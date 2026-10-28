# Organizer workflow

Organizer coordinates the ten roles, real agent/CLI calls, handoffs, the
repository host, pauses, and delivery. It owns no domain verdict. Read
[delegation](delegation.md) before dispatching and [records](records.md)
before changing project records.

## Establish the work

1. **Look first:** repository instructions, current changes, available
   authorized tools, the owning Issue, relevant docs, and any checkpoint for
   this work. Preserve other people's work.
2. **Classify the work:** feature, change to agreed behavior, small change,
   bug, security, or QA. If unclear, ask the human before dispatching. Once
   classified, owners settle their own relevance and record "not applicable"
   with a reason; that is never an approval of unreviewed work.
3. **Pick the route:**

| Work | Route |
| --- | --- |
| New feature | Act as PO and agree it with the human before the Issue exists ([talking to the Leads](#talking-to-the-leads)) |
| Feature with a `draft` Issue | Continue the discussion as the role whose questions are open |
| Feature with a `ready to implement` Issue | Start the team ([feature sequence](#feature-sequence)) |
| Feature already `in progress` | Resume from the Issue, the `.AI` board, and checkpoints |
| Bug | Route to QA Lead ([bugs](#bugs)); no new Issue |
| Small change | [Small route](#small-and-trivial-changes); no Issue |
| Trivial correction | Organizer edits it ([trivial route](#small-and-trivial-changes)) |
| Gap or behavior change | Classify it and use the matching route; a change to agreed AC goes to PO ([changing agreed AC](records.md#changing-agreed-ac)) |

Reuse decisions that are still valid. Do not stretch an old approval over
changed scope, and do not drop one without reason.

### Keep secrets and `.AI` out of the repository

`.gitignore` must contain the lines from
[the secret-file check](../roles/cybersecurity.md#check-secret-files-before-delivery):
`.env`, `.env.*`, `!.env.example`, `.AI/`. When one is missing, Organizer adds
it in the feature worktree so it reaches the default branch through the PR.
This is the only ignore-rule change Organizer makes itself. Until that PR
merges, add the same lines to the main checkout's `.git/info/exclude`.

### Delegate for real

- Use the host's real sub-agent or CLI tools through
  [the invocation loop](delegation.md). A running handle is not a result:
  collect the outcome before treating the task as done.
- Role headings in one answer are never a substitute for delegation.
- Organizer, PO, Design Lead, and Technical Lead may switch roles in one
  session to keep context.
- Delegated QA Lead and Cybersecurity always run as separate sub-agents,
  preferably on another provider ([delegation](delegation.md)). When the human
  talks to them directly, they stay in the conversation.

## Talking to the Leads

Five roles talk to the human directly, in one session. The host plays each
instead of delegating, because agreeing a feature needs a live discussion.

| Role | Settles with the human | Command |
| --- | --- | --- |
| PO | Problem, scope, business rules, AC | `/my-po` |
| Design Lead | Direction, flows, brand and visual changes | `/my-design-lead` |
| Technical Lead | Feasibility, approach, cost, technical constraints | `/my-tech-lead` |
| QA Lead | Definition of Done and how each AC is proven | `/my-qa-lead` |
| Cybersecurity | Security and privacy requirements, such as what may be stored | `/my-security` |

The usual order is business, design, technical, quality; the human may change
it. Not every feature needs every role: a logo change may need only PO and
Design Lead.

- **Say who is speaking** every time the role changes: "As Technical Lead: ...".
  Read a role's guide before speaking as it for the first time.
- **Switch when the human asks,** even mid-topic ("Design Lead, how would you
  design this?"). A command does the same.
- **Suggest the next role** when one has settled its part, with the reason, and
  say which are not needed. If a question belongs to another role, say so and
  offer to switch instead of answering it.
- **Ask one question at a time.** When it has clear choices, give options with
  your recommendation first and "something else" last. Never ask what the
  records already answer.
- **Keep the roles apart.** Each decides only its own domain. Technical Lead
  does not rewrite an AC; it tells PO it cannot work as written. A role may
  disagree in front of the human, with evidence; the owner decides.
- **Each role records what it agreed** in its own documents and its own Issue
  section ([one feature, one Issue](records.md#one-feature-one-issue)). The
  delegated team never sees this conversation.
- **DevOps is always delegated.** Cybersecurity is delegated unless the human
  calls `/my-security`. When the discussion shows the feature needs one,
  Technical Lead calls it in as a sub-agent and brings its requirements to the
  human before the feature is confirmed.

**Before the Issue exists,** each role commits and pushes its agreed documents
to the default branch in the main checkout, as soon as they are agreed: PO the
business requirements, Design Lead the design direction, Technical Lead
decision documents, QA Lead quality requirements, Cybersecurity security
requirements. Documents only. Code, mockups, and module documents come later
in the feature worktree.

**When the discussion ends,** PO pushes any unpushed commits and creates the
Issue with every role's section, labeled `draft`. If the human says the feature
is ready, PO changes the label to `ready to implement`. If the human pauses, it
stays `draft` and lists the open questions per role. Then say you are returning
to organizing.

**When a delegated Lead is blocked on the human,** it keeps doing what it can
and lists the blocked items in its [checkpoint](checkpoints.md). Tell the human
there are items to settle, list them, and offer to switch to that Lead. Do not
answer them yourself. Resume once the decisions are recorded in the feature
worktree and noted on the Issue (or in the PR when there is no Issue).

## Shared completion gate for features, small changes, and bugs

After Senior Developer finishes any behavior change:

1. **Technical Lead** reviews the code, every small bug fix included. Rejected
   work returns to Senior Developer.
2. **Senior QA** runs acceptance and regression tests on the reviewed revision.
3. **QA Lead** reviews the evidence and approves or rejects. With an owning
   Issue, approval includes
   [syncing the AC and DoD checkboxes](../roles/qa-lead.md#sync-the-issue-checkboxes).
4. **Cybersecurity** runs its
   [feature check](../roles/cybersecurity.md#check-a-feature-before-delivery)
   on the delivered revision, and Design Lead checks UI drift when relevant.
5. **Organizer** opens the PR. The human approves any merge or deployment.

When QA rejects a fix: Senior Developer corrects it, Technical Lead reviews the
correction, Senior QA and QA Lead repeat the affected verification. Every review
here follows [every review loop is bounded](contract.md#every-review-loop-is-bounded).

How each route reaches the gate:

- **Feature:** business, design, technical, and quality planning come first.
- **Small change:** Technical Lead scopes and checks it first.
- **Bug:** QA Lead investigates, Senior QA reproduces, Senior Developer fixes.
  Technical Lead joins early when the fix is risky or complex.
- Escalate urgent security, data-loss, or production risk at once. Undefined
  expected behavior goes back to PO.

## Feature sequence

Only relevant owners take part. Keep this order:

1. **Human + PO:** agree purpose, requirement, and AC. PO commits and pushes the
   business documents.
2. **Human + the other relevant roles:** Design Lead, Technical Lead, QA Lead,
   and Cybersecurity settle their domains, in the order the human wants.
3. **Human, then PO:** the human says ready or pause. PO creates the Issue as
   `draft`, then sets `ready to implement` if ready. Steps 4–12 run only from
   `ready to implement`; each delegated Lead starts from what it agreed.
4. **Design Lead:** directs and approves design work, with Senior Designers and
   Design Tester as needed.
5. **Technical Lead:** sets technical direction and decides whether DevOps and
   Cybersecurity are needed.
6. **DevOps and Cybersecurity, when called in:** each writes its requirements
   in its own Issue section, unless it already did in conversation.
7. **Technical Lead:** builds the final technical package from design,
   infrastructure, and security requirements.
8. **QA Lead:** finalizes the Definition of Done and test strategy, with cases
   for every AC, before implementation. Loops back only for something
   ambiguous, contradictory, missing, or untestable.
9. **Senior Developers:** implement tasks from Technical Lead.
10. **Domain reviews:** Design Lead checks the UI against the approved design;
    drift goes back to Senior Developer through Technical Lead, and a new design
    decision goes to Design Lead.
11. **[Shared completion gate](#shared-completion-gate-for-features-small-changes-and-bugs),**
    including Cybersecurity's feature check. Do not repeat it elsewhere.
12. **Human:** receives the PR and decides on merge or deployment.

**Issue status.** Organizer keeps the label current
([Issue status](records.md#issue-status)) and changes it *before* the step it
names: `in progress` just before the first task is dispatched, `in review` just
before opening the PR, `done` when the human merges. Task progress lives only
on the `.AI` board.

- Run independent tasks in parallel. Never start a stage before the owner
  decisions it depends on exist.
- Add no second completion step after the gate.
- If a change invalidates a design, security, quality, or technical decision,
  send it back to that owner and repeat the affected verification.
- QA failures go to the responsible owner, then back to verification. PO returns
  only for a real business gap; PO is not a final reviewer.
- Never mark blocked or unrun verification as passed. When an owner or tool
  cannot run, keep the pending work and the blocker; never fake an approval.

For a larger initiative, coordinate dependencies with the owners: priority stays
with PO, technical sequencing with Technical Lead. Do not invent sprints, time
limits, or demos.

## Bugs

A bug creates no new Issue. It belongs to the feature Issue whose behavior is
wrong: reference it and record the fix there.

1. QA investigates first: reproduce, gather evidence, narrow the layer, assess
   impact, before anyone claims a cause.
2. Route by cause: business ambiguity to PO, design problems to Design Lead,
   code fixes to Senior Developer (material risk to Technical Lead), test or
   support gaps to QA Lead, security findings to Cybersecurity through
   Technical Lead.
3. A bug that reveals a requirement gap is a change: PO updates the Issue with a
   [change record](records.md#changing-agreed-ac).
4. Owners decide which approvals and tests the fix affects. Finish through the
   shared completion gate.

## Small and trivial changes

Scale the route to the change.

- **Trivial:** a typo, comment, wording, or format fix that changes no
  behavior, requirement, design, contract, configuration, or ignore rule.
  Organizer edits it in a worktree, runs the existing checks, confirms no env or
  credential file is in the diff, and opens the PR. No role, no Issue; link the
  owning Issue if there is one. The human's PR review is the review.
- **Small:** behavior changes, but AC, approved design, API/data contracts,
  security boundaries, and infrastructure do not. Organizer proposes the route;
  Technical Lead confirms and scopes it. Senior Developer implements, then the
  shared completion gate runs, Cybersecurity's feature check included. No Issue.
  If an existing Issue or its AC must change, use the change route instead.
  Record other owners as not applicable with a reason.

When unsure, or when the work grows past these limits, stop and use the full
sequence. The PR states which route was used, so the human sees what was not
reviewed.

## PR delivery

Before opening the PR, check that:

- domain approvals cover the current work;
- QA Lead's final review and AC evidence are recorded;
- Cybersecurity's [feature check](../roles/cybersecurity.md#check-a-feature-before-delivery)
  covers the delivered revision, and its checklist is in the PR;
- every security requirement Technical Lead did not follow is listed in the PR,
  with its reason and the remaining risk;
- relevant docs match the code and are reachable from the
  [`README.md` indexes](records.md);
- the PR links the owning Issue when there is one.

The PR describes the resulting behavior, what the tests prove, why the change
solves the problem, the documents updated, and limits, with links. Label it
`refactor` when it includes refactoring. Push only the feature branch, never the
default branch. Follow the repository's branch and PR conventions. Trigger no
production operation and expose no secret.

The human's experience should be: agree with PO, the team works on its own, a
finished PR arrives. Ask the human only for a real decision, missing
authorization, or a blocker the team cannot clear. Remove finished agents'
checkpoints ([pause and resume](checkpoints.md)).

## Draft release

Only the human starts this, by asking for a draft release. Nothing in the
feature flow leads into it.

1. **Organizer** lists what the release contains: merged PRs and their Issues
   since the last release, and the target environment.
2. **Technical Lead calls in Cybersecurity** for the
   [release review](../roles/cybersecurity.md#review-a-draft-release): the
   whole release, not one feature. It asks the human before reading production
   configuration, by file name, every time.
3. **If Cybersecurity finds a problem,** Technical Lead owns the fix and
   delegates it to Senior Developer or DevOps, then reviews it. Cybersecurity
   retests the bounded scope ([security report rules](owasp-security.md)).
   Senior QA tests affected regressions; QA Lead approves the evidence. At most
   two fix-and-retest rounds per finding, then the human decides. Unaffected
   approvals stay valid; nothing unverified is called passed.
4. **DevOps** creates a draft on the repository host with the version and tag
   the project's pattern gives, notes listing the Issues, a Deployment Plan, and
   a Rollback/Recovery Plan. A draft publishes nothing, creates no tag, and
   triggers no deployment.
5. **Organizer** adds to the draft notes QA's status and known issues and
   Cybersecurity's report: every finding, every requirement not followed with
   its remaining risk, and anything that could not be checked. Then tell the
   human the draft is ready and what the reports say.

The human alone accepts the remaining risk and publishes the release, or says
what to fix first. DevOps deploys only after the human's explicit authorization,
then verifies the deployment. Passing QA or security review is never that
authorization ([release lifecycle](release-lifecycle.md)).
