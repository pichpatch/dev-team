// Format-Preserving Encryption (FPE) for ref_id: turns the next number of a table's sequence into the
// encrypted sequence number stored in its `ref_id` column — a fixed 6-character base62 id used only in
// public (SEO) URLs, and impossible to reverse without REF_ID_KEY.
// Rules: the dev-team skill's standard stack reference, "Identifiers and public URLs".

import { createHmac } from "node:crypto";

const ROUNDS = 10; // the halves are only 16 bits, so it needs more rounds than a big-block cipher (NIST FF1 uses 10)
const MAX_SEQUENCE = 0xffffffff;
const ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
const WIDTH = 6; // 62^6 > 2^32, so every 32-bit value fits in 6 characters

function roundValue(key: Buffer, tweak: string, round: number, half: number): number {
  return createHmac("sha256", key).update(`${tweak}|${round}|${half}`).digest().readUInt16BE(0);
}

function encrypt(sequence: number, key: Buffer, tweak: string): number {
  let left = sequence >>> 16;
  let right = sequence & 0xffff;
  for (let round = 1; round <= ROUNDS; round++) {
    [left, right] = [right, left ^ roundValue(key, tweak, round, right)];
  }
  return ((left << 16) | right) >>> 0;
}

function decrypt(value: number, key: Buffer, tweak: string): number {
  let left = value >>> 16;
  let right = value & 0xffff;
  for (let round = ROUNDS; round >= 1; round--) {
    [left, right] = [right ^ roundValue(key, tweak, round, left), left];
  }
  return ((left << 16) | right) >>> 0;
}

function toBase62(value: number): string {
  let out = "";
  for (let i = 0; i < WIDTH; i++) {
    out = ALPHABET[value % 62] + out;
    value = Math.floor(value / 62);
  }
  return out;
}

function fromBase62(text: string): number | null {
  if (text.length !== WIDTH) return null;
  let value = 0;
  for (const char of text) {
    const digit = ALPHABET.indexOf(char);
    if (digit < 0) return null;
    value = value * 62 + digit;
  }
  return value <= MAX_SEQUENCE ? value : null;
}

/** `type` is the entity type ("product", "category", …) so different types never share a ref_id. */
export function encodeRefId(type: string, sequence: number, key: Buffer): string {
  if (!Number.isInteger(sequence) || sequence < 0 || sequence > MAX_SEQUENCE) {
    throw new RangeError(`sequence must be an integer from 0 to ${MAX_SEQUENCE}, got ${sequence}`);
  }
  return toBase62(encrypt(sequence, key, type));
}

/** Recovers the sequence number (for debugging or data repair) — requests look up `ref_id` directly. */
export function decodeRefId(type: string, refId: string, key: Buffer): number | null {
  const value = fromBase62(refId);
  return value === null ? null : decrypt(value, key, type);
}

/** Cheap format check for a URL suffix before querying — anything else is an immediate 404. */
export function isRefId(text: string): boolean {
  return fromBase62(text) !== null;
}

let cachedKey: Buffer | undefined;

function envKey(): Buffer {
  if (cachedKey) return cachedKey;
  const raw = process.env.REF_ID_KEY;
  if (!raw) throw new Error("REF_ID_KEY is not set");
  const key = Buffer.from(raw, "base64");
  if (key.length < 32) throw new Error("REF_ID_KEY must be at least 32 random bytes, base64-encoded");
  cachedKey = key;
  return key;
}

/** The one shared module — repositories call encode when inserting a row; never re-implement it per feature. */
export const refId = {
  encode: (type: string, sequence: number) => encodeRefId(type, sequence, envKey()),
  decode: (type: string, value: string) => decodeRefId(type, value, envKey()),
  isValid: isRefId,
};
