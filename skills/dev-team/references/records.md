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

Write every project document as HTML (`.html`): requirements, decisions, technical
packages, QA cases, support and security records, runbooks, and evaluations. Start
from [the document template](../assets/document.html) so a page is self-contained
and readable when opened straight from a checkout.

`README.md` files are the index, because GitHub renders them. The root `README.md`
lists the root `docs/` documents and links to every application/service
`README.md`. Each of those lists its own documents. A docs subfolder with many
documents may keep its own `README.md`, linked from its parent. Every document is
therefore reachable from the root `README.md` by following links:

```markdown
## Documents

| Document | Purpose | Owner |
| --- | --- | --- |
| [Business requirements](docs/requirements/business-requirements.html) | Agreed scope, rules, and AC sources | PO |

## Applications and services

- [API](api/README.md)
- [Frontend](frontend/README.md)
```

Whoever adds, renames, or removes a document updates the `README.md` that lists
it in the same change. A document no `README.md` reaches is not published. Use
relative links. Besides the indexes, the only Markdown the team writes is under
`.AI/` (see [pause and resume](checkpoints.md)).

These are not project documents and keep their own formats: GitHub Issue and PR
text, task packets, generated files such as `openapi.json`, and diagram or mockup
assets linked from a document.

In a project that already keeps non-HTML docs, write new documents as HTML and
list the existing ones in the `README.md` index as they are. Converting them is a migration
the human agrees first. Never keep two formats of the same truth.

The following are example locations, not a scaffold to create in every project:

```text
README.md
docs/
  requirements/business-requirements.html
  ui-system/
  qa/support/
  security/
  decisions/
  evaluation/{feature-slug}-{role}-{model}.html
infra/
  README.md
  docs/
    architecture.html
    uat.html
    production.html
    diagrams/
    decisions/
  terraform/
frontend/
  README.md
  docs/
    technical/
    mockups/
    decisions/
api/
  README.md
  docs/
    architecture/
    flows/
    data-dictionary/
    api-spec/
    roles-permissions/
    decisions/
```

Create a directory only when a real deliverable needs it. Keep requirements,
decisions, and implementation docs current as part of the work that changes them.
Link between records instead of maintaining conflicting copies of the same truth.

QA Lead owns authoritative support-system requirements in `docs/qa/support/`:
supportability, troubleshooting standards, incident classifications, and
recovery/support actions. If support becomes an actual application, `/support/`
holds its implementation docs, mockups, and code. It does not replace the
requirements under `docs/qa/support/`.

## One feature, one Issue

A GitHub Issue is the durable lifetime history for one feature. PO creates it
only after the human and PO agree on the business requirement and AC. The team
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

## Technical Concerns
Optional concerns, not a technical task checklist.

## Design Concerns
Optional concerns, not a design task checklist.

## References
Links to relevant authoritative documents.
```

Purpose gives every stateless agent the context behind the requirement; keep it
short. Every AC carries a stable identifier that is never renumbered or reused.
Omit empty optional sections. PO must not create Design/Technical/QA/Security
task checklists. Each responsible Lead owns the later work coordination for its
domain. PO defines AC; QA Lead updates AC completion only after verification.

Bugs and business, technical, design, QA/supportability, or security gaps normally
continue in the original owning feature Issue. Organizer searches existing Issues
(including closed ones), references, and related PRs before proposing a new Issue.
Do not attach work to an unrelated Issue just to avoid creating one. If ownership
is unclear, route to the appropriate owner; PO resolves genuine new feature scope
with the human before creating its Issue. Record later fixes on the same feature
even when its original implementation already shipped.

## Changing agreed AC

When the agreed behavior itself changes, or an AC was missing, PO agrees the
change with the human and then records it as a comment on the owning Issue:

```markdown
## Change 1: manager approval for large refunds (2026-10-11)

Why: finance requires a second person on refunds over 5,000 THB.

| AC | Change | Before → After |
| --- | --- | --- |
| AC-2 | Modified | Any staff can refund any amount → Staff can refund up to 5,000 THB; above that needs manager approval |
| AC-5 | New | A manager can approve or reject a pending refund |
| AC-1, AC-3, AC-4 | Unchanged | |

Must not change: refund goes to the original payment method; customer email is still sent.
Agreed by the human on 2026-10-11.
```

Number changes per Issue (`Change 1`, `Change 2`, ...). List every AC as
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
work on the owning Issue. Specialists record their own domain results; Seniors
return findings and artifacts to their Lead instead of managing the Issue.
Organizer may carry an owner's approved update to GitHub when tooling requires
it, clearly attributing the owner, without authoring its verdict.

Before editing an Issue body, fetch its latest version and preserve other owners'
sections. Prefer attributable comments for independent updates when simultaneous
body edits could overwrite work. Keep history when a decision changes; update
current repo truth and link the reason from the Issue.

Meaningful handoffs must point to saved files/commits and durable Issue records.
Do not rely on a local tool message as the sole record of a decision. A required
GitHub write that fails is pending, not synchronized: preserve the outcome in
appropriate repo docs and checkpoint any unfinished publishing action.

PRs link to the owning feature Issue and relevant verification evidence. Existing
Issue lifecycle conventions may be followed; do not require auto-closing an Issue
to prove completion or create a second Issue for a follow-up in the same feature.
