# Engineering practices

Technical Lead owns decisions and review; Senior Developer owns assigned
implementation. These practices supplement the [team contract](contract.md).
For a new project, the [standard stack](stack.md) fixes the applications, the
repository layout, the typed API contract, identifiers, and the frontend and
backend conventions.

## Technical package and impact

Find your way through the documents, not the code: follow
[navigate by documents](records.md) before opening any file.

Write every confirmed technical decision into the affected domain docs: the
approach and why, changed interfaces, state and data, side effects and
invariants, rules with their identifiers, compatibility and migration, test
enablers, deployment implications, and risks. The docs must be complete enough
that an agent can design, build, and review from them without reading the Issue
for technical content. They state the current truth, so update them in place.

The Issue is the ticket. Technical Lead posts an implementation note on it: a
short note that links to those documents and lists the implementation slices. Discussion
happens against the docs, not in the Issue.

Trace callers/consumers and failure paths before changing a contract. For a bug,
establish an evidenced cause, preferably a failing regression. If reproduction is
impractical, state the limitation and strongest evidence; do not call a hypothesis
confirmed. Independent diagnostic/test work can be delegated without inventing
new roles or Issues.

## Module documents and rule identifiers

Each module has a docs folder named like its code folder, for example
`api/docs/modules/orders/` for the code in `api/app/modules/orders/`. The names
match, so the documents are found from the code and the code from the documents.
The folder holds a `README.md` index and one document per subject:

```text
api/docs/modules/orders/
  README.md           purpose and index
  rules.html
  flows.html
  data-dict.html
  permissions.html
  api-spec.html
  code-map.html
  tech-debt.html
```

| File | Holds | Section ids |
| --- | --- | --- |
| `README.md` | One line on what the module is for, then a table linking each file with one line on what it answers | |
| `rules.html` | Each rule and invariant with its identifier (`R1`, `R2`, ...) and the AC it comes from, grouped by who it applies to | one per group (`#admin`, `#user`) and one per rule (`#r3`) |
| `flows.html` | Allowed state transitions; every side effect; on the frontend, the global state the module uses | one per flow (`#refund`), plus `#side-effects` and `#global-state` |
| `data-dict.html` | Tables and fields with their meaning, constraints, and sensitivity | one per table (`#order-items`) |
| `permissions.html` | Who may do what, and ownership conditions | one per role (`#admin`) |
| `api-spec.html` | What each operation means beyond the generated spec: purpose, rules applied, permissions, side effects, errors | one per operation, its `operationId` in kebab-case (`#refund-order`) |
| `code-map.html` | The files that implement the module and its tests, one line each on what the file does | `#files`, `#tests` |
| `tech-debt.html` | Known debt: what it is, what it risks, what fixing takes, and its Issue | one per severity (`#critical`, `#high`, `#medium`, `#low`) |

`README.md`, `rules.html`, and `code-map.html` exist for every module. Create each
other file only when it has content, and list in the `README.md` only the files
that exist; a file missing from the index means there is nothing to say. A
frontend module follows the same shape with the files it needs, for example
`screens.html` and `routes.html` in place of `data-dict.html` and `api-spec.html`.
Why the module is built this way belongs in the application's `docs/decisions/`,
linked from the module's `README.md`.

The module `README.md` is the only file an agent always reads; from it the agent
opens the one or two documents its task needs:

```markdown
# Orders

Takes a customer's order from cart to delivered or refunded.

| Document | Answers |
| --- | --- |
| [Rules](rules.html) | What must always be true, per actor |
| [Flows](flows.html) | Order states and what each transition changes |
| [Data](data-dict.html) | Tables and fields |
| [Permissions](permissions.html) | Who may do what |
| [API](api-spec.html) | What each operation means |
| [Code map](code-map.html) | Which files and tests implement it |
| [Tech debt](tech-debt.html) | Known shortcuts and their risk |
```

`api-spec.html` never repeats request or response shapes; those are generated
into `openapi.json`, and a second copy would drift. It says what the shapes
cannot: why the operation exists and which rules it applies. Each section's id
is the `operationId` in kebab-case, and its heading shows the exact
`operationId`, method, and path, for example
`<h2 id="refund-order">refundOrder: POST /orders/{id}/refund</h2>`, so searching
for the name finds the operation in the document, the generated spec, and the
SDK.

Every side effect and every use of global state is written in the module's
`flows.html`, because neither is visible from the code that triggers it:

- **`#side-effects`:** one row per effect: what triggers it, what else changes,
  where it runs (repository, service, workflow, action hook, or `subscribe`), and the
  rule it implements. Backend example: "Unbind Google → `google_refresh_token`
  cleared (userRepository); Google Drive permission removed (AccountService)".
- **`#global-state`,** in a frontend module: one row per global store or Context
  the module reads or writes: what it holds, who changes it, and what updates
  by itself when it changes. Example: "Wallet store: balance. Changed by top-up
  and checkout. Every price shown on the cart and checkout screens recalculates
  automatically." List each `subscribe` here with what it does.

Add or change the row in the same change as the code. A side effect or a global
state dependency that is not in the document is a review finding.

Keep the code map current: a file added, moved, or removed updates it in the same
change. It is what lets the next agent open three files instead of searching
thirty.

Record in `tech-debt.html` any shortcut you knowingly leave and any debt you
find. Technical Lead sets the severity: `critical` can cause wrong results, data
loss, or a security exposure; `high` makes the next changes to the module unsafe
or slow; `medium` and `low` are the rest. Remove an entry in the change that
fixes it.

Every rule has its identifier in three places:

- **The module's `rules.html`:** `R3: cancelling an order clears refund_deadline`.
- **The test that proves it**, in its name: `R3: cancelling clears refund_deadline`.
- **The code that implements it**, as a one-line comment pointing to the rule
  when the code is not obvious:
  `// R3: see api/docs/modules/orders/rules.html#r3`.

A failing test then names the broken rule, the document explains it, and the
comment shows where it lives. Number rules per module and never renumber or reuse
one; outside the module, cite it as `orders#R3`. A change without its rule, test,
and document updated together is not done.

## Implementation and data

- Follow existing patterns, formatter, and linter. Use clear boundaries and
  cohesive functions/modules.
- Keep production source lines to 150 characters or fewer. Generated code,
  vendor files, URLs, hashes, and values that cannot sensibly be broken are
  exceptions; do not use an exception to keep ordinary source lines long.
- Keep source files at or below 2,000 lines, with generated and vendor files
  excepted. Treat 2,000 as a ceiling, not a target: split files by responsibility
  well before reaching it. Each file has one primary responsibility. A service
  domain may span multiple focused files; for example, `userService.ts`,
  `userCache.ts`, `helpers/user.ts`, and `types/user.ts` can live within the user
  service domain. Give each concern its narrowest sensible ownership.
- **Fail case first.** Handle invalid input, missing permission, and edge cases
  at the top of a function with guard clauses and early returns. The happy path
  comes last and is not nested inside `if`/`else`.
- **Do not duplicate code.** Before writing a function, component, query, or
  rule, look for one that already does it: the module's `code-map.html`, the
  shared library, and `frontend-core`. Reuse it, or extend it when the change is
  small. Copying code needs Technical Lead's decision. Do not build an
  abstraction for a single use either.
- Put genuinely shared helpers, types, and code in an explicit shared location
  such as `/lib`, `/helper`, or a shared package, following repository
  conventions. Do not place shared code inside one page or service and make
  unrelated pages or domains import that internal implementation.
- **Comment usefully.** Every exported function, class, component, and module
  gets a short comment saying what it is for. Inside the code, comment why: the
  rule identifier, a non-obvious constraint, a workaround and its cause, a
  performance choice and its evidence. Never restate what the code already says,
  and update a comment in the change that makes it untrue.
- Enforce permissions on the server and validate data at trust boundaries. Put
  each side effect at its level: a repository keeps its own record consistent;
  services own their domain's business logic and data access; a workflow layer
  coordinates business operations across services ([backend layers](stack.md)).
- Treat each backend service domain as a microservice boundary, even in a
  modular monolith. Keep its interfaces and dependencies clear enough that it
  can be extracted as a service without redesigning its business logic.
- Give each repository/table exactly one owning service. Other services must
  not import that service's repository or directly query its tables; use the
  owning service's interface or an approved cross-service communication path.
- Put cross-service workflows in a controller, workflow, or orchestrator layer,
  rather than having one service directly orchestrate another. A reusable flow
  can be an explicit workflow module with parameters. Where appropriate, use
  the existing queue/event mechanism for one-way communication. Kafka is not
  currently part of the stack: do not introduce it automatically; discuss it
  with the Technical Lead when requirements justify considering it.
- Keep frontend and backend application logic horizontally scalable and
  stateless: correctness must not depend on process-local memory. Disposable
  local caches and other performance optimizations are fine when losing them
  does not change correctness.
- **Multi-table/repository write integrity (hard rule):** before implementing
  any business workflow that creates, updates, or deletes data in more than one
  table/repository, define its failure and rollback/recovery behavior. Treat
  transaction scope as the whole business operation, not a set of nearby
  queries. Identify required dependent writes separately from optional side
  effects such as analytics or notifications. A required write failure must
  roll back or compensate the operation; optional side effects should normally
  retry without undoing completed core business work.
- When all required writes share one safe database transaction boundary, prefer
  a database transaction so they commit or roll back atomically. Do not use
  compensation when a normal database transaction can safely provide
  atomicity. When required writes cross services or independent transaction
  boundaries, coordinate them through the workflow/orchestrator and use
  explicit saga-style compensation or recovery; do not imply that a distributed
  database transaction exists. For example, if checkout deducts a user's
  balance and later order creation or processing fails, the workflow must
  reverse/compensate the deduction or record and recover the incomplete work.
- Track which workflow steps succeeded. Make compensation idempotent where
  practical, never swallow a partial failure or report success, and include
  workflow and compensation identifiers in logs. Compensation is not always a
  delete: it may reverse a balance transaction, cancel or mark a record failed,
  restore prior state, delete a newly created record, or enqueue compensation.
  If compensation fails, durably record the recovery need and retry or escalate
  it; never claim rollback succeeded when it did not. Define idempotency and
  retry behavior for operations that may be repeated.
- Example: creating a Website and its required initial BlogOffer is
  one business operation. If both writes share a safe transaction boundary,
  roll back the Website when BlogOffer creation fails. If they are owned by
  separate services/transaction boundaries, orchestrate `WebsiteService` and
  `BlogOfferService` and safely compensate or recover the Website creation if
  the required BlogOffer step fails.
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
- Select only the columns the view uses, never `SELECT *`, and return a lean
  payload. Use `VARCHAR(n)` with a known maximum for bounded values such as a
  status or a name; keep `TEXT` for free-form descriptions.
- Agree rate limits and IP allowlists with DevOps and PO, within what
  Cybersecurity requires; the edge handles the rest. Build and run a load test
  with DevOps when the human asks for one.
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
- Give each route-, screen-, or endpoint-specific UI its own entry/module/file.
  Small presentation or layout duplication is acceptable when it keeps local
  code clear, easy to debug, and within the file-size guidance. Do not duplicate
  business, security, or state logic.
- Every page must initialize independently from authentication context and its
  route parameters. It may reuse valid application state or cache according to
  the cache rules, but must not depend on the user navigating through another
  page first.

For public web content, implement agreed indexability, meaningful rendered content,
titles/descriptions, canonical links, redirects/status codes, sitemaps, language
alternates, and applicable structured data; for Next.js, follow the
[SEO checklist](stack.md). Verify current search guidance when deciding
specifics. Nonproduction index controls are not access controls. For AI
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

### Read only results and errors

Test runs, builds, linters, and installs print mostly lines about things that
went fine. Reading them costs tokens and hides the one line that matters.

- **Find the related tests first.** Before editing, run the tests connected to
  the files you will change, and the type checker, which lists every caller of
  a changed signature. They must pass before you start; report any that already
  fail. Run the full suite once before returning the work.

  | Stack | Related tests | Types |
  | --- | --- | --- |
  | Vitest | `vitest related <files> --run` | `tsc --noEmit --pretty false` |
  | Jest | `jest --findRelatedTests <files>` | `tsc --noEmit --pretty false` |
  | pytest | `pytest <module tests>` | `mypy <paths>` |
  | .NET | `dotnet test --filter "FullyQualifiedName~<Area>"` | `dotnet build -v q` |

- **Keep the exit code.** Never pipe a command straight into `tail`, `grep`, or
  `head`: the pipe hides a failure. Save the output to a log, print the exit
  code, then read the end of the log:

  ```bash
  log=$(mktemp); npx vitest related src/orders/order.repository.ts --run --reporter=dot > "$log" 2>&1
  echo "exit=$?"; tail -n 25 "$log"
  ```

- **Failures in full, passes as a count.** To fix a failure you need the test
  name, expected and actual, and the first lines of the stack trace. Read only
  the failing part of the saved log; do not re-run everything with full output.
- **Use each tool's quiet mode** instead of cutting output blindly:
  `vitest run --reporter=dot`, `jest --silent`, `pytest -q --tb=short`,
  `eslint --quiet`, `npm ci --loglevel=error --no-audit --no-fund`,
  `poetry install -q`, `dotnet build -v q`.
- **Sort every failure after your change:** a bug you caused, so fix the code;
  or an intended change, so update the test and the rule in the module document
  together and tell QA. Never edit a test only to make it pass.
- Put the summary and the failures in a return or a PR, never a full log.

Return revision, affected artifacts, behavior change, tests and results, doc
updates, compatibility/recovery implications, limitations, and review questions.
Say what the tests prove and why the change resolves the task, and list the
documents updated. Label a change that includes refactoring `refactor` and ask
QA Lead to regression-test the affected parts.
Technical Lead inspects the diff and integrated behavior. Changes after approval
must be assessed for invalidated review/test evidence and routed accordingly.
