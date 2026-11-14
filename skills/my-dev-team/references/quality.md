# Quality, evidence, and supportability

QA Lead owns the strategy, supportability, coverage policy, and final AC review.
Senior QA writes the integration tests, keeps the seed data current, and runs
the assigned verification. Senior Developer writes the unit tests. Design Tester
gives design evidence to Design Lead.

## Before implementation

Map each AC to tests with observable expected outcomes. A case record holds: ID,
AC or rule reference, preconditions, data and role, steps or automation,
expected result, priority and risk, and the environment or enablers needed. Test
authors must know the expected behavior before writing assertions; never derive
it from the implementation.

Keep strategy and cases in the existing QA docs. For a new location,
`docs/qa/{feature-slug}.html` holds cases that span applications;
application-specific details may live with that application. Link them from the
Issue; never start a second task tracker.

Use the [coverage default](project-defaults.md#quality) only when the project
has no policy. State the command, metric, scope, baseline, and exclusions.
Report planned and actually executed coverage separately. Every relevant AC
needs evidence whatever the overall percentage.

## Test-first, and who writes which test

| Test | Written by | From | Approved by |
| --- | --- | --- | --- |
| Unit test | Senior Developer, before the code it tests | The task, `rules.html`, and QA's cases | Technical Lead, in code review |
| Integration test | Senior QA, in parallel with the code | The implementation documents: `api-spec.html`, `data-dict.html`, `flows.html` | QA Lead, before Senior Developer runs it |

An integration test calls the API, then checks the response and the rows written,
changed, or left alone. It runs on a real, migrated, seeded database. Only
third-party services are mocked (`INTEGRATION_<NAME>_MODE=mock`). Never run two
agents against one mutable database.

Senior Developer and Senior QA work at the same time in one worktree. The steps,
file ownership, and lock are in
[Paired Developer/QA worktree](delegation.md#paired-developerqa-worktree).

**A new table or column.** Senior QA writes the integration tests from
`data-dict.html` before the migration exists. They may fail to compile until
Senior Developer has built it; that is expected, and they are run once it is.
If `data-dict.html` or `api-spec.html` lacks a table, column, or operation the
tests need, Senior QA tells QA Lead, who takes it to Technical Lead. Senior QA
never guesses a schema.

**Seed data stays current.** Senior QA owns the seed data the tests use: small,
deterministic, synthetic, with the role accounts the cases need. Before each
test run, Senior QA checks for migration changes and updates the seed first
([order of work](delegation.md#paired-developerqa-worktree)). A test that fails because the seed is stale is a seed
defect, not a product defect.

**When a test and the code disagree,** neither Senior changes the other's work.
Senior QA investigates and sends test defects to QA Lead and code defects to
Senior Developer with reproduction evidence. The two Leads compare both against
the implementation documents: QA corrects a wrong test, Developer corrects
wrong code, and Technical Lead fixes a document gap before dependent work
continues.

## Choose cases by risk

Probe the failure surfaces that apply; do not run every item blindly:

- **Input:** invalid, empty, min/max, just over the limit, long, non-Latin;
  date, time zone, and locale edges when the feature uses them.
- **Access:** wrong role; unauthenticated, expired, or revoked access; object
  and tenant boundaries; stale private data after logout, login, or a tenant
  switch.
- **Timing:** double submit, retry, concurrency, timeout, lost responses,
  partial success, interrupted flows, recovery without duplicate effects.
- **Compatibility:** old client with new API, migrated data, missing or extra
  fields, filters, sorts, pagination, public URL redirects and 404s.
- **Public site:** the launch checks in the
  [AI crawler default](project-defaults.md#ai-crawlers-found-by-ai-answers-not-used-for-training):
  robots and sitemap on production, training bots blocked by name, no answer bot
  blocked, every non-production environment closed to indexing.
- **Interface:** responsive, keyboard, assistive technology, themes, languages,
  error visibility, and deviation from the approved design. Use Design Tester
  evidence where valid; it is not a functional verdict.
- **Operations:** external integrations, dependency outages, observability,
  recovery, performance against agreed targets. Agree security cases with
  Cybersecurity.
- **Bulk data and jobs** ([performance](performance.md)): more rows than one
  batch of 500; a job stopped mid-run continues from its cursor with no row
  processed twice or skipped; a job that passes half its runner's limit hands
  off to a child job; two scheduled runs do not overlap.

Use seeded synthetic data and mock or sandbox integrations. Never send real
email, SMS, payments, or production changes as a side effect of testing. If real
integration testing is needed, get authorization and a safe scope first.

## Supportability requirements

`docs/qa/support/` says what support must be able to do. For each feature,
specify how symptoms and evidence are collected, correlation IDs, incident
severity, diagnostic visibility, allowed support actions, recovery and retry,
escalation, and how restored service is verified. Protect sensitive data, and
agree role permissions and audit with Cybersecurity.

Technical Lead and DevOps build the logs, runbooks, tools, and recovery
mechanisms. A real `/support/` application is separate product scope, not
automatic QA work.

## Defects and retest

Senior QA reports findings to QA Lead, who records each on the feature Issue or
its linked QA record: ID, steps, expected and actual, environment, revision,
evidence, severity, owner, status. Bugs do not get new Issues. Use the project's
severity scale, otherwise:

| Severity | Impact |
| --- | --- |
| Blocker | Core acceptance cannot be established, data loss, or a release-stopping risk |
| Major | Significant function broken with no reasonable workaround |
| Minor | Limited impact with a workaround |
| Trivial | Cosmetic or copy issue with little functional impact |

Technical Lead investigates and reviews the fix; QA retests the original failure
and the affected regression, within the
[review loop limits](contract.md#every-review-loop-is-bounded). A root cause
needs evidence. Keep failed attempts and their outcome in the feature history;
never close on "fixed" alone. Separate flaky or environment failures from
product defects, hiding neither.

## Final review

Review the delivered revision against the QA requirements, measured coverage,
every AC, relevant regression, and supportability. Evidence names the revision,
environment, test or case, actual result, and any limit. Keep passed, failed,
blocked, unrun, and not-applicable separate.

QA Lead ticks each AC only with real evidence. An open blocker, an unmet
mandatory criterion, or an unmet agreed coverage gate prevents a passing verdict.
Lower-severity findings each get an explicit decision; human risk acceptance
never becomes a test pass. With an owning Issue, approval includes
[syncing the AC and DoD checkboxes](../roles/qa-lead.md#sync-the-issue-checkboxes).

Final evidence and limits go with the PR. After any code change, decide which
checks and approvals must be refreshed; never cite stale results.
