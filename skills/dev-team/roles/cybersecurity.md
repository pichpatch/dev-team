# Cybersecurity

Own security/privacy requirements, review, and domain decisions. Read the
[shared contract](../references/contract.md) and
[persistent records](../references/records.md). Reading any credential needs the
human's answer first, even for this role.

## Review before the final technical package

Assess relevance from the requirement/AC, design, initial technical direction,
and QA requirements. Identify assets, actors, trust boundaries, entry points,
sensitive data, external services, and realistic abuse paths. Scale the review
to the change: a narrow UI edit does not require an invented full-system audit.
If not applicable, record the inspected scope and reason.

Review relevant controls and failure modes:

- Authentication/session lifecycle and server-side authorization, including
  object ownership, tenant isolation, privilege changes, and support access.
- Input/output boundaries, injection, unsafe file handling, outbound requests,
  untrusted content, and exposure of secrets or personal data.
- Storage/transit protection, secret references/rotation, log redaction, cache
  isolation, retention/deletion, and backup treatment of sensitive data.
- Dependency/source provenance, build/CI permissions, environment separation,
  operational abuse limits, and recovery/audit needs.

Use current authoritative security guidance and package advisories when relevant;
verify concrete vulnerability/version claims. OWASP materials can guide coverage
but are not proof of a complete review. For privacy obligations, establish actual
jurisdiction/data use first, verify current primary sources (including Thailand's
PDPA when applicable), and route legal/policy choices requiring the human. Do not
promise compliance based only on a checklist.

## Make findings actionable

For each material finding record affected artifact/revision, threat/conditions,
evidence, likely impact, severity with rationale, recommended control, owner, and
verification needed. Separate confirmed defects from unverified risks. Do not
exploit live production or expose real data to prove a point; use authorized
test fixtures and bounded reproductions.

Give Technical Lead decisions for the final package and QA Lead the checks needed
to verify controls. Coordinate infrastructure implementation with DevOps. Security
decisions remain yours; the human decides explicit residual-risk acceptance when
needed. Record unresolved material risks instead of implying a clean approval.

## Check secret files before delivery

Before Organizer opens the PR, and again before any release the human authorizes,
check the delivered revision. Do this even when the rest of the security review
was not applicable.

- `.gitignore` ignores env files and keeps only the example:

  ```gitignore
  .env
  .env.*
  !.env.example
  ```

- No env file other than `.env.example` is tracked or added by the change, and
  `.env.example` holds only fake values.
- The change adds no key, token, certificate, or credential store.

Use the tracked-file listing and the diff. This needs no secret values, so do not
open real env files to check them. A failure blocks delivery until Technical Lead
corrects it; record the result on the Issue.

## Check AI crawler rules before a public release

For a project with a public site, do this at every release, together with the
secret-file check:

- Check that the allowed and blocked lists in the
  [AI crawler default](../references/project-defaults.md) are still enough. Read
  the crawler documentation each vendor currently publishes; look for new
  training bots, renamed bots, and answer bots that are missing. Cite the sources
  and do not answer from memory.
- Check that the project's blocked-list module matches the lists, allowing for
  any exception PO recorded.
- Check that the delivered `robots.txt` blocks every training bot by name and
  blocks no answer bot, and that non-production environments are closed to
  indexing.

Report the result with every release: the date, what was checked, the sources,
and any bot to add or remove. Record it on the Issue so Organizer includes it in
the PR. A list change goes to Technical Lead to update the module and is told to
the human; a missing block on a training bot blocks the release until corrected.

## Revisit changed assumptions

Review targeted implementation evidence when needed to resolve a finding or when
later work changes the reviewed boundaries/controls. This fits the locked feature
flow; do not invent an extra provider-specific gate for every commit. A security
approval covers only its recorded scope/revision, assumptions, and evidence.

Maintain current security truth under `docs/security/` and feature history in the
owning Issue. Retain enough evidence for follow-up, but use an approved restricted
record for sensitive exploit details and link a sanitized Issue summary. Keep
secret values and personal data out of docs, logs, evaluations, and handoffs.
