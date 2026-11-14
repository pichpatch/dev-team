# Document map: who owns what, and how to find it

Read this before you look for a file or change a document.

## Who owns what

**The owner decides the content, writes it, and answers for it.** Every document
and every file has exactly one owner. Nobody else edits it. When you find it
wrong or incomplete, report `file#section: what is wrong` to the owner (a Senior
reports through its Lead) and continue with what you can.

**Leads own the overview; Seniors own the detail of their own work.** A Lead's
documents say what a module must do and how its parts fit. A Senior's code
comment says what one function actually does.

| What | Where | Owner | Who else writes there |
| --- | --- | --- | --- |
| Business requirements, market research | `docs/requirements/` | PO | Nobody |
| Feature Issue | The repository host | Each section has its owner ([Issue sections](records.md#one-feature-one-issue)) | Seniors never edit it |
| Design System, design decisions, mockups, image briefs | `docs/ui-system/`, each frontend's `docs/mockups/` and `docs/decisions/` | Design Lead | Senior Designer writes them as its deliverable; nothing counts until Design Lead approves it |
| Architecture and technical decisions | Each application's `docs/architecture.html` and `docs/decisions/` | Technical Lead | Nobody |
| Module documents: rules, flows, data dictionary, permissions, API meaning, tech debt, and the module `README.md` ([what each holds](module-docs.md)) | Each application's `docs/modules/{module}/` | Technical Lead | Nobody. Senior Developer lists the changes needed in its return; Technical Lead writes them before approving |
| Code map | `docs/modules/{module}/code-map.html` | Technical Lead | Senior Developer keeps the rows for the files and functions it adds, moves, or removes |
| Root and application `README.md` indexes | Repository root, each application | Technical Lead | Each owner adds or removes the row for its own document |
| Code, function comments, unit tests, migrations | The code | Senior Developer | Nobody; Technical Lead reviews |
| Integration tests, seed data | The code | Senior QA | Nobody; QA Lead approves |
| Generated files (`openapi.json`, the SDK) | Where the generator writes | Nobody edits them | Senior Developer regenerates them with the project's commands |
| `.env.example` | Each application | Technical Lead | Senior Developer adds each key its code reads, with an empty or fake value |
| Test strategy, cases, support requirements | `docs/qa/`, `docs/qa/support/` | QA Lead | Senior QA supplies cases and evidence; QA Lead records them |
| Regression document | `docs/qa/regression.html` | PO decides which behavior is listed; QA Lead writes the steps and how each case is run ([rule](records.md#regression-document-and-user-manual)) | Nobody |
| User manual | `docs/manual/user-manual.html` | PO | Nobody |
| Security requirements and reports | `docs/security/` | Cybersecurity | Nobody |
| Infrastructure documents and runbooks | `infra/README.md`, `infra/docs/` | DevOps | Nobody |
| Evaluations | `docs/evaluation/` | The Lead of the evaluated Senior | Nobody |
| Work board | `.AI/{feature-slug}/README.md` | Organizer | Nobody |
| Task card | `.AI/{feature-slug}/{role}-{instance}.md` | The assigning Lead owns the assignment; the worker owns its plan, progress, and evidence ([the board](ai-task-delegation.md#the-board)) | Nobody |
| PR text | The repository host | Organizer | Owners supply their results |
| Draft release | The repository host | DevOps | Organizer adds QA's and Cybersecurity's reports |

- Every HTML document names its owning role at the top
  ([template](../assets/document.html)), and every `README.md` document table
  has an Owner column. A document with no owner is a finding for Technical Lead.
- A Lead may have a [drafting run](roster.md#drafting-runs) write its document
  updates; the Lead checks them and stays the owner.
- Owning a document never gives authority outside the role's domain
  ([authority](contract.md#authority)).

## Navigate by documents, not by code

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
   side effects, its impact, and its unit test file
   ([comment format](engineering.md#implementation-and-data)); open that test
   only when the task needs it.
8. **The `.AI/` checkpoint,** only when resuming.

- Read only your path; skip other modules and applications unless the change
  crosses into them.
- Never read generated files (`openapi.json`, the SDK), lockfiles, or build
  output to learn the system. Search them for one name when needed.
- Search code only when the documents do not answer. Then report the gap to
  the document's owner as `file#section: what is missing`, so the next agent
  does not search again. When a document contradicts the code, trust the code
  and report it the same way.
- Write for the next reader: one opening line on what the document covers, each
  fact once at the lowest level where it is true, links instead of repeats.

Each module has one folder with one document per subject: rules, flows, data,
permissions, API meaning, code map, debt ([module documents](module-docs.md)).
Documents outside modules cover only what spans them: architecture and
decisions.

## Where documents live

Example locations in the [standard layout](stack.md); create a folder only when
a real deliverable needs it. `frontend_domain_N` is a frontend named after the
business:

```text
README.md               map of applications and root documents
docs/
  assets/docs.css       the one shared stylesheet
  requirements/business-requirements.html
  ui-system/
  qa/regression.html    standing regression cases, one section per feature
  qa/support/
  manual/user-manual.html   how a user does each thing, one section per feature
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
