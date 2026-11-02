# Persistent records

## Repository truth

Root `docs/` holds project-wide truth; each application's `docs/` holds what is
specific to it. When a fact changes, update the document that owns it.

A document states only the current truth. No dated copies, archived versions,
superseded text, or change logs inside it: older versions come from git history,
and the reason for a change is on the owning Issue.

### HTML documents, README indexes

- **Every project document is HTML:** requirements, decisions, module and
  architecture docs, QA cases, support and security records, runbooks,
  evaluations. Start from [the document template](../assets/document.html).
  Plain semantic HTML only: no inline styles or scripts.
- **One stylesheet,** [docs.css](../assets/docs.css), copied once to
  `docs/assets/docs.css`.
- **Every section heading has a short, stable kebab-case `id`,** even when named
  after code: table `order_items` is `#order-items`, operation `refundOrder` is
  `#refund-order`.
- **Point at the section, not just the file,** everywhere (replies, packets,
  Issues, PRs, other documents): `api/docs/modules/orders/rules.html#admin`.
  Renaming an `id` breaks links, so rename only together with every link to it.
- **`README.md` files are the index and the map.** Every document and module is
  reachable from the root `README.md` by links. Whoever adds, renames, or
  removes a document or module updates the `README.md` that lists it in the same
  change; anything no `README.md` reaches is unpublished. Use relative links.
- Besides these READMEs, the only Markdown the team writes is under `.AI/`
  ([pause and resume](checkpoints.md)).

The root `README.md` maps the applications and lists root documents:

```markdown
# Alpha Food

One line on what the product is.

## Applications

| Application | What it is | Stack | Start here |
| --- | --- | --- | --- |
| API | One backend for every client | NestJS | [api](api/README.md) |
| Customer mobile | Ordering app for customers | React Native | [frontend_domain_1](frontend_domain_1/README.md) |
| Customer web | Public ordering site | Next.js | [web/frontend_domain_1](web/frontend_domain_1/README.md) |
| Frontend core | Shared tokens, components, logic, SDK | Library | [frontend-core](frontend-core/README.md) |

## Documents

| Document | Purpose | Owner |
| --- | --- | --- |
| [Business requirements](docs/requirements/business-requirements.html) | Agreed scope, rules, and AC sources | PO |
```

Each application's `README.md` gives its commands, its modules with where their
documents and code are, and its other documents:

```markdown
# API

One backend for every client. NestJS, PostgreSQL, Redis.

## Run, test, generate

| Task | Command |
| --- | --- |
| Start | `yarn start:dev` |
| Test | `yarn test` |
| Generate the API spec | `yarn generate-openapi` |

Environment keys are listed in `.env.example`; never write values here.

## Modules

| Module | Documents | Code | Tests |
| --- | --- | --- | --- |
| orders | [orders](docs/modules/orders/README.md) | `app/modules/orders/` | `app/modules/orders/*.spec.ts` |

## Documents

| Document | Purpose | Owner |
| --- | --- | --- |
| [Architecture](docs/architecture.html) | Module map and rules that cross modules | Technical Lead |
```

### Navigate by documents, not by code

Agents have no memory of the code, and searching it is the most expensive thing
they do. Reach the right files in a few reads:

1. **Task packet:** the Issue, the worktree, the documents to start from.
2. **Issue:** purpose, AC, status, history. Not how anything works.
3. **Root `README.md`:** follow one application link.
4. **Application `README.md`:** commands, and where each module's docs and code
   are.
5. **Module `README.md`:** what the module is for, and its documents.
6. **Only the module documents and sections the task needs.**
   - `code-map.html`: the file and the function.
   - `flows.html` and `api-spec.html`: the service to call and its caching
     rules, the flows, and what each operation means.
   - `data-dict.html`: the tables and columns.
7. **Only the function the code map names.** Its comment says what it does, its
   side effects, and its unit test file; open that test only when the task
   needs it.
8. **The `.AI/` checkpoint,** only when resuming.

- Read only your path; skip other modules and applications unless the change
  crosses into them.
- Never read generated files (`openapi.json`, the SDK), lockfiles, or build
  output to learn the system. Search them for one name when needed.
- Search code only when the documents do not answer, then fix the document in
  the same change. When a document contradicts the code, trust the code, fix the
  document, and say so.
- Write for the next reader: one opening line on what the document covers, each
  fact once at the lowest level where it is true, links instead of repeats.

Each module has one folder with one document per subject: rules, flows, data,
permissions, API meaning, code map, debt ([engineering](engineering.md)).
Documents outside modules cover only what spans them: architecture and
decisions.

Not project documents, and they keep their own formats: Issue and PR text, task
packets, generated files such as `openapi.json`, diagram and mockup assets.

A project with existing non-HTML docs keeps them and lists them in the index as
they are; new documents are HTML. Converting is a migration the human agrees
first. Never keep the same truth in two formats.

Example locations in the [standard layout](stack.md); create a folder only when
a real deliverable needs it. `frontend_domain_N` is a frontend named after the
business:

```text
README.md               map of applications and root documents
docs/
  assets/docs.css       the one shared stylesheet
  requirements/business-requirements.html
  ui-system/
  qa/support/
  security/
  decisions/
  evaluation/{feature-slug}-{role}-{model}.html
frontend_domain_N/
  README.md
  docs/
    modules/{module}/   README.md index, then screens, routes, flows, code map, debt
    mockups/
    decisions/
web/frontend_domain_N/
  README.md
  docs/                 the same shape as the mobile app's docs
frontend-core/
  README.md
  docs/
    modules/{module}/   tokens, components, shared logic, SDK usage; apps link here
    decisions/
api/
  README.md
  docs/
    architecture.html   module map and rules that cross modules
    modules/{module}/   named like the code folder
      README.md         purpose and index of the files below
      rules.html
      flows.html
      data-dict.html
      permissions.html
      api-spec.html     what each operation means; shapes stay in openapi.json
      code-map.html
      tech-debt.html
    decisions/
    api-spec/openapi.json   generated; never read whole
infra/
  README.md
  docs/
    architecture.html
    uat.html
    production.html
    diagrams/
    decisions/
```

An application's docs describe only what is specific to it. For anything from
`frontend-core`, link the `frontend-core` document, so it is clear one change
there affects every application linking it.

QA Lead owns the support requirements in `docs/qa/support/`. If support becomes
a real application, `/support/` holds its own docs and code; it does not replace
those requirements.

## One feature, one Issue

The Issue (on the repository's host) is the ticket and lifetime history of one
feature: what was agreed, its status, and what happened. Decisions live in the
docs, which the Issue links; an agent never needs the Issue to learn how
something works. PO creates it when the human says the feature is ready or asks
to pause.

```markdown
# Feature name

## Purpose
Two or three sentences: the problem, who it is for, and what success looks like.

## Business Requirement
The agreed requirement.

## Acceptance Criteria
- [ ] **AC-1** An observable business outcome.

## Design
What Design Lead agreed with the human, in a few lines, linking the design documents.

## Technical
What Technical Lead agreed with the human, in a few lines, linking the decision documents.

## Infrastructure
What DevOps needs for this feature: environments, services, configuration names, cost.

## Security
- **SEC-1** A security or privacy requirement the feature must meet.

## Definition of Done
- [ ] **DOD-1** A condition, beyond the AC, that must hold before this feature is done.

## References
Links to relevant authoritative documents, as `file#section`.
```

Only the owner writes its section:

| Section | Owner |
| --- | --- |
| Purpose, Business Requirement, Acceptance Criteria | PO |
| Design | Design Lead |
| Technical | Technical Lead |
| Infrastructure | DevOps, when Technical Lead calls it in |
| Security | Cybersecurity, when Technical Lead calls it in |
| Definition of Done | QA Lead |

- A section states what was agreed and links the detail. It is not a task list;
  nobody adds Design/Technical/QA/Security task checklists.
- **AC** say what the product does for the user. Each has a stable ID (`AC-1`),
  never renumbered or reused.
- **Definition of Done** items say what else must be true (coverage, a
  performance limit, a runbook). QA Lead agrees them with the human, gives
  stable IDs (`DOD-1`), and ticks them only with evidence.
- **Security requirements** have stable IDs (`SEC-1`) so docs and QA cases can
  cite them. One may forbid something: "Do not store a customer's card number
  until the certification is passed." When Technical Lead does not follow one,
  the requirement stays as written and Technical Lead adds its decision and
  reason beneath it.
- Keep Purpose short. Omit sections the feature does not need.
- QA Lead keeps the AC and DoD boxes matched to verified evidence, changing only
  the boxes ([sync the Issue checkboxes](../roles/qa-lead.md#sync-the-issue-checkboxes)).

### Issue status

The Issue shows where the feature stands, never task progress; that lives on
the [`.AI` board](ai-task-delegation.md). Each feature Issue has exactly one
status label; create the label in the repository if it is missing.

| Label | Means | Set by |
| --- | --- | --- |
| `draft` | Just created, or paused before the human confirmed. What is agreed so far is recorded and pushed. Every Issue starts here. | PO |
| `ready to implement` | The human confirmed; work has not started. | PO |
| `in progress` | Set just before the first task is dispatched. | Organizer |
| `in review` | Implementation and reviews are done; set just before the PR opens. | Organizer |
| `done` | The human merged the feature's PR. | Organizer |

- The team starts a feature only from `ready to implement`.
- A `draft` Issue has an `## Open questions` section: what is still open, under
  the owning role, with options and what each blocks. Remove it at
  `ready to implement`.
- A `bug` label sits beside the status while a bug recorded on the Issue is
  open. QA Lead adds it on confirming the bug and removes it on verifying the
  fix.

### Work without a new Issue

- **Small change:** no Issue. It uses a `fix/{descriptive-slug}` branch and
  records context, decisions, evidence, and outcome in its PR.
- **Bug:** no new Issue. It belongs to the feature Issue whose behavior is
  wrong; its branch and PR reference that Issue, and the outcome is recorded
  there, even if the feature already shipped.
- **Requirement gap found by a bug:** a change to agreed AC; PO records a
  [change record](#changing-agreed-ac).
- Other gaps are classified by impact and routed to their owner. Never attach
  work to an unrelated Issue to avoid creating one; new feature scope goes to
  PO and the human first.

## Changing agreed AC

When agreed behavior changes, or an AC was missing, PO agrees the change with
the human and posts it as a comment on the owning Issue:

```markdown
## Change 1: manager approval for large refunds (2026-10-11)

Why: finance requires a second person on refunds over 5,000 THB.
Original intent: refunds were kept to one step so staff could serve a customer at the counter.
Current behavior (checked): any staff account can refund any amount.

| AC | Change | Before → After |
| --- | --- | --- |
| AC-2 | Modified | Any staff can refund any amount → Staff can refund up to 5,000 THB; above that needs manager approval |
| AC-5 | New | A manager can approve or reject a pending refund |
| AC-1, AC-3, AC-4 | Unchanged | |

Must not change: refund goes to the original payment method; customer email is still sent.
Agreed by the human on 2026-10-11.
```

- Number changes per Issue (`Change 1`, `Change 2`, ...).
- State the original intent, so nobody undoes a decision without knowing why.
- State current behavior as checked in the product or by Technical Lead, not
  from memory.
- List every AC as Modified, New, Removed, or Unchanged.
- "Must not change" is mandatory: QA Lead takes the regression checks from it.

Then PO updates the Issue body and the business requirements document:

- Modified AC: new wording, the change tag, an unchecked box.
- New AC: the next unused ID, tagged, unchecked.
- Removed AC: struck through with its tag, not deleted; the ID is never reused.
- Unchanged AC keep their text and box.

```markdown
- [x] **AC-1** Staff can refund a paid order.
- [ ] **AC-2** Staff can refund up to 5,000 THB; above that needs manager approval. *(Change 1)*
- [ ] **AC-5** A manager can approve or reject a pending refund. *(Change 1)*
```

QA Lead re-ticks a modified or new AC only with new evidence. Affected owners
decide which of their earlier approvals the change invalidates.

A bug needs no change record: when the product does not do what an AC says, the
AC stays and the fix follows the bug route.

## Durable updates

- Leads record scope, decisions, review outcomes, evidence links, and remaining
  work on the owning Issue, or in the PR and linked records when there is no
  Issue. Specialists record their own results; Seniors report to their Lead.
- Organizer may post an owner's approved update when tooling needs it, credited
  to the owner, without writing its verdict.
- Before editing an Issue body, fetch the latest version and keep other owners'
  sections. Prefer comments for independent updates when body edits could
  collide. When a decision changes, keep the history, update the docs, and link
  the reason from the Issue.
- Handoffs point to saved files, commits, and the Issue (or PR). A local tool
  message is never the only record. A failed write to the host is pending, not
  synced: keep the outcome in repo docs and checkpoint the unfinished step.
- Feature PRs link their Issue and evidence. Issue-free PRs record the request,
  fix, reviews, and QA evidence themselves. Never require auto-closing an Issue
  as proof, and never open a second Issue for follow-up in the same feature.
