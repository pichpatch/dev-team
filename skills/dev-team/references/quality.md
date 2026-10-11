# Quality, evidence, and supportability

QA Lead owns strategy, supportability, coverage policy, and final AC review.
Senior QA executes assigned verification. Senior Developer implements unit and
integration tests; Design Tester supplies design verification to Design Lead.

## Before implementation

Map each PO-defined AC to tests with observable expected outcomes. A compact case
record contains ID, AC/rule reference, preconditions/data/role, steps or automation,
expected result, priority/risk, and required environment/enablers. Test authors
must know expected behavior before deriving assertions from the implementation.

Record strategy/cases in the existing QA docs. For a new location,
`docs/qa/{feature-slug}.html` can hold cross-application cases; implementation-specific
test details may live with the application/service. Link the records from the
feature Issue instead of introducing a second task tracker.

Use the [draft coverage policy](project-defaults.md) only when no project policy
exists. State command, metric, scope, baseline, and exclusions. Report planned
coverage and actually executed coverage separately. Every relevant AC needs
evidence regardless of the aggregate percentage.

## Choose cases by risk

Probe applicable failure surfaces rather than blindly applying every item:

- Invalid, empty, min/max, just-over-limit, long, and non-Latin input; date/timezone
  boundaries and locale behavior when the feature uses them.
- Wrong role, unauthenticated/expired/revoked access, object/tenant boundaries,
  and stale private data after logout/login or tenant switching.
- Double submission, retry, concurrency, request timeout, lost responses,
  partial success, interrupted flows, and recovery without duplicate side effects.
- Old client/new API, migrated data, missing/extra fields, backward compatibility,
  filters/sorts/pagination, and relevant public URL redirects/404 behavior.
- For a public site, the launch checks in the
  [AI crawler default](project-defaults.md): robots and sitemap on production,
  training bots blocked by name, no answer bot blocked, and every non-production
  environment closed to indexing.
- Responsive/keyboard/assistive interaction, relevant themes/languages, error
  visibility, and deviation from approved designs. Use Design Tester evidence
  where valid without treating it as a functional QA verdict.
- Safe external integrations, dependency outages, observability, recovery, and
  performance against agreed targets. Coordinate security cases with Cybersecurity.

Use seeded synthetic data and mock/sandbox integrations. Do not send real email,
SMS, payments, or production mutations as incidental test side effects. If real
integration verification is necessary, establish authorization and safe scope.

## Supportability requirements

`docs/qa/support/` defines what support must accomplish. For the relevant feature,
specify symptom/evidence collection, correlation IDs, incident impact/severity,
diagnostic visibility, permitted support actions, recovery/retry behavior,
escalation, and verification of restored service. Protect sensitive data and
coordinate role permissions/audit with Cybersecurity.

Technical Lead/DevOps implement the needed logs, runbooks, tools, and recovery
mechanisms in their domains. An actual `/support/` application implements these
requirements; creating it is separate product scope, not automatic QA work.

## Defects and retest

Senior QA supplies findings to QA Lead. The Lead records them in the owning
feature Issue/linked QA record with an ID, steps, expected/actual, environment,
revision, evidence, severity, owner, and status. Bugs do not get new Issues by
default. Use existing project severity definitions; otherwise:

| Severity | Impact |
| --- | --- |
| Blocker | Core acceptance cannot be established, data loss, or a release-stopping risk |
| Major | Significant functionality broken without a reasonable workaround |
| Minor | Limited impact with a viable workaround |
| Trivial | Cosmetic/copy issue with little functional impact |

Technical Lead investigates and reviews a correction; QA retests the original
failure and affected regression. Root-cause assertions need evidence. Retain
failed attempts and disposition in feature history; do not close on "fixed" alone.
Separate flaky/environment failures from product defects without hiding either.

## Final review

Review the delivered revision against QA requirements, measured test coverage,
every AC, relevant regression, and supportability. Evidence identifies artifact/
revision, environment, test/case, actual result, and any limitation. Preserve
passed, failed, blocked, unrun, and reasoned not-applicable distinctions.

QA Lead checks each AC only with actual verification evidence. Open blockers,
unmet mandatory criteria, or an unmet agreed coverage gate prevent a passing
quality verdict. Lower-severity findings receive explicit dispositions based on
their effect on requirements; human risk acceptance does not become test success.
Final evidence and limitations accompany the finished PR. After code changes,
assess which checks/approvals must be refreshed rather than citing stale success.
