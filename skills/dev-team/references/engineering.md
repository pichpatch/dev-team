# Engineering practices

Technical Lead owns decisions and review; Senior Developer owns assigned
implementation. These practices supplement the [team contract](contract.md).

## Technical package and impact

Keep lasting facts in existing domain docs. A useful package links requirement/AC,
approved design, QA plan, security decisions, and affected code. Add only the
sections needed: approach and alternatives, changed interfaces/state/data,
side effects and invariants, compatibility/migration, test enablers, deployment
implications, risks, implementation slices, and expected evidence.

Trace callers/consumers and failure paths before changing a contract. For a bug,
establish an evidenced cause, preferably a failing regression. If reproduction is
impractical, state the limitation and strongest evidence; do not call a hypothesis
confirmed. Independent diagnostic/test work can be delegated without inventing
new roles or Issues.

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
- Choose cache freshness/invalidation by correctness requirements. Scope private
  caches by user/tenant and clear or isolate them across auth/tenant transitions.
  Do not default stale data for permissions, money, or other strict invariants.

## API contracts

Use the existing contract-generation workflow where one exists. For a new typed
API, consider `api:generate` producing `docs/api-spec/openapi.json` and generated
clients such as `app/api/generated/`. Name operations consistently and keep a
shared client for base URL, authentication, and error handling. Never hand-edit
generated files or duplicate request/response shapes that the generator owns.

After a schema/endpoint change, regenerate the API and affected consumers, review
the diff, and run type/contract checks. Generation should be deterministic and
work without production secrets or live services. Document semantics the schema
cannot express, such as authorization, side effects, idempotency, and error meaning.
Identify external consumers before shipping a breaking change.

## Frontend, discovery, and integrations

Use the approved design/UI system and actual state behavior; read
[design practices](design.md). Keep server-state handling and errors consistent,
with relevant loading/empty/retry states. Scale paging, search debounce, and
virtualization to measured data/interaction needs instead of fixed arbitrary limits.

For public web content, implement agreed indexability, meaningful rendered content,
titles/descriptions, canonical links, redirects/status codes, sitemaps, language
alternates, and applicable structured data. Verify current search guidance when
deciding specifics. Nonproduction index controls are not access controls. For AI
crawlers, follow the [AI crawler default](project-defaults.md) and its lists
unless PO recorded an exception: keep the blocked list in one module and never
block an answer bot. Build [search engine submission](project-defaults.md) into
the backend so it needs only credentials, and list its keys in `.env.example`.

Provide a mock/sandbox adapter for external side effects behind the same interface
where needed. Default local/test runs to safe modes; distinguish mock coverage
from real integration coverage. Check exact package identity, source, versions,
advisories and install behavior proportionately before adding dependencies; keep
lockfiles/pins and raise substantive supply-chain concerns to Cybersecurity.
Use established cryptographic libraries/protocols, not bespoke cryptography.

## Verification and review package

Senior Developer owns meaningful unit/integration checks against QA's cases;
QA owns independent feature/E2E verification. Run related checks first, then
required project checks; broaden when impact or unresolved concerns justify it.
Report pre-existing failures separately and preserve exit codes and diagnostic
evidence. A test that matches implementation wording is not behavior evidence.

Return revision, affected artifacts, behavior change, tests and results, doc
updates, compatibility/recovery implications, limitations, and review questions.
Technical Lead inspects the diff and integrated behavior. Changes after approval
must be assessed for invalidated review/test evidence and routed accordingly.
