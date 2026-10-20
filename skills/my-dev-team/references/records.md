# Persistent records

## Repository truth

Root `docs/` holds project-wide truth; each application/service's `docs/` holds
implementation-specific truth. Update the existing authoritative document when
facts change.

A document states the current truth only, so it is always up to date. Do not keep
dated copies, archived versions, superseded text, or a change log inside it. An
earlier version comes from git history by its commit; the reason for a change is
on the owning Issue.

### HTML documents, README indexes

Write every project document as HTML (`.html`): requirements, decisions, module
and architecture documents, QA cases, support and security records, runbooks, and
evaluations. Start from [the document template](../assets/document.html). Keep
the HTML plain: semantic tags only, no inline styles or scripts. All documents
share one stylesheet, [docs.css](../assets/docs.css), copied once to
`docs/assets/docs.css`, so no document carries its own styling.

Give every section heading a short, stable `id` in kebab-case, for example
`<h2 id="admin">`. Every `id` is kebab-case, including one named after
something in the code: the table `order_items` is `#order-items` and the
operation `refundOrder` is `#refund-order`. Whenever you point anyone at a
document, in a reply to the human, a task packet, an Issue, a PR, or another
document, give the file and the section:
`api/docs/modules/orders/rules.html#admin`. The human opens the exact place, and
an agent reads that section instead of the whole file. Renaming an `id` breaks
links, so change one only together with every link to it.

`README.md` files are the index and the map, because GitHub renders them and they
are the first thing an agent reads. Every document and every module is reachable
from the root `README.md` by following links.

The root `README.md` maps the applications and lists the root documents:

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

Each application's `README.md` gives the commands, its modules with where their
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

Whoever adds, renames, or removes a document or a module updates the `README.md`
that lists it in the same change. A document or module no `README.md` reaches is
not published. Use relative links. Besides these READMEs, the only Markdown the
team writes is under `.AI/` (see [pause and resume](checkpoints.md)).

### Navigate by documents, not by code

An agent has no memory of the code base, and reading code to find its way is the
most expensive thing it does. Reach the right files in a few reads:

1. **The task packet** names the Issue, the worktree, and the documents to start
   from.
2. **The Issue** gives the purpose, the AC, readiness, and history. It does not
   explain how anything works.
3. **The root `README.md`** maps the applications. Follow one link.
4. **The application's `README.md`** gives the commands and, for each module,
   where its documents and its code are.
5. **The module's `README.md`** says in one line what the module is for and
   lists its documents: rules, flows, data, permissions, API, code map, debt.
6. **Only the module documents the task needs**, and in them only the sections
   it needs. `code-map.html` names the files and tests.
7. **Then open only the files the code map names.**
8. **The `.AI/` checkpoint**, only when resuming unfinished work.

- Read only your path. Skip sibling modules and other applications unless the
  change crosses into them.
- Do not open generated files (`openapi.json`, the SDK), lockfiles, or build
  output to learn the system; the module's `api-spec.html` says what they mean. Search
  them for one specific name when you need it.
- Search or read through code only when the documents do not answer. Then fix
  the document in the same change, so the next agent does not pay the same cost.
  When a document contradicts the code, trust the code, fix the document, and
  say so.
- Write for the next reader's budget. Start each document with one line saying
  what it covers, state each fact once at the lowest level where it is true, and
  link instead of repeating. A higher level gives one sentence and the link.

One folder per module holds everything about that module, one document per
subject: rules, flows, data, permissions, what its API operations mean, the code
map, and known debt ([engineering practices](engineering.md)). Documents outside
the modules cover only what spans them: the architecture overview and decisions.

These are not project documents and keep their own formats: GitHub Issue and PR
text, task packets, generated files such as `openapi.json`, and diagram or mockup
assets linked from a document.

In a project that already keeps non-HTML docs, write new documents as HTML and
list the existing ones in the `README.md` index as they are. Converting them is a
migration the human agrees first. Never keep two formats of the same truth.

The following are example document locations in the
[standard repository layout](stack.md), not a scaffold to create in every project.
`frontend_domain_N` stands for a frontend domain named after the business:

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

An application's docs describe only what is specific to it. For anything it
takes from `frontend-core`, link to the `frontend-core` document, so it is clear
that one change there applies to every application that links to it.

Create a directory only when a real deliverable needs it. Keep requirements,
decisions, and implementation docs current as part of the work that changes them.
Link between records instead of maintaining conflicting copies of the same truth.

QA Lead owns authoritative support-system requirements in `docs/qa/support/`:
supportability, troubleshooting standards, incident classifications, and
recovery/support actions. If support becomes an actual application, `/support/`
holds its implementation docs, mockups, and code. It does not replace the
requirements under `docs/qa/support/`.

## One feature, one Issue

A GitHub Issue is the ticket and the durable lifetime history for one feature:
what was agreed, whether it is ready to implement, and what happened. Decisions
themselves live in the docs, which the Issue links to, so an agent learns how
something works from the docs and never needs the Issue for that. PO creates the
Issue when the human says the feature is ready or asks to pause, and labels it
with its status. The team
works on GitHub only: when the repository's remote is another host, stop and ask
the human instead of recording the feature elsewhere or inventing a substitute.
Include:

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

Each section belongs to one role, and only that role writes it:

| Section | Owner |
| --- | --- |
| Purpose, Business Requirement, Acceptance Criteria | PO |
| Design | Design Lead |
| Technical | Technical Lead |
| Infrastructure | DevOps, when Technical Lead calls it in |
| Security | Cybersecurity, when Technical Lead calls it in |
| Definition of Done | QA Lead |

A section says what was agreed and links the document that holds the detail; it
is not a task checklist. The Definition of Done is the exception: QA Lead agrees
each item with the human, gives it a stable identifier (`DOD-1`, `DOD-2`, ...),
and checks it only with evidence, as for an AC. An AC says what the product does
for the user; a Definition of Done item says what else must be true, such as
test coverage, a performance limit, or a support runbook. Each security
requirement also carries a stable identifier (`SEC-1`, `SEC-2`, ...), so the
technical documents and QA cases can cite it; it may forbid something, for
example: "Do not store a customer's card number in our systems until the
certification is passed." When Technical Lead decides not to follow one, the
requirement stays in the section as Cybersecurity wrote it, and Technical Lead
adds its decision and reason beneath it. Omit the section of a role the feature
does not need.

### Issue status

The Issue shows where the feature stands, never the progress of each task;
that lives in the local [`.AI` board](ai-task-delegation.md). Every feature
Issue carries exactly one status label, created in the repository when it does
not exist:

| Label | Means | Set by |
| --- | --- | --- |
| `draft` | The human paused before confirming. The requirement so far is recorded and pushed. | PO |
| `ready to implement` | Pending: the human confirmed the feature; work has not started. | PO |
| `in progress` | Technical Lead has started the work. | Organizer |
| `done` | The human merged the feature's PR. | Organizer |

A `bug` label is added beside the status while a bug recorded on the Issue is
open, by QA Lead when it confirms the bug, and removed when QA Lead verifies the
fix. The team starts work only from `ready to implement`.

A `draft` Issue adds an `## Open questions` section listing what is still to be
settled, under the role that owns each, with its options and what it blocks, so the discussion can
continue from the Issue alone. Remove the section when the Issue becomes
`ready to implement`.

Purpose gives every stateless agent the context behind the requirement; keep it
short. Every AC carries a stable identifier that is never renumbered or reused.
Omit empty optional sections. Nobody creates Design/Technical/QA/Security task
checklists on the Issue. Each responsible Lead owns the later work coordination
for its domain. PO defines AC and QA Lead defines the Definition of Done; QA
Lead updates the completion of both only after verification.

QA Lead keeps the Issue's AC and DoD checkboxes matched to verified evidence,
changing only the boxes
([sync the Issue checkboxes](../roles/qa-lead.md#sync-the-issue-checkboxes)).

A minor change (the small route) needs no Issue: it uses a
`fix/{descriptive-slug}` branch and records its context, decisions, verification
evidence, and outcome in its draft PR. A bug needs no new Issue either: it
belongs to the feature Issue whose behavior is wrong, so its branch and PR
reference that Issue and the outcome is recorded on it. A bug that reveals a
requirement gap is a change to agreed AC, and PO updates that Issue with a
[change record](#changing-agreed-ac). Other business, technical, design, QA/supportability, or security gaps
are classified by impact and routed to the appropriate owner. Do not attach work
to an unrelated Issue just to avoid creating one. If ownership
is unclear, route to the appropriate owner; PO resolves genuine new feature scope
with the human before creating its Issue. Record later fixes on the same feature
even when its original implementation already shipped.

## Changing agreed AC

When the agreed behavior itself changes, or an AC was missing, PO agrees the
change with the human and then records it as a comment on the owning Issue:

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

Number changes per Issue (`Change 1`, `Change 2`, ...). State the original
intent, so nobody undoes a decision without knowing why it was made, and the
current behavior as verified in the product or by Technical Lead, not as
remembered. List every AC as
Modified, New, Removed, or Unchanged. "Must not change" is mandatory: QA Lead
derives the regression checks from it.

Then PO updates the Issue body to the current truth:

- A modified AC gets its new wording, the change tag, and an unchecked box.
- A new AC takes the next unused identifier, tagged and unchecked.
- A removed AC is struck through with its change tag, not deleted; its identifier
  is never reused.
- Unchanged AC keep their text and checkbox.

```markdown
- [x] **AC-1** Staff can refund a paid order.
- [ ] **AC-2** Staff can refund up to 5,000 THB; above that needs manager approval. *(Change 1)*
- [ ] **AC-5** A manager can approve or reject a pending refund. *(Change 1)*
```

QA Lead checks a modified or new AC again only with new verification evidence.
PO also updates the business requirements document to match. The affected owners
then decide which of their earlier decisions and approvals the change invalidates.

A bug needs no change record. When the product does not do what an AC says, the
AC stays as written and the correction follows the bug route.

## Durable updates

Leads record their scope, decisions, review outcomes, evidence links, and remaining
work on the owning Issue when present, or in the draft PR and linked repository
records for issue-free bugs and minor changes. Specialists record their own domain results; Seniors
return findings and artifacts to their Lead instead of managing the Issue.
Organizer may carry an owner's approved update to GitHub when tooling requires
it, clearly attributing the owner, without authoring its verdict.

Before editing an Issue body, fetch its latest version and preserve other owners'
sections. Prefer attributable comments for independent updates when simultaneous
body edits could overwrite work. Keep history when a decision changes; update
current repo truth and link the reason from the Issue.

Meaningful handoffs must point to saved files/commits and durable Issue records
when present, or draft PR/repository records for issue-free work.
Do not rely on a local tool message as the sole record of a decision. A required
GitHub write that fails is pending, not synchronized: preserve the outcome in
appropriate repo docs and checkpoint any unfinished publishing action.

Feature PRs link to their owning Issue and relevant verification evidence. Bug and
minor-change PRs without Issues record the request, fix, reviews, and QA evidence
directly. Existing
Issue lifecycle conventions may be followed; do not require auto-closing an Issue
to prove completion or create a second Issue for a follow-up in the same feature.
