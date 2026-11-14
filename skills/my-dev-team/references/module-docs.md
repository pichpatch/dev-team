# Module documents and rule identifiers

What each module document holds. Technical Lead owns and writes them
([who owns what](doc-map.md#who-owns-what)); everyone else reads the one section
a task needs.

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

Senior Developer reports each new or changed row in its return; Technical Lead
writes it before approving, so the row and the code merge together. A side
effect or global-state dependency missing from the document is a review finding.

**`code-map.html`** changes in the same change as any file added, moved, or
removed. Senior Developer keeps its rows: path, function, and one line copied
from the function's comment. It lets the next agent open three files instead of
searching thirty.

**`tech-debt.html`** records every shortcut left and every debt found. Senior
Developer reports them; Technical Lead writes the entry and sets severity: `critical` can cause wrong results, data loss, or
security exposure; `high` makes the next changes unsafe or slow; `medium` and
`low` are the rest. Remove an entry in the change that fixes it.

**Every rule's ID appears in three places:**

- the module's `rules.html`: `R3: cancelling an order clears refund_deadline`;
- the test that proves it: `R3: cancelling clears refund_deadline`;
- the code, as a one-line comment where it is not obvious:
  `// R3: see api/docs/modules/orders/rules.html#r3`.

A failing test then names the broken rule, the document explains it, and the
comment shows where it lives. Technical Lead numbers rules per module and never
renumbers or reuses one; Senior Developer puts the ID in the test and the code.
Outside the module, cite `orders#R3`. A change is not done until rule, test, and
document change together.
