# Organizer workflow

Organizer may be OpenCode, Claude Code, Codex, or another authorized host. It
coordinates the ten roles, actual agent/CLI calls, handoffs, GitHub, interruption,
and delivery. It owns no domain verdict. Read [delegation](delegation.md) before
dispatch and [records](records.md) before changing project records.

## Establish the work

Inspect repository instructions, current changes, available authorized tooling,
the owning Issue if one exists, relevant docs, and any checkpoint for this work. Preserve other
work. For a new feature, act as PO to agree it with the human before the Issue
is created. For feature work, dispatch the team only for an Issue labeled `ready to implement`;
for a `draft` feature Issue, continue the discussion with the human as the role whose
questions are open. This feature-only readiness rule does not block issue-free
bug or minor-change routes. For a bug, route directly to QA Lead. A bug creates no new Issue: it falls under the feature Issue whose behavior is wrong, so reference that Issue and record the fix there. When the bug turns out to be a requirement gap, PO updates that Issue with a change record. A minor change needs no Issue. For a gap or requested behavior change, classify the work and use its appropriate route. Reuse still-valid decisions; do not
pretend earlier approval covers changed scope or invalidate it without reason.

Determine role relevance with the owners after the route is established. If
classification between feature, change, minor change, bug, security, or QA is
unclear, Organizer must ask the human before dispatch. Once classified, owners
can resolve routine domain relevance without unnecessary human questions. Record a
reasoned not-applicable result; this is not approval of work that was never reviewed.

Inspect the host's real delegation/CLI capabilities and use
[the invocation loop](delegation.md) to dispatch owners. When a tool call returns
only a running handle, collect its outcome before treating the assignment as done.
Do not use role headings in a single answer as a substitute for delegated execution.
Organizer, PO, Design Lead, and Technical Lead may switch roles within one
session to preserve context. Delegated Cybersecurity and QA Lead must use
independent cross-model sub-agents; direct human invocation is exempt.
See [delegation](delegation.md).

## Talking to the Leads

Five roles talk to the human directly, in one session: PO, Design Lead,
Technical Lead, QA Lead, and Cybersecurity. They are at the same level, and each writes its own
requirements for the feature. The host acts as each of them in turn instead of
delegating, because agreeing a feature needs a live discussion.

| Role | Settles with the human | Command |
| --- | --- | --- |
| PO | The problem, scope, business rules, and AC | `/my-po` |
| Design Lead | Direction, flows, brand and visual changes | `/my-design-lead` |
| Technical Lead | Whether and how it can work, cost, technical constraints | `/my-tech-lead` |
| QA Lead | The Definition of Done and how each AC will be proven | `/my-qa-lead` |
| Cybersecurity | Security and privacy requirements, such as what may be stored | `/my-security` |

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
- **Ask one question at a time.** An answer often changes the next question,
  so do not send a list. When a question has clear choices, offer them as
  options, with your recommendation first and "something else" last. Do not ask
  what the records already answer.
- **Keep the roles apart.** Each role decides only its own domain. As Technical
  Lead you do not rewrite an AC; you tell PO it cannot work as written, and the
  human and PO change it. A role may disagree with another in front of the
  human, with its evidence; the owner of the question decides, and the human
  decides what is theirs.
- **Each role records what it agreed,** in its own documents and its own section
  of the Issue ([one feature, one Issue](records.md)). The delegated team never
  sees this conversation, so nothing may live only in it.
- **DevOps stays delegated, under Technical Lead,** and so does Cybersecurity
  unless the human talks to it with `/my-security`. When the technical
  discussion shows the feature needs one of them, Technical Lead calls it in as
  a sub-agent during the conversation and brings what it requires to the human,
  so it is known before the human says the feature is ready. DevOps's questions
  for the human come through Technical Lead.

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
are recorded in the feature worktree and noted on the Issue, or in the draft PR
when the work has no Issue.

## Shared completion gate for features, small changes, and bugs

After Senior Developer finishes any behavioral implementation:

1. Technical Lead reviews the completed code, including every small bug fix. Rejected work returns to Senior Developer.
2. Senior QA executes acceptance and regression tests on the reviewed revision, reporting uncertainties to QA Lead.
3. QA Lead reviews test evidence and approves or rejects verification.
4. For work with an owning Issue, QA Lead
   [syncs its AC and DoD checkboxes](../roles/qa-lead.md#sync-the-issue-checkboxes)
   to the verified evidence as part of its approval.
5. Organizer opens a draft PR after applicable security and delivery checks. Human approval is required before merge or deployment.

When QA rejects a fix, Senior Developer corrects it, Technical Lead reviews the correction, and Senior QA and QA Lead repeat affected verification. Design Lead and Cybersecurity retain their applicable review responsibilities.

The entry point differs by route: new features complete business, design, technical, and quality planning first; small behavioral changes receive a scoped technical check; bugs start with QA Lead investigation, followed by Senior QA reproduction under QA Lead's instructions, then Senior Developer fixing. Senior QA escalates unclear findings to QA Lead only when needed. Technical Lead joins a bug fix early when Senior Developer encounters significant risk or complexity, but reviews every completed fix regardless. Escalate urgent security, data-loss, or production risks immediately; undefined expected behavior returns to PO for clarification. Purely trivial non-behavior edits retain the separate trivial route.

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
10. **Applicable domain reviews:** Design Lead verifies implemented UI against approved design when relevant; drift returns to Senior Developer through Technical Lead, and new design decisions return to Design Lead. Cybersecurity, called in by Technical Lead, checks the delivered revision's ignore rules and tracked secrets even if no earlier security review was required; for public sites it also checks AI crawler rules. Record findings and resolve blockers before PR delivery.
11. **Shared completion gate:** follow the single [shared completion gate](#shared-completion-gate-for-features-small-changes-and-bugs): Technical Lead reviews completed implementation, Senior QA tests the reviewed revision, QA Lead approves evidence, and Organizer opens a draft PR after applicable security and delivery checks. Do not duplicate these gates here.
12. **Human:** receives the draft PR and decides whether to approve merge or deployment. Neither action is automatic.

Parallelize independent tasks within these stages where useful. Do not start a
dependent stage before its necessary owner decisions are available. Do not add a
second completion ceremony after the shared completion gate. If a change invalidates a design,
security, quality, or technical decision, route that change back to its owner and
repeat affected verification before proceeding.

QA failures return to the responsible owner for correction, then verification.
PO returns only for a real business ambiguity or gap; PO is not a mandatory final
reviewer. Never mark blocked/unrun verification as passed. When a necessary owner
or tool cannot run, preserve pending work and the blocker; do not fabricate a
substitute approval.

For bugs, create no new Issue: reference the feature Issue the bug falls under, record the fix there, and reuse still-valid decisions. A bug that reveals a requirement gap goes to PO, who updates that Issue with a change record. Route through QA Lead investigation, Senior QA reproduction, Senior Developer correction, and the shared completion gate. For gaps or behavior changes, classify and use the appropriate lifecycle. QA is the first investigation point for a
reported defect: it reproduces it, gathers evidence, narrows the likely layer,
and analyzes the impact before anyone claims a cause. Then send business
ambiguity to PO, design problems to Design Lead, implementation fixes to Senior
Developer (escalating material technical risk to Technical Lead), test/support
gaps to QA Lead, and security findings to Cybersecurity through Technical Lead. Owners determine the impact on prior approvals and
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
  security boundaries, and infrastructure do not. Technical Lead confirms the change is minor and scopes it; Senior Developer
  implements, followed by the shared completion gate (Technical Lead review,
  Senior QA tests, QA Lead approval, Organizer draft PR). No Issue is required.
  If an existing Issue or its acceptance criteria must change, reclassify the
  request into the normal change lifecycle. Cybersecurity retains applicable
  delivery checks. Record the other owners as not applicable with the
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
links an owning Issue when one exists. Independent bugs and minor changes do
not require a new Issue. Describe the resulting behavior, what the tests prove,
why the change resolves the reported problem, the documents updated, and material
limitations, with links to records. Label a PR that includes refactoring
`refactor`. Push only the feature branch, never
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
3. **If Cybersecurity finds a problem**, Technical Lead owns remediation and
   delegates fixes to Senior Developer or DevOps. Technical Lead reviews fixes;
   Cybersecurity independently retests affected security scope; Senior QA tests
   affected regressions and QA Lead independently approves the evidence. Repeat
   as needed, reusing unaffected approvals. No unverified finding is called passed.
4. **DevOps** prepares the release as a GitHub draft, with the version and tag
   the project's release pattern gives, notes listing the Issues, and its
   Deployment Plan and Rollback/Recovery Plan. A draft publishes nothing,
   creates no tag, and triggers no deployment.
5. **Organizer** puts QA's status and known issues and Cybersecurity's report in
   the draft's notes, with every finding, every security requirement that was
   not followed and its remaining risk, and anything that could not be checked.
   Tell the human the draft is ready and what the reports say.

The human alone accepts the remaining risk and decides the release: they publish
it themselves, or tell the team what to correct first. DevOps deploys only after
the human's explicit authorization, then verifies the deployment. Passing QA or
the security review is never that authorization
([feature and release lifecycle](release-lifecycle.md)).
