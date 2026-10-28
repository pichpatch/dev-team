# Shared OWASP security standard

The one security-testing playbook for Technical Lead and Cybersecurity. Load it
when designing or verifying a security-relevant change or reviewing a draft
release. Do not copy its checklist into role guides; the role guides and
[release lifecycle](release-lifecycle.md) govern ownership, approvals, and depth.

## Sources

Use OWASP Top 10 (risk taxonomy), ASVS 5.0 (verifiable requirements), the Web
Security Testing Guide (WSTG, test procedures), API Security Top 10 2023 (API
threats), and the File Upload Cheat Sheet. Record the edition and the exact
requirement or test IDs used. The Top 10 is not a complete checklist: pick ASVS
requirements and WSTG tests for the real stack and attack surface. Do not change
editions in the middle of a release.

- https://owasp.org/Top10/
- https://owasp.org/www-project-application-security-verification-standard/
- https://owasp.org/www-project-web-security-testing-guide/
- https://owasp.org/API-Security/
- https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

## Owners

- **Technical Lead:** builds the controls into architecture, tasks, and review;
  secure defaults and testability. Asks Cybersecurity for independent
  requirements. Records any deviation with its risk and tells the human.
- **Cybersecurity:** independently chooses and runs checks, judges evidence,
  records `SEC-` requirements and findings, retests fixes. A scanner finding
  nothing is not proof of safety.
- **QA Lead:** covers the resulting AC and regressions in the DoD.
- **DevOps:** builds and evidences infrastructure isolation, edge protection,
  monitoring, alerting, and response. Cybersecurity verifies they work.
- **Human:** makes the release decision and accepts remaining risk.

## Baseline coverage matrix

For each release, list what is exposed and mark each area applicable or not,
with a reason. The baseline evidence review runs every release; dynamic testing
depth follows the role guide's patch/minor/major levels and risk override. A new
or changed high-risk boundary needs deeper checks even in a patch.

| ID | Area | Minimum verification |
| --- | --- | --- |
| OW-01 | Access control | Server-side object, role, tenant, and admin authorization; cross-account negative tests with fixtures. |
| OW-02 | Authentication and sessions | Login, logout, reset, expiry, rotation, revocation, impersonation resistance. |
| OW-03 | Injection | Parameterized data access; bounded negative tests for SQL, command, and template injection. |
| OW-04 | File uploads and processing | Type, content, and size validation; isolated storage; no execution; ownership; safe retrieval ([below](#mandatory-file-upload-execution-prevention-control)). |
| OW-05 | API security | Object, property, and function authorization; mass assignment; input limits; enumeration; excessive data exposure. |
| OW-06 | Security configuration | Production-safe flags, debug and admin exposure, storage permissions, TLS, headers, environment separation. |
| OW-07 | Dependencies and supply chain | Changed packages and images, advisories, build and CI permissions, provenance. |
| OW-08 | Cryptography, secrets, and data | Secret exposure, storage and transit protection, sensitive logging, cache and backup handling. |
| OW-09 | Abuse and availability | Rate limits, quotas, exhaustion controls, upload limits, edge/WAF; config review and bounded staging tests, never disruptive production DoS. |
| OW-10 | Detection and response | Security logs without sensitive values, actionable alerts, incident routing, tested response. |

The matrix is a routing index, not a one-to-one map to the Top 10. For each
applicable area, name the exact ASVS, WSTG, or API references and any project
`SEC-` requirements.

## Mandatory file-upload execution-prevention control

If **any** upload or import path exists, this control applies at every release,
even when upload code did not change. Cover API uploads, admin imports, media
processing, direct-to-storage flows, and legacy endpoints.

**Technical Lead designs and verifies:**

1. A server-side allowlist of file types, checked by extension, declared MIME,
   and content signature as appropriate; never trust client names or MIME alone.
   Size, count, decompression, and processing limits.
2. Storage that cannot run uploads as server code: outside executable web roots,
   or isolated object storage. Enforced by web server, runtime, and deployment
   config, not filename checks.
3. Generated opaque names, safe paths, no traversal or overwrite of app files,
   least-privilege storage, access control on private content.
4. Safe serving with the right Content-Type and Content-Disposition, no active
   content running in privileged origins, and safe downstream parsers.
5. Security logs for rejected and suspicious uploads, with DevOps-owned alerts
   and edge controls.

**Cybersecurity independently tests and documents:**

1. Every upload endpoint, traced through storage, processing, and serving.
2. In an authorized isolated environment, harmless fixtures with misleading
   extensions and MIME, double extensions, traversal names, and active-content
   formats for the stack: rejected, or stored and served inert.
3. That server-side execution is impossible at the destination: inspect runtime,
   web-server, and storage config, and use a harmless canary. Never upload or run
   a real web shell.
4. Cross-user access and overwrite limits, with separate test identities.
5. That rejected attempts produce redacted security events, and DevOps can show
   the alerting or blocking where required.

**Release gate:** with uploads, `OW-04` is never silently skipped. Confirmed
execution of uploaded code, or failing to establish the non-executable boundary,
is a blocking critical risk: fix it or get the human's explicit risk decision.
Never call an unverified control passing. Missing runtime monitoring evidence is
a recorded gap, escalated by impact. No WAF replaces application-level
isolation.

## Safe execution and tool permissions

Prefer read-only review, unit and integration tests, configuration evidence, and
non-destructive authenticated fixtures. Scanners (OWASP ZAP) and templates
(Nuclei) are optional tools, not automatic permission. Before active testing,
agree the targets, environment, accounts, scope, request budget, and stop
conditions; intrusive testing needs explicit authorization. Never scan with
production credentials, attack real users, run disruptive load or DoS tests, or
expose secrets or personal data. Mark checks **NOT TESTED** when the access or
environment is not available.

## Evidence and release decision

The security report is a checklist written from
[the security report template](../assets/security-report.html). Its rows are
fixed when the review starts, and differ by kind:

| | Feature check | Release review |
| --- | --- | --- |
| Scope | Only what the diff touches | Everything since the last release, and how features work together |
| Rows | `SECRET-FILES`; the feature's `SEC-` requirements; the `OW-` areas the diff touches; `DEPENDENCIES` the diff adds or upgrades; `AI-CRAWLERS` only when the diff touches crawler rules or routing on a public site | `SECRET-FILES`; `AI-CRAWLERS` (public site); `DEPENDENCIES` since the last release; `PROD-CONFIG`; every `SEC-` requirement in the release; each applicable `OW-` area; open follow-up from feature checks |
| Attack testing | None; a bounded check of the touched paths | By version: patch none, minor targeted, major full ([Cybersecurity](../roles/cybersecurity.md#review-a-draft-release)) |
| Production configuration | Never | Yes, after asking the human for the file by name |
| Where it lives | A checklist recorded on the Issue (or given to Organizer when there is none) and put in the PR | One HTML document per release in `docs/security/`, linked from the draft release notes |

Either kind is updated in place on every retest, so one table shows what was
checked, how, what should have happened, and what did.

**Each row has:**

- **ID**;
- **check:** what must be true, with the OWASP edition and exact ASVS, WSTG, or
  API reference;
- **how tested:** steps, tool and version, synthetic or redacted test data, and
  the authorized environment, enough for someone else to repeat it;
- **expected result** and **actual result**;
- **status:** `PASS`, `FAIL`, `NOT APPLICABLE`, or `NOT TESTED`;
- **evidence:** a sanitized link with the revision and round;
- for a `FAIL`: severity, whether it blocks, owner, and related paths.

`PASS` needs positive evidence, not just a quiet scanner. Evidence may cite a QA
case and its revision instead of repeating the test. `NOT APPLICABLE` states the
scope inspected; `NOT TESTED` states the blocker and the remaining risk.

### What blocks, and how a retest stays small

A `FAIL` **blocks** when it is: an unmet `SEC-` requirement, a Critical or High
finding, a tracked secret or failed secret-file check, a production key with a
placeholder or test value, a missing block on an AI training bot, or confirmed
execution of uploaded code. Everything else is **follow-up**: in the report with
severity, owner, and where it is tracked; no retest round; the human sees it. A
`NOT TESTED` row of a blocking kind needs the human's decision.

Rate each `FAIL` with this scale unless the project has its own, with one line
on why:

| Severity | Meaning |
| --- | --- |
| Critical | Exploitable without special access, and it exposes or changes other users' data, gives admin rights or code execution, or leaks a secret |
| High | Exploitable by a signed-in user or under a likely precondition, and it crosses a permission boundary or exposes personal data |
| Medium | Needs an unlikely precondition or a chain with another weakness, or removes one defense layer while another holds |
| Low | Hardening, or information neither sensitive nor useful to an attacker alone |

Technical Lead may challenge a rating once, with evidence. If they still
disagree, the row keeps Cybersecurity's rating and the disagreement goes in
Decisions for the human.

**A retest is bounded:** the failing blocking rows, the rows whose code the fix
touched (from the diff), and the related paths named when the finding was
raised. It is not a new review; untouched `PASS` rows stay `PASS`. A problem
found in a retest becomes a new row. It blocks only if it is inside that scope or
is Critical; otherwise it is follow-up, or a decision for the human when High.

**At most two fix-and-retest rounds per finding.** If it still fails, or a
retest shows another input form passing the same guard, stop patching: Technical
Lead and Cybersecurity revisit the enforcement boundary together
([security hardening](engineering.md#verification-and-review-package)). If that
does not close it, the human decides: accept the risk, hold the release, or
change scope.

**The whole release review is bounded too:** the first review plus at most two
retest passes. Whatever still blocks goes to the human in Decisions for the
human; Cybersecurity never starts a third pass on its own.

### When the report is complete

Complete means: every row has a status, a repeatable "how tested", expected and
actual results, and evidence; every `FAIL` has a reasoned severity, whether it
blocks, an owner, and related paths; and the Result section counts the rows and
names the blocking ones.

Technical Lead (or whoever reviews) checks the report against this list only,
and may return it **once**, naming the rows missing something. Disagreeing with
a verdict or rating is not a reason to return it: record it in Decisions for the
human. Organizer never grades the report.

If Cybersecurity's model changes mid-review ([roster](roster.md)), the
replacement continues from the report as it stands: it finishes open rows and
never reopens `PASS` rows or restarts.

Failures follow the existing path: Technical Lead fix → Cybersecurity retest →
QA regression → DevOps draft release. This document adds no approval role or
parallel lifecycle.

## Authorization and roles (OW-01)

Design guidance for a project that chooses role-based access control (RBAC); not
a required model.

**Design direction:**

- Keep **authentication** (who the user is), **authorization** (what they may do,
  to which resources), and the delivery team's own roles separate.
- With RBAC, users, roles, and permissions are many-to-many; a user gets the
  union of their roles' permissions.
- No direct per-user permission overrides unless a project requirement says so.
- Enforce every permission on the server at the protected operation. Hiding a
  button is not authorization.
- No role, however broad, overrides resource ownership, tenant or organization
  isolation, or other contextual limits; a union of roles never widens access
  across them.
- Deny by default. Prevent privilege escalation, including users granting roles
  or permissions they do not hold.
- Admin, Staff, or Operations are examples, not required roles.

**Decided per project by PO:** the roles, the permission catalog, membership
rules, and what each role may do; whether admins can change roles at runtime;
whether a role hierarchy exists and who may view, edit, assign roles to, or
disable whom (no hierarchy by default); separation of duties, delegation, and
sensitive approval flows.

**Who does what:** PO defines the business authorization requirements and AC.
Technical Lead designs the data model and server-side checks. Cybersecurity
tests horizontal and vertical escalation, role combinations, ownership and
tenant boundaries, unauthorized role changes, and server enforcement, using the
evidence format above. QA Lead verifies the AC and surrounding regressions.

## Authentication and session lifecycle (OW-02)

A shared design and verification checklist, not a universal login policy.
Technical Lead proposes risk-based device limits, idle and absolute lifetimes,
reauthentication triggers, and logout scope; PO approves the business policy.
Cybersecurity verifies the security requirements, QA the AC and regressions.
Record project choices before implementation; never assume one device or
unlimited devices.

### Design requirements

- Validate token integrity, issuer and audience, intended use, expiry, and
  authorization at the trusted server boundary. Reading a user ID from an
  unverified token is not authentication. Block cross-user, cross-tenant, and
  unauthorized access whatever the device policy.
- Define allowed simultaneous sessions (one device, web plus mobile, many),
  replacement behavior, and whether logout ends this session or all. For one
  device, replace sessions atomically so two concurrent logins cannot both
  stay active.
- Revoke sessions on the server on logout, replacement, account disablement,
  and other approved triggers; reject revoked tokens promptly even before
  expiry. Store a session ID or token hash, never a raw bearer token. Keep
  revocation state until the token can no longer be accepted.
- A cache may speed validation, but a cache miss is **unknown**, not valid or
  revoked: use active, revoked, and unknown states. Verify signature and claims
  before trusting IDs. A durable authoritative store survives cache restarts; a
  bounded database fallback may resolve unknowns. If neither can verify, fail
  closed. Protect the database from repeated misses, bad tokens, or cache
  outages with rate limits, request coalescing, and bounded concurrency.
  Document invalidation races and how session state propagates.
- Issue a separate refresh token per device or session. Protect it, rotate it on
  each refresh, invalidate the old one, and detect reuse. Handle simultaneous
  refreshes so races neither create parallel valid tokens nor lock out real
  users.
- Automatic refresh rotation is the default while the session is eligible.
  Renewal never overrides revocation, idle timeout, absolute lifetime, forced
  reauthentication, or step-up. Technical Lead proposes the limits and PO
  approves; never a hardcoded universal lifetime or endless login. Define
  behavior at expiry, logout, password reset, recovery, and device loss.
- Document latency and availability budgets for the session store at peak
  traffic, cache restarts, database fallback, and recovery. A control that
  collapses login under load is not a complete design.

### Cybersecurity verification

For each case, record OW-02 and the project `SEC-` IDs, the approved policy,
environment and revision, expected and actual behavior, sanitized evidence, and
PASS / FAIL / NOT APPLICABLE / NOT TESTED:

1. Successful and failed login, signature, claim, and expiry checks,
   unauthenticated and cross-user or cross-tenant attempts, login throttling.
2. Each approved device policy, concurrent logins, atomic replacement, logout
   here and logout everywhere.
3. Revoke a captured valid token's session and prove it is rejected before
   expiry, including after cache eviction or restart and during cache/database
   inconsistency. Revocation markers must not cause unbounded queries.
4. Refresh rotation, rejection and alerting of reused tokens, session isolation,
   expiry edges, simultaneous refreshes, idle and absolute limits, step-up.
5. Bounded, authorized staging tests of latency and database load under
   realistic traffic, cache misses and restarts, store slowdown or outage, and
   repeated bad requests. Confirm fail-closed behavior; agree performance
   evidence with QA and DevOps.

A Redis session cache with a durable database fallback is one option, not a
required architecture. The security properties and measured evidence are
required where they apply.
