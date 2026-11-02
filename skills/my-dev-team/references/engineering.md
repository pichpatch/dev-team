# Engineering practices

Technical Lead owns technical decisions and review; Senior Developer owns
assigned implementation. These practices add to the [contract](contract.md). For
a new project, the [standard stack](stack.md) fixes the applications, layout,
typed API contract, identifiers, and frontend and backend conventions.

## Technical package and impact

Find your way through documents, not code
([navigate by documents](records.md#navigate-by-documents-not-by-code)).

- **Write every confirmed decision into the affected domain docs:** the approach
  and why, changed interfaces, state and data, side effects and invariants,
  rules with IDs, compatibility and migration, test enablers, deployment
  effects, and risks. An agent must be able to design, build, and review from
  the docs without reading the Issue. Update them in place.
- **The Issue is the ticket.** Technical Lead posts a short implementation note:
  links to those docs and the list of implementation slices. Discussion happens
  against the docs.
- **Before changing a contract,** trace its callers, consumers, and failure
  paths.
- **For a bug,** establish the cause with evidence, ideally a failing regression
  test. If reproduction is impractical, state why and give the strongest
  evidence; a hypothesis is never "confirmed". Diagnostic work can be delegated
  without new roles or Issues.

## Module documents and rule identifiers

Each module has a docs folder named like its code folder, for example
`api/docs/modules/orders/` for `api/app/modules/orders/`, so each is found from
the other. It holds a `README.md` index and one document per subject:

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
| `README.md` | One line on the module's purpose, then a table linking each file with what it answers | |
| `rules.html` | Each rule and invariant with its ID (`R1`, `R2`, ...) and source AC, grouped by who it applies to | one per group (`#admin`, `#user`) and per rule (`#r3`) |
| `flows.html` | Allowed state transitions; every side effect; the services: which entry point to call for what, what it handles for the caller (session checks, caching with its key, lifetime, and invalidation); on the frontend, the global state the module uses | one per flow (`#refund`), plus `#services`, `#side-effects`, and `#global-state` |
| `data-dict.html` | Tables and fields: meaning, constraints, sensitivity | one per table (`#order-items`) |
| `permissions.html` | Who may do what, and ownership conditions | one per role (`#admin`) |
| `api-spec.html` | What each operation means beyond the generated spec: purpose, rules, permissions, side effects, errors | one per operation, its `operationId` in kebab-case (`#refund-order`) |
| `code-map.html` | Each file with its main functions, one line each, and the unit and integration test files | `#files`, `#tests` |
| `tech-debt.html` | Known debt: what, the risk, the fix, its Issue | one per severity (`#critical`, `#high`, `#medium`, `#low`) |

- `README.md`, `rules.html`, and `code-map.html` exist for every module. Create
  the others only when they have content, and index only files that exist.
- A frontend module uses the files it needs, for example `screens.html` and
  `routes.html` instead of `data-dict.html` and `api-spec.html`.
- Why the module is built this way goes in the application's `docs/decisions/`,
  linked from the module `README.md`.

The module `README.md` is the one file an agent always reads; from it the agent
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

**`api-spec.html`** never repeats request or response shapes; those are
generated into `openapi.json`, and a copy would drift. It says why the operation
exists and which rules it applies. Each heading shows the exact `operationId`,
method, and path, for example
`<h2 id="refund-order">refundOrder: POST /orders/{id}/refund</h2>`, so one search
finds it in the document, the spec, and the SDK.

**`flows.html`** records every side effect and every use of global state,
because neither is visible from the code that triggers it:

- **`#side-effects`:** one row per effect: trigger, what else changes, where it
  runs (repository, service, workflow, action hook, or `subscribe`), and the
  rule. Example: "Unbind Google → `google_refresh_token` cleared
  (userRepository); Google Drive permission removed (AccountService)".
- **`#global-state`** (frontend): one row per global store or Context the module
  reads or writes: what it holds, who changes it, what updates automatically.
  Example: "Wallet store: balance. Changed by top-up and checkout. Every price on
  the cart and checkout screens recalculates." List each `subscribe` here.

Change the row in the same change as the code. A side effect or global-state
dependency missing from the document is a review finding.

**`code-map.html`** changes in the same change as any file added, moved, or
removed. It lets the next agent open three files instead of searching thirty.

**`tech-debt.html`** records any shortcut you leave and any debt you find.
Technical Lead sets severity: `critical` can cause wrong results, data loss, or
security exposure; `high` makes the next changes unsafe or slow; `medium` and
`low` are the rest. Remove an entry in the change that fixes it.

**Every rule's ID appears in three places:**

- the module's `rules.html`: `R3: cancelling an order clears refund_deadline`;
- the test that proves it: `R3: cancelling clears refund_deadline`;
- the code, as a one-line comment where it is not obvious:
  `// R3: see api/docs/modules/orders/rules.html#r3`.

A failing test then names the broken rule, the document explains it, and the
comment shows where it lives. Number rules per module; never renumber or reuse.
Outside the module, cite `orders#R3`. A change is not done until rule, test, and
document change together.

## Implementation and data

**Code shape**

- Follow existing patterns, formatter, and linter, with clear boundaries.
- Production lines at most 150 characters. Exceptions: generated or vendor code,
  URLs, hashes, values that cannot sensibly be broken; never ordinary code.
- Source files at most 2,000 lines (generated and vendor excepted). It is a
  ceiling, not a target: split by responsibility well before it. One primary
  responsibility per file; a service domain may span focused files
  (`userService.ts`, `userCache.ts`, `helpers/user.ts`, `types/user.ts`).
- **Fail case first.** Handle invalid input, missing permission, and edge cases
  at the top with guard clauses and early returns. The happy path comes last,
  not nested in `if`/`else`.
- **Do not duplicate code.** Before writing a function, component, query, or
  rule, look in the module's `code-map.html`, the shared library, and
  `frontend-core`. Reuse it, or extend it when the change is small. Copying needs
  Technical Lead's decision. Do not build an abstraction for a single use.
- Put truly shared helpers, types, and code in an explicit shared place (`/lib`,
  `/helper`, a shared package). Never make unrelated code import another page's
  or service's internals.
- **Comment every function and method,** so an agent can understand it without
  reading its callers or its body:
  - what it does, in one or two lines;
  - its side effects: what it writes, sends, caches, or invalidates, or "none";
  - its unit test file.

  ```ts
  /**
   * Refunds a paid order and restores the stock.
   * Side effects: writes refunds and order_items; clears the order cache.
   * Unit tests: src/orders/refund.service.spec.ts
   */
  ```

  Inside, comment the why: the rule ID, a hidden constraint, a workaround and
  its cause, a performance choice and its evidence. Never restate the code;
  update a comment in the change that makes it untrue.

**Backend boundaries**

- Enforce permissions on the server and validate data at trust boundaries.
- Each side effect at its level: a repository keeps its own record consistent;
  a service owns its domain's logic and data; a workflow layer coordinates
  operations across services ([backend](stack.md#backend)).
- Treat each service domain as a microservice boundary, even in a modular
  monolith, so it could be extracted without redesign.
- Each repository/table has exactly one owning service. Other services never
  import that repository or query its tables; they use its interface or an
  approved cross-service path.
- Cross-service workflows live in a controller, workflow, or orchestrator layer,
  never one service orchestrating another. A reusable flow can be a workflow
  module with parameters. Use the existing queue or events for one-way messages.
  Kafka is not in the stack: never add it on your own; raise it with Technical
  Lead when requirements justify it.
- Application logic is stateless and horizontally scalable: correctness never
  depends on process memory. Disposable local caches are fine when losing them
  changes nothing.

**Writes across several tables (hard rule)**

- Before building any business operation that writes to more than one table or
  repository, define its failure and rollback or recovery. The transaction scope
  is the whole business operation. Separate required writes from optional side
  effects (analytics, notifications): a required write failing must roll back or
  compensate; optional effects retry without undoing the core work.
- When all required writes share one safe database transaction, use it. Do not
  use compensation when a normal transaction works.
- When writes cross services or transaction boundaries, coordinate them in the
  workflow layer with explicit saga-style compensation or recovery; never imply
  a distributed transaction exists. Example: if checkout deducts a balance and
  order creation then fails, the workflow reverses the deduction or records and
  recovers the incomplete work.
- Track which steps succeeded. Make compensation idempotent where practical.
  Never swallow a partial failure or report success. Log workflow and
  compensation IDs. Compensation is not always a delete: it may reverse a
  balance, mark a record failed, restore state, delete a new record, or enqueue
  compensation. If compensation fails, record the recovery need durably and
  retry or escalate; never claim a rollback that did not happen. Define
  idempotency and retries for repeatable operations.
- Example: a Website and its required initial BlogOffer are one operation. In
  one transaction, roll back the Website if BlogOffer fails. Across services,
  orchestrate `WebsiteService` and `BlogOfferService` and compensate or recover
  the Website.

**Data**

- Check types, constraints, nullability, pagination, query cost, indexes, and
  N+1 risks against real access patterns. Document destructive changes and
  compatibility with existing clients and data.
- Migrations have an explicit recovery strategy: compatible rollback,
  roll-forward, or backup and restore. Never promise a lossless down migration
  for a destructive change. DevOps plans the operational run.
- Cache refresh-ahead by default ([stack](stack.md#backend)). Scope private
  caches by user or tenant and clear them across auth or tenant changes. Never
  serve stale data for permissions, money, or other strict invariants.
- Select only the columns the view uses, never `SELECT *`; return lean payloads.
  Use `VARCHAR(n)` for bounded values (status, name); `TEXT` for free text.
- Agree rate limits and IP allowlists with DevOps and PO, within Cybersecurity's
  requirements; the edge handles the rest. Build and run a load test with DevOps
  when the human asks.
- Ask the human how a local database should run before setting one up, and never
  drop, reset, or re-seed a database without the human's explicit OK
  ([stack](stack.md#backend)). A Senior sends that question to its Lead.

## API contracts

Use the project's existing contract-generation workflow. Otherwise follow
[one typed contract](stack.md#one-typed-contract-end-to-end):

- `yarn generate-openapi` in the API writes `api/docs/api-spec/openapi.json`;
- `yarn generate-spec` in `frontend-core` regenerates the SDK;
- web and mobile call the API only through that SDK.

After a schema or endpoint change, run both commands, review the diff, and make
every app compile. Never hand-edit generated files or hand-write request or
response shapes. Document what the schema cannot say: authorization, side
effects, idempotency, error meaning. Identify external consumers before shipping
a breaking change.

## Frontend, discovery, and integrations

- Use the approved design and UI system and real state behavior
  ([design practices](design.md)). Keep server-state handling and errors
  consistent, with loading, empty, and retry states. Follow the
  [shared frontend](stack.md#shared-frontend) rules: TanStack Query on the SDK,
  i18n for every string, Firebase Remote Config flags, the list thresholds.
- Give each route, screen, or endpoint its own entry, module, or file. Small
  presentation duplication is fine when it keeps local code clear and within
  file limits; never duplicate business, security, or state logic.
- Every page initializes on its own from the auth context and route parameters.
  It may reuse valid state or cache, but never depends on the user visiting
  another page first.
- **Public web content:** implement agreed indexability, meaningful rendered
  content, titles and descriptions, canonical links, redirects and status codes,
  sitemaps, language alternates, and structured data; for Next.js follow the
  [SEO checklist](stack.md#nextjs-seo-checklist). Check current search guidance.
  Non-production index controls are not access controls.
- **AI crawlers:** follow the
  [AI crawler default](project-defaults.md#ai-crawlers-found-by-ai-answers-not-used-for-training)
  unless PO recorded an exception: one module for the blocked list, never block
  an answer bot. Build [search engine submission](project-defaults.md#search-engine-submission)
  into the backend so it needs only credentials, with its keys in `.env.example`.
- **Integrations:** every third party has a mock behind the same interface,
  switched by `INTEGRATION_<NAME>_MODE=mock|real`, `mock` by default locally and
  in tests. Report mock and real integration coverage separately.
- **Dependencies:** check package identity, source, versions, advisories, and
  install behavior before adding one; pin exact versions and install from the
  lockfile ([dependencies](stack.md#dependencies)). Raise supply-chain concerns
  to Cybersecurity.
- Use established cryptographic libraries, never home-made cryptography. The
  supplied `ref_id` module ([stack](stack.md#identifiers-and-public-urls)) is the
  one approved exception; use it as supplied.

## Verification and review package

- Senior Developer writes the unit tests, test-first; Senior QA writes the
  integration tests and keeps the seed data current
  ([test-first](quality.md#test-first-and-who-writes-which-test)).
- Run related checks first, then the project's required checks; widen when the
  impact or open concerns justify it.
- Before editing code no test covers, first add a test that locks today's
  behavior.
- Report failures that already existed separately; keep exit codes and
  diagnostics. A test that just mirrors the implementation is not evidence.

**Security hardening:** first state the security invariant, the untrusted inputs
and transformations, the affected storage and output boundaries, and the
regression cases that must stay blocked. If several representations bypass one
guard, stop adding one-off patches: revisit canonicalization and enforcement at
the owning boundary with Technical Lead and Cybersecurity, and put all the found
variants in one focused regression suite.

### Read only results and errors

Test runs, builds, linters, and installs mostly print lines about things that
went fine. Reading them wastes tokens and hides the line that matters.

- **Find the related tests first.** Before editing, run the tests connected to
  the files you will change, plus the type checker (it lists every caller of a
  changed signature). They must pass before you start; report any that already
  fail. Iterate on focused and related tests. The full suite runs once, at the
  final integrated verification, after the change settles. Extra full runs need
  a stated reason: project or QA policy, broad impact, open risk, invalidated
  evidence, or a failure investigation.

  | Stack | Related tests | Types |
  | --- | --- | --- |
  | Vitest | `vitest related <files> --run` | `tsc --noEmit --pretty false` |
  | Jest | `jest --findRelatedTests <files>` | `tsc --noEmit --pretty false` |
  | pytest | `pytest <module tests>` | `mypy <paths>` |
  | .NET | `dotnet test --filter "FullyQualifiedName~<Area>"` | `dotnet build -v q` |

- **Keep the exit code.** Never pipe a command straight into `tail`, `grep`, or
  `head`; the pipe hides failure. Save the output, print the exit code, then read
  the end of the log:

  ```bash
  log=$(mktemp .test-log.XXXXXX)
  trap 'rm -f "$log"' EXIT
  if npx vitest related src/orders/order.repository.ts --run --reporter=dot > "$log" 2>&1; then
    status=0
  else
    status=$?
  fi
  echo "exit=$status"; tail -n 25 "$log"
  exit "$status"
  ```

- **Failures in full, passes as a count.** To fix a failure you need the test
  name, expected and actual, and the first stack lines. Read only the failing
  part of the saved log; never re-run everything with full output.
- **Use each tool's quiet mode** instead of cutting output blindly:
  `vitest run --reporter=dot`, `jest --silent`, `pytest -q --tb=short`,
  `eslint --quiet`, `npm ci --loglevel=error --no-audit --no-fund`,
  `poetry install -q`, `dotnet build -v q`.
- **Sort every failure after your change:** a bug you caused (fix the code), or
  an intended change (update the test and the rule document together, and tell
  QA). Never edit a test only to make it pass.
- Put the summary and failures in your return or the PR, never a full log.

**Return package:** revision, affected artifacts, behavior change, tests and
results, doc updates, compatibility and recovery effects, limits, and review
questions. Say what the tests prove and why the change solves the task, and list
the documents updated. Label a change with refactoring `refactor` and ask QA
Lead to regression-test the affected parts.

Technical Lead inspects the diff and integrated behavior. After a correction,
re-review the changed scope and any evidence it may invalidate, not unchanged
work. Any change after approval is checked for invalidated review or test
evidence and routed accordingly.
