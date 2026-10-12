# Engineering practices

Technical Lead owns decisions and review; Senior Developer owns assigned
implementation. These practices supplement the [team contract](contract.md).
For a new project, the [standard stack](stack.md) fixes the applications, the
repository layout, the typed API contract, identifiers, and the frontend and
backend conventions.

## Technical package and impact

Write every confirmed technical decision into the affected domain docs: the
approach and why, changed interfaces, state and data, side effects and
invariants, rules with their identifiers, compatibility and migration, test
enablers, deployment implications, and risks. The docs must be complete enough
that an agent can design, build, and review from them without reading the Issue
for technical content. They state the current truth, so update them in place.

The Issue is the ticket. It shows the feature is ready to implement: a short note
that links to those documents and lists the implementation slices. Discussion
happens against the docs, not in the Issue.

Trace callers/consumers and failure paths before changing a contract. For a bug,
establish an evidenced cause, preferably a failing regression. If reproduction is
impractical, state the limitation and strongest evidence; do not call a hypothesis
confirmed. Independent diagnostic/test work can be delegated without inventing
new roles or Issues.

## Rule identifiers

Every rule a module enforces has a stable identifier in three places:

- **The module's document** in the owning application's docs, for example
  `api/docs/modules/orders.html`: `R3: cancelling an order clears refund_deadline`.
  Say which AC the rule comes from when it comes from one.
- **The test that proves it**, in its name: `R3: cancelling clears refund_deadline`.
- **The code that implements it**, as a one-line comment pointing to the rule
  when the code is not obvious: `// R3: see api/docs/modules/orders.html#r3`.

A failing test then names the broken rule, the document explains it, and the
comment shows where it lives. Number rules per module and never renumber or reuse
one. A change without its rule, test, and document updated together is not done.

## Implementation and data

- Follow existing patterns, formatter, and linter. Use clear boundaries, cohesive
  functions/modules, and guard clauses where they clarify behavior. Avoid both
  duplicated business rules and premature abstraction.
- Enforce permissions on the server and validate data at trust boundaries. Keep
  domain side effects with the owning operation; use transactions where the
  invariant requires atomic changes. Define idempotency/retry behavior for
  operations that may be repeated.
- Check data types, constraints, nullability, pagination, query cost, indexes, and
  N+1 risks against actual access patterns. Document destructive changes and
  compatibility with existing clients/data.
- For migrations, establish an explicit recovery strategy: compatible rollback,
  roll-forward, or backup/restore. Do not promise a lossless down migration for
  destructive transformations. DevOps owns operational execution planning.
- Cache with refresh-ahead by default, as the [standard stack](stack.md) says.
  Scope private caches by user/tenant and clear or isolate them across auth/tenant
  transitions. Do not serve stale data for permissions, money, or other strict
  invariants.
- Ask the human how a local database should run before setting one up, and never
  drop, reset, or re-seed a database without the human's explicit OK
  ([standard stack](stack.md)). A Senior sends that question to its Lead.

## API contracts

Use the existing contract-generation workflow where a project has one. Otherwise
follow [one typed contract](stack.md): `yarn generate-openapi` in the API writes
`api/docs/api-spec/openapi.json`, `yarn generate-spec` in `frontend-core`
regenerates the SDK, and web and mobile call the API only through that SDK.

After a schema or endpoint change, run both commands, review the diff, and make
every app compile. Never hand-edit generated files or declare request/response
shapes by hand. Document what the schema cannot express, such as authorization,
side effects, idempotency, and error meaning. Identify external consumers before
shipping a breaking change.

## Frontend, discovery, and integrations

Use the approved design/UI system and actual state behavior; read
[design practices](design.md). Keep server-state handling and errors consistent,
with relevant loading/empty/retry states. Follow the
[shared frontend](stack.md) conventions: TanStack Query on the SDK, the i18n
library for every string, Firebase Remote Config flags, and the list thresholds.

For public web content, implement agreed indexability, meaningful rendered content,
titles/descriptions, canonical links, redirects/status codes, sitemaps, language
alternates, and applicable structured data; for Next.js, follow the
[SEO checklist](stack.md). Verify current search guidance when deciding specifics. Nonproduction index controls are not access controls. For AI
crawlers, follow the [AI crawler default](project-defaults.md) and its lists
unless PO recorded an exception: keep the blocked list in one module and never
block an answer bot. Build [search engine submission](project-defaults.md) into
the backend so it needs only credentials, and list its keys in `.env.example`.

Give every third-party integration a mock behind the same interface, switched by
`INTEGRATION_<NAME>_MODE=mock|real`. Default local/test runs to `mock`; distinguish mock coverage
from real integration coverage. Check exact package identity, source, versions,
advisories and install behavior proportionately before adding dependencies; keep
lockfiles/pins and raise substantive supply-chain concerns to Cybersecurity.
Use established cryptographic libraries/protocols, not bespoke cryptography. The
supplied `ref_id` module in the [standard stack](stack.md) is the one approved
exception; use it as supplied.

## Verification and review package

Senior Developer owns meaningful unit/integration checks against QA's cases;
QA owns independent feature/E2E verification. Run related checks first, then
required project checks; broaden when impact or unresolved concerns justify it.
Before editing code that no test covers, first add a test that locks today's
behavior. Report pre-existing failures separately and preserve exit codes and
diagnostic evidence. A test that matches implementation wording is not behavior evidence.

Return revision, affected artifacts, behavior change, tests and results, doc
updates, compatibility/recovery implications, limitations, and review questions.
Technical Lead inspects the diff and integrated behavior. Changes after approval
must be assessed for invalidated review/test evidence and routed accordingly.
