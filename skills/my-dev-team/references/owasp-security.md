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

For each check record: check ID; OWASP edition and specific reference; release revision; affected endpoint/component; applicability and rationale; procedure/tool and authorized environment; expected result; observed result; evidence link (sanitized); status **PASS / FAIL / NOT APPLICABLE / NOT TESTED**; severity and owner if unresolved; remediation and retest revision. `PASS` requires positive verification evidence, not just absence of scanner alerts. `NOT APPLICABLE` needs an inspected-scope rationale; `NOT TESTED` states the blocker and residual risk.

Summarize the coverage matrix, blocking findings, untested controls, deviations, monitoring gaps, and human decisions in the existing Cybersecurity release report. Failures follow the existing Technical Lead fix -> Cybersecurity retest -> QA regression -> DevOps draft-release path; this document creates no new approval role or parallel release lifecycle.
