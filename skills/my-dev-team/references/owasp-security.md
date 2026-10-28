# Shared OWASP security standard

This is the single shared security-testing playbook for Technical Lead and Cybersecurity. Load it when designing or verifying a security-relevant change or reviewing a draft release; do not copy its checklist into role guides. The existing role guides and release lifecycle govern ownership, approvals, and test depth.

## Sources and applicability

Use OWASP Top 10 (web risk taxonomy), OWASP ASVS 5.0 (verifiable requirements), OWASP Web Security Testing Guide (testing procedures), OWASP API Security Top 10 2023 (API threats), and OWASP File Upload Cheat Sheet (upload defenses). Record the edition/version and exact requirement or test IDs used. OWASP Top 10 is not an exhaustive checklist; select ASVS requirements and WSTG tests for the actual stack and attack surface. Revisit source editions when maintaining this playbook; do not silently change standards mid-release.

References:
- https://owasp.org/Top10/
- https://owasp.org/www-project-application-security-verification-standard/
- https://owasp.org/www-project-web-security-testing-guide/
- https://owasp.org/API-Security/
- https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

## Owners and workflow

- **Technical Lead:** Map applicable controls into architecture, implementation tasks, and technical review; ensure secure defaults and testability. Ask Cybersecurity for independent security requirements. Record any deviation from a security requirement with its risk and notify the human under the existing contract.
- **Cybersecurity:** Independently select and execute relevant checks, evaluate evidence, record `SEC-` requirements and findings, and retest fixes. Do not accept a scanner's lack of findings as proof of safety.
- **QA Lead:** Cover the resulting acceptance criteria and relevant regressions through the existing DoD workflow.
- **DevOps:** Implement and provide evidence for infrastructure isolation, edge protections, monitoring, alerting, and response configuration. Cybersecurity verifies security effectiveness; DevOps owns operations.
- **Human:** Owns the final release/deployment decision and explicit acceptance of residual risk.

## Baseline coverage matrix

For each release, inventory exposed functionality and mark each area applicable or not applicable, with a reason. Run the baseline evidence review on every release; use the role guide's patch/minor/major depth and risk override for dynamic testing. New or changed high-risk boundaries require deeper targeted checks even in patches.

| ID | Area | Minimum verification |
| --- | --- | --- |
| OW-01 | Access control | Server-side object, role, tenant, and administrative authorization; cross-account negative tests with test fixtures. |
| OW-02 | Authentication and sessions | Login, logout, reset, token/session expiry, rotation, revocation, and impersonation resistance. |
| OW-03 | Injection | Parameterized database access and bounded negative tests for SQL/command/template injection where applicable. |
| OW-04 | File uploads and processing | Validate upload type/content/size, isolate storage, deny execution, enforce ownership and safe retrieval; see mandatory upload control below. |
| OW-05 | API security | Object/property/function authorization, mass assignment, input limits, resource enumeration, and excessive data exposure. |
| OW-06 | Security configuration | Production-safe flags, debug/admin exposure, storage permissions, TLS, headers, and environment separation. |
| OW-07 | Dependencies and supply chain | Changed packages/images, advisories, build/CI permissions, and provenance. |
| OW-08 | Cryptography, secrets, and data | Secret exposure, storage/transit protection, sensitive logging, cache and backup handling. |
| OW-09 | Abuse and availability | Rate limits, quotas, resource exhaustion controls, upload limits, and edge/WAF protections; inspect configuration and bounded staging tests, never launch disruptive production DoS tests. |
| OW-10 | Detection and response | Security-event logs without sensitive values, actionable alerts, incident routing, and tested operational response for material threats. |

The matrix is a routing index, not a claim that each row corresponds one-to-one to an OWASP Top 10 category. For every applicable area, identify precise ASVS/WSTG/API references and any project-specific `SEC-` requirements.

## Mandatory file-upload execution-prevention control

If **any** file-upload or import pathway exists, this control is mandatory at every release, even when upload code did not change. Review all paths including API uploads, admin imports, media processing, direct-to-object-storage flows, and legacy endpoints.

**Technical Lead must design and verify implementation of:**
1. An allowlist of required file types, validated server-side using extension, declared MIME, and content/signature as appropriate; never trust client-provided names or MIME alone. Apply size, count, decompression, and processing limits.
2. Storage that cannot execute uploaded content as server-side code. Keep uploads outside executable application/web roots or use isolated object storage with no code execution; ensure web-server, runtime, and deployment configuration enforce this, not merely filename checks.
3. Generated opaque object names, safe paths, no traversal or overwrite of application files, least-privilege storage permissions, and access controls for private content.
4. Safe serving with suitable Content-Type/Content-Disposition, no active-content execution in privileged application origins where relevant, and secure downstream parsers/processors.
5. Security-event logging for rejected uploads and suspicious patterns, plus DevOps-owned monitoring/alerts and appropriate edge controls.

**Cybersecurity must independently test and document:**
1. Inventory upload endpoints and trace storage, processing, and serving paths.
2. In an authorized isolated test environment, try harmless non-executing fixtures with misleading extensions/MIME, double extensions, path traversal names, and active-content formats relevant to the stack; confirm rejection or inert storage and retrieval.
3. Verify server-side execution is impossible at the upload destination by inspecting runtime/web-server/storage configuration and using a harmless canary that cannot perform destructive actions. Never upload or execute a real web shell.
4. Test cross-user access and overwrite restrictions with separate test identities.
5. Confirm rejected attempts produce appropriate redacted security events and that DevOps can demonstrate configured alerting/blocking where required.

**Release gate:** If uploads exist, `OW-04` cannot be silently skipped. Confirmed execution of uploaded server-side code, or inability to establish the non-executable storage boundary, is a blocking critical risk requiring correction or explicit human risk decision under the existing release contract; do not describe an unverified control as passing. Lack of runtime monitoring evidence is recorded as a gap and escalated based on impact. No WAF replaces application-level isolation.

## Safe execution and tool permissions

Prefer read-only review, unit/integration tests, configuration evidence, and non-destructive authenticated test fixtures. Active scanners (e.g. OWASP ZAP) and vulnerability templates (e.g. Nuclei) are optional tools, not automatic permissions. Before active testing, establish authorized targets, environment, accounts, scope, request budget, and stop conditions; require explicit authorization for intrusive activity. Never use production credentials for scanning, attack real users, run disruptive load/DoS tests, or expose secrets or personal data. Mark checks **NOT TESTED** when the required access or environment is unavailable.

## Evidence and release decision

The security report is a checklist, written from [the security report template](../assets/security-report.html). It is one HTML document per release, kept in `docs/security/`, updated in place on every retest, and linked from the draft release notes. Its rows are fixed when the review starts: the `SECRET-FILES`, `AI-CRAWLERS` (public site), `DEPENDENCIES`, and `PROD-CONFIG` checks, every `SEC-` requirement in the release, and each applicable `OW-` area. A reader can then see in one table what was checked, how, what should have happened, and what did.

Each row has: **ID**; **check**, what must be true, with the OWASP edition and the exact ASVS/WSTG/API reference; **how tested**, the steps, tool and version, test data (synthetic or redacted), and the authorized environment, enough for someone else to repeat it; **expected result**; **actual result**; **status** `PASS` / `FAIL` / `NOT APPLICABLE` / `NOT TESTED`; **evidence**, a sanitized link with the revision and round; and, for a `FAIL`, the severity, whether it blocks, the owner, and the related paths (see below). `PASS` requires positive verification evidence, not just absence of scanner alerts. Evidence may cite a QA case and its revision instead of repeating the test. `NOT APPLICABLE` needs an inspected-scope rationale; `NOT TESTED` states the blocker and residual risk.

### What blocks, and how a retest stays small

A `FAIL` **blocks** the release when it is a `SEC-` requirement that is not met, a Critical or High finding, a tracked secret or a failed secret-file check, a production key holding a placeholder or test value, a missing block on an AI training bot, or confirmed execution of uploaded code. Every other finding is **follow-up**: it goes in the report with severity, owner, and where it is tracked, it triggers no retest round, and the human sees it. A `NOT TESTED` row of a blocking kind needs the human's decision.

Rate each `FAIL` with this scale, unless the project has its own, and write one line on why:

| Severity | Meaning |
| --- | --- |
| Critical | Exploitable without special access, and it exposes or changes other users' data, gives admin rights or code execution, or leaks a secret |
| High | Exploitable by a signed-in user or under a likely precondition, and it crosses a permission boundary or exposes personal data |
| Medium | Needs an unlikely precondition or a chain with another weakness, or removes one layer of defense while another still holds |
| Low | Hardening, or information that is neither sensitive nor useful to an attacker on its own |

Technical Lead may challenge a rating once, with evidence. If they still disagree, the row keeps Cybersecurity's rating and the disagreement goes in Decisions for the human.

A fix is retested once, in a bounded scope: the failing blocking rows, the rows whose code the fix touched (read from the diff), and the related paths Cybersecurity wrote in the row when it raised the finding. It is not a new full review, and `PASS` rows the fix did not touch stay `PASS`. A problem found during a retest becomes a new row. It blocks only when it lies inside that retest's scope or is Critical; anything else is follow-up, or a decision for the human when it is High.

A finding gets at most **two** fix-and-retest rounds. If it still fails after the second, or a retest shows another input form passing the same guard, stop patching: Technical Lead and Cybersecurity revisit the enforcement boundary together ([security hardening](engineering.md)). If that does not close it, the human decides: accept the remaining risk, hold the release, or change the scope.

The whole release review is also bounded: the first review and at most **two** retest passes. Whatever still blocks after the second pass goes to the human in Decisions for the human; Cybersecurity does not start a third pass on its own.

### When the report is complete

The report is complete when every row has a status, a "how tested" someone else could repeat, an expected and an actual result, and evidence; every `FAIL` has its severity with a reason, whether it blocks, its owner, and its related paths; and the Result section counts the rows and names the blocking ones. Technical Lead, or whoever reviews the report, checks it against this list only. It may return the report **once**, naming the rows that are missing something. Disagreeing with a verdict or a rating is not a reason to return it: record the disagreement in Decisions for the human. Organizer never grades the report.

When Cybersecurity's model changes mid-review ([roster](roster.md)), the replacement continues from the report as it stands: it finishes the open rows and does not reopen `PASS` rows or start the review again.

Failures follow the existing Technical Lead fix -> Cybersecurity retest -> QA regression -> DevOps draft-release path; this document creates no new approval role or parallel release lifecycle. The report's Result section names the blocking rows, so the human sees the state in one place.

## Authorization and roles (OW-01)

This section is design guidance for a project that chooses role-based access
control (RBAC); it is not a mandatory model for every application.

### Design direction

- Keep **authentication** (who the user is), **authorization** (what the user
  may do, and to which resources), and the delivery team's own roles separate.
- With RBAC, model users, roles, and permissions as many-to-many: a role holds
  many permissions, a user may hold several roles, and a permission may belong
  to several roles. A user gets the union of their roles' permissions.
- Grant no direct per-user permission overrides by default; an exception needs
  an explicit project requirement.
- Enforce every permission on the server at the protected operation. Hiding an
  action in the frontend is not an authorization check.
- No role permission, however broad, overrides resource ownership, tenant or
  organization isolation, or another contextual constraint. A union of roles
  must never widen access across those boundaries.
- Deny by default, and prevent privilege escalation, including a user assigning
  roles or permissions they do not hold.
- Role names such as Admin, Staff, or Operations are examples, not mandated
  roles.

### Decided per project by PO

- The roles, the permission catalog, membership rules, and which actions each
  role may perform.
- Whether administrators may change roles and permissions at runtime.
- Whether a role hierarchy exists, its order, and who may view, edit, assign
  roles to, or disable other users. No hierarchy rule applies by default.
- Separation of duties, delegated privileges, and sensitive approval flows.

### Who does what

PO defines the business authorization requirements and AC. Technical Lead
designs the data model and the server-side checks. Cybersecurity independently
tests horizontal and vertical privilege escalation, combinations of roles,
ownership and tenant boundaries, unauthorized role or permission changes, and
server-side enforcement, using the OW-01 evidence format above. QA Lead
verifies the AC and the regressions around them.

## Authentication and session lifecycle (OW-02)

This section is a shared design and independent-verification checklist, not a universal product login policy. Technical Lead proposes risk-based session/device limits, idle and absolute lifetimes, reauthentication triggers, and logout scope; PO approves the business policy. Cybersecurity verifies the resulting security requirements independently, and QA verifies acceptance criteria and regression behavior. Record project-specific choices and exceptions before implementation; never infer a one-device or unlimited-device default.

### Design requirements and examples

- Validate access-token integrity, issuer/audience, intended use, expiry, and authorization at the trusted server boundary. Extracting a user ID from an unverified token is not authentication. Prevent cross-user, cross-tenant, and unauthorized access regardless of device policy.
- Define allowed simultaneous sessions (one device, web plus mobile, or multiple), replacement behavior, and whether logout revokes this session or all sessions. For one-device policies, use an atomic session replacement so concurrent logins cannot both remain active.
- Revoke sessions server-side on logout, replacement, account disablement, and other approved triggers; reject revoked access tokens promptly even if cryptographic expiry has not elapsed. Store a session identifier or token hash rather than a raw bearer token in the session store. Keep revocation state until the affected token can no longer be accepted.
- A cache may speed validation, but a cache miss is **unknown**, not **valid** or **revoked**. Use distinct active/revoked/unknown states. Verify token signature and claims before trusting its user/session identifiers. Cache active session state and revocation markers with appropriate expiration and consistency rules. A durable authoritative store must survive cache restart/eviction; a bounded database fallback may resolve unknown states. If neither cache nor authoritative store can verify authorization, fail closed. Prevent repeated misses, invalid tokens, or cache outages from exhausting the database through rate limits, request coalescing, bounded concurrency, and appropriate resilience measures. Document cache invalidation/race conditions and session-state propagation.
- Issue separate refresh-token credentials per device/session; do not share one refresh token across devices. Protect refresh tokens in storage and transit, rotate on successful refresh, invalidate the prior token, and detect replay/reuse. Define safe handling of simultaneous refresh requests so races do not accidentally create parallel valid tokens or lock out legitimate sessions.
- While the approved session remains eligible, automatic refresh-token rotation is the default. Renewal never overrides revocation, inactivity timeout, absolute session lifetime, forced reauthentication, or risk-based step-up authentication. Technical Lead proposes these limits and PO approves; do not hardcode a universal six-month lifetime or indefinite login. Define behavior at expiry, logout, password reset, account recovery, and device loss.
- Document latency and availability budgets for the gateway/session store, realistic peak traffic, cache restarts, database fallback, and recovery. A secure control that collapses authentication under load is not a complete design.

### Cybersecurity verification and evidence

For each applicable case, record OW-02 and relevant project SEC IDs, approved policy, test environment/revision, expected and actual behavior, sanitized evidence, and PASS / FAIL / NOT APPLICABLE / NOT TESTED:

1. Test successful/failed login, token signature/claim/expiry checks, unauthenticated and cross-user/tenant attempts, and login throttling or abuse controls.
2. Test each approved device policy, concurrent logins, atomic replacement, current-device logout and logout-everywhere where applicable.
3. Capture a valid access token, revoke its session, and prove it is rejected before natural expiry, including after cache eviction/restart and during cache/database inconsistencies. Verify revoked markers do not cause unbounded database queries.
4. Test refresh rotation, rejection and alerting of reused old refresh tokens, session/device isolation, expiry boundaries, simultaneous refreshes, and the approved idle/absolute lifetime and step-up rules.
5. With authorized, bounded staging tests, verify gateway latency and database load under realistic traffic, cache misses/restarts, store slowdown/outage, and repeated invalid requests. Confirm fail-closed behavior when authoritative verification is unavailable; coordinate performance and operational evidence with QA and DevOps.

A documented example (Redis session cache plus durable database fallback) is an option, not a mandated architecture. Security properties and measured evidence are mandatory where applicable.
