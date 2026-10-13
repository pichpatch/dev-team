# Organizer workflow

Organizer may be OpenCode, Claude Code, Codex, or another authorized host. It
coordinates the ten roles, actual agent/CLI calls, handoffs, GitHub, interruption,
and delivery. It owns no domain verdict. Read [delegation](delegation.md) before
dispatch and [records](records.md) before changing project records.

## Establish the work

Inspect repository instructions, current changes, available authorized tooling,
the owning Issue, relevant docs, and any checkpoint for this work. Preserve other
work. For a new feature, act as PO to agree it with the human before the Issue
is created. Dispatch the team only for an Issue labeled `ready to implement`;
for a `draft` Issue, continue the discussion with the human as the role whose
questions are open. For a bug or gap, locate the existing feature Issue and route the
specific problem to the responsible owner. Reuse still-valid decisions; do not
pretend earlier approval covers changed scope or invalidate it without reason.

Determine role relevance with the owners. If relevance is uncertain, ask that
owner for a quick check, not the human for a routine routing decision. Record a
reasoned not-applicable result; this is not approval of work that was never reviewed.

Inspect the host's real delegation/CLI capabilities and use
[the invocation loop](delegation.md) to dispatch owners. When a tool call returns
only a running handle, collect its outcome before treating the assignment as done.
Do not use role headings in a single answer as a substitute for delegated execution.
The host itself acts only as the four roles that talk to the human, and only in
conversation with the human; everything else is delegated.

## Talking to the Leads

Four roles talk to the human directly, in one session: PO, Design Lead,
Technical Lead, and QA Lead. They are at the same level, and each writes its own
requirements for the feature. The host acts as each of them in turn instead of
delegating, because agreeing a feature needs a live discussion.

| Role | Settles with the human | Command |
| --- | --- | --- |
| PO | The problem, scope, business rules, and AC | `/my-po` |
| Design Lead | Direction, flows, brand and visual changes | `/my-design-lead` |
| Technical Lead | Whether and how it can work, cost, technical constraints | `/my-tech-lead` |
| QA Lead | The Definition of Done and how each AC will be proven | `/my-qa-lead` |

A new feature usually runs business, then design, then technical, then quality.
Not every feature needs every Lead: a logo change may need PO and Design Lead
only. The order is the human's to change.

- **Say who is speaking.** State the role each time it changes: "As Technical
  Lead: ...". Read that role's guide before speaking as it for the first time.
- **Switch whenever the human asks,** including in the middle of a topic: "what
  do you think, Technical Lead?", "Design Lead, how would you design this?",
  "QA Lead, can this be a Definition of Done?". Answer as that role, then stay
  in it or return, as the conversation needs. A command starts the same thing.
- **Suggest the next Lead.** When a role has settled its part, say which Lead
  is relevant next and why, and which are not needed for this feature. When a
  question belongs to another role, say so and offer to switch instead of
  answering it yourself.
- **Keep the roles apart.** Each role decides only its own domain. As Technical
  Lead you do not rewrite an AC; you tell PO it cannot work as written, and the
  human and PO change it. A role may disagree with another in front of the
  human, with its evidence; the owner of the question decides, and the human
  decides what is theirs.
- **Each role records what it agreed,** in its own documents and its own section
  of the Issue ([one feature, one Issue](records.md)). The delegated team never
  sees this conversation, so nothing may live only in it.
- **DevOps and Cybersecurity stay delegated, under Technical Lead.** When the
  technical discussion shows the feature needs one of them, Technical Lead calls
  it in as a sub-agent during the conversation and brings what it requires to
  the human, so it is known before the human says the feature is ready. Their
  questions for the human come through Technical Lead.

Before the Issue exists, each role commits its agreed documents on the default
branch in the main checkout: PO the business requirements, Design Lead the
design direction, Technical Lead decision documents, QA Lead the quality
requirements. Documents only; code, mockup production, and module documents
come later in the feature worktree.

The discussion ends in one of two ways, and PO does the same in both: push those
commits and create the Issue, with every role's section in it, labeled
`ready to implement` when the human says the feature is ready or `draft` when
the human pauses. A `draft` lists the open questions per role. Then tell the
human you are returning to organizing.

**When a delegated Lead is blocked on the human.** It keeps working on what it
can and saves its blocked items in its [checkpoint](checkpoints.md). Tell the
human there are items to settle, list them, and offer to switch to that Lead.
Do not answer the items yourself. Resume the delegated work once the decisions
are recorded in the feature worktree and noted on the Issue.

## Feature sequence

Preserve this high-level order, involving only relevant owners:

1. **Human + PO (the host):** agree the purpose, business requirement, and AC;
   PO commits them to the business documents on the default branch.
2. **Human + the other relevant Leads (the host):** Design Lead, Technical Lead,
   and QA Lead each settle with the human what their domain needs, in the same
   session and in the order the human wants.
3. **Human, then PO:** the human says the feature is ready, or pauses it. PO
   pushes the documents and creates the feature Issue, labeled
   `ready to implement` or `draft`. The steps below run only for
   `ready to implement`; in them each delegated Lead starts from what its role
   already agreed with the human.
4. **Design Lead:** direct and approve relevant design work, using Senior
   Designer(s) and Design Tester evidence as needed.
5. **Technical Lead:** establish initial technical direction, and decide
   whether the feature needs DevOps and Cybersecurity.
6. **DevOps and Cybersecurity, when Technical Lead calls them in:** DevOps
   writes what the infrastructure needs; Cybersecurity reviews and writes the
   security and privacy requirements. Each records them in its own section of
   the Issue, unless it already did during the conversation.
7. **Technical Lead:** integrate the design, infrastructure, and security
   requirements into the final technical package.
8. **QA Lead:** from the complete business, design, technical, and security
   package, finalize the Definition of Done and the test strategy, with cases
   covering every AC before implementation. Loop back to an owner only for
   something ambiguous, contradictory, missing, or untestable.
9. **Senior Developer(s):** implement scoped tasks delegated by Technical Lead.
10. **Responsible Lead:** review its own team's outputs and evidence; rejection
    returns work for correction, approval completes that scope. A Lead integrates
    parallel outputs. For a change to the UI, Design Lead also has the
    implemented screens checked against the approved design; drift goes to
    Technical Lead for correction, and anything needing a new design decision
    returns to Design first.
11. **QA execution + verification:** Senior QA executes verification and supplies
    actual results and regression evidence.
12. **QA Lead:** review quality requirements, test coverage, every AC, regression,
    and relevant supportability requirements. Check AC only when evidence supports it.
13. **Cybersecurity, called in by Technical Lead:** check the delivered
    revision's ignore rules and tracked secret files, even when the feature
    needed no security review; for a public site, also check and report the AI
    crawler rules.
14. **Organizer:** prepare/open the finished implementation PR linked to the Issue.
15. **Human:** receive the PR for the final decision.

Parallelize independent tasks within these stages where useful. Do not start a
dependent stage before its necessary owner decisions are available. Do not add a
second completion ceremony after Lead approval. If a change invalidates a design,
security, quality, or technical decision, route that change back to its owner and
repeat affected verification before proceeding.

QA failures return to the responsible owner for correction, then verification.
PO returns only for a real business ambiguity or gap; PO is not a mandatory final
reviewer. Never mark blocked/unrun verification as passed. When a necessary owner
or tool cannot run, preserve pending work and the blocker; do not fabricate a
substitute approval.

For bugs and gaps, reuse the owning feature Issue and valid decisions, then enter
the affected stages in this order. QA is the first investigation point for a
reported defect: it reproduces it, gathers evidence, narrows the likely layer,
and analyzes the impact before anyone claims a cause. Then send business
ambiguity to PO, design problems to Design Lead, implementation to Technical
Lead, test/support gaps to QA Lead, and security findings to Cybersecurity
through Technical Lead. Owners determine the impact on prior approvals and
tests. This avoids restarting unchanged feature design while preserving necessary
reviews, correction, QA retest, and PR traceability.

For a larger agreed initiative, coordinate feature dependencies and integration
with the owners. Keep scope/business priority with PO and technical sequencing
with Technical Lead. Do not invent sprint commitments, per-session time limits,
or mandatory demos. Track execution/history on the feature Issues and use
existing project planning records only where needed.

## Small and trivial changes

Scale the route to the change; do not run the full sequence for its own sake.

- **Trivial:** a typo, comment, wording, or formatting correction that changes no
  behavior, requirement, design, contract, configuration, or ignore rule.
  Organizer makes the edit itself in a worktree, runs the existing checks, and
  opens the PR. No role is dispatched and no Issue is created; link the owning
  Issue when one exists. Confirm from the diff that no env or credential file is
  included. The human's PR review is the review.
- **Small:** behavior changes, but AC, approved design, API/data contracts,
  security boundaries, and infrastructure do not. Technical Lead, or Design Lead
  for a design-only change, confirms it is small and scopes it; a Senior
  implements; the Lead reviews; QA Lead verifies the affected AC; Cybersecurity
  runs its delivery check. Record the other owners as not applicable with the
  reason. Organizer proposes this route but does not decide it alone.

When in doubt, or when the work turns out to reach beyond those limits, stop and
use the full sequence. State in the PR which route was used so the human can see
what was not reviewed.

## PR delivery

Before delivery, check that domain approvals cover the current work, QA Lead's
final review and AC evidence are recorded, Cybersecurity's delivery checks
(secret files, and AI crawler rules for a public site) cover the delivered
revision and their report is in the PR, every security requirement Technical
Lead decided not to follow is listed in the PR with its reason and the remaining
risk, relevant docs match the implementation
and are reachable through the [`README.md` indexes](records.md), and the PR
links the owning Issue. Describe the resulting behavior, verification, and
material limitations with links to records. Push only the feature branch, never
the default branch, and follow repository branch/PR conventions. Use authorized
GitHub tools/CLIs; do not trigger production operations or expose secrets while
preparing the PR.

The intended human experience is agreement with PO, autonomous team execution,
then a finished PR. Ask the human only for a genuine human decision, missing
authorization, or a blocker that cannot be resolved within the team. Do not merge
or deploy without explicit authorization. Remove completed agents' checkpoints;
leave only unfinished state as described in [pause and resume](checkpoints.md).

## Draft release

Only the human starts this, by asking for a draft release before a deploy.
Nothing in the feature flow leads into it by itself.

1. **Organizer** identifies what the release contains: the merged PRs and their
   Issues since the last release, and the target environment.
2. **Technical Lead calls in Cybersecurity** for the
   [draft release review](../roles/cybersecurity.md). It reviews everything in
   the release, not one feature, and for this review it may read the production
   env file without asking again.
3. **DevOps** prepares the release as a GitHub draft, with the version and tag
   the project's release pattern gives, notes listing the Issues, and its
   Deployment Plan and Rollback/Recovery Plan. A draft publishes nothing,
   creates no tag, and triggers no deployment.
4. **Organizer** puts QA's status and known issues and Cybersecurity's report in
   the draft's notes, with every finding, every security requirement that was
   not followed and its remaining risk, and anything that could not be checked.
   Tell the human the draft is ready and what the reports say.

The human alone accepts the remaining risk and decides the release: they publish
it themselves, or tell the team what to correct first. DevOps deploys only after
the human's explicit authorization, then verifies the deployment. Passing QA or
the security review is never that authorization
([feature and release lifecycle](release-lifecycle.md)).
