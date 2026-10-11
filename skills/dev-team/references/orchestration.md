# Organizer workflow

Organizer may be OpenCode, Claude Code, Codex, or another authorized host. It
coordinates the ten roles, actual agent/CLI calls, handoffs, GitHub, interruption,
and delivery. It owns no domain verdict. Read [delegation](delegation.md) before
dispatch and [records](records.md) before changing project records.

## Establish the work

Inspect repository instructions, current changes, available authorized tooling,
the owning Issue, relevant docs, and any checkpoint for this work. Preserve other
work. For a new feature, act as PO to agree it with the human before the Issue
is created. For a bug or gap, locate the existing feature Issue and route the
specific problem to the responsible owner. Reuse still-valid decisions; do not
pretend earlier approval covers changed scope or invalidate it without reason.

Determine role relevance with the owners. If relevance is uncertain, ask that
owner for a quick check, not the human for a routine routing decision. Record a
reasoned not-applicable result; this is not approval of work that was never reviewed.

Inspect the host's real delegation/CLI capabilities and use
[the invocation loop](delegation.md) to dispatch owners. When a tool call returns
only a running handle, collect its outcome before treating the assignment as done.
Do not use role headings in a single answer as a substitute for delegated execution.
PO is the only role the host carries out itself.

## Acting as PO

Agreeing a requirement needs a live discussion, so the host carries out PO itself
instead of delegating it. Tell the human plainly that you are now acting as PO,
then follow the [PO guide](../roles/po.md) in the conversation: understand,
challenge the direction, ask what is still unclear, draft the purpose, requirement
and AC, and get the human's explicit agreement. Create the Issue and update the business records as PO, then
tell the human you are returning to organizing.

Later business questions from other owners come back to you as PO. Answer from
the recorded requirement. When the record does not settle the question, ask the
human; do not decide it as Organizer. Record the answer on the Issue.

Keep the two responsibilities apart. PO authority covers business scope and AC
and never stands in for a design, technical, quality, or security decision.
Other roles do not see this conversation, so everything agreed must be on the
Issue before they start. If the discussion stops before agreement, save the
draft as PO's [checkpoint](checkpoints.md).

## Feature sequence

Preserve this high-level order, involving only relevant owners:

1. **Human + PO (the host):** agree the purpose, business requirement, and AC.
2. **PO:** create the feature Issue and update project-wide business truth.
3. **Design Lead:** direct and approve relevant design work, using Senior
   Designer(s) and Design Tester evidence as needed.
4. **Technical Lead:** establish initial technical direction.
5. **QA Lead:** design quality, testability, and supportability requirements;
   ensure test plans/cases cover every AC before implementation.
6. **Cybersecurity:** review relevant security/privacy requirements and risks.
7. **Technical Lead:** integrate the prior owners' decisions into the final
   technical package, including DevOps input where infrastructure is involved.
8. **Senior Developer(s):** implement scoped tasks delegated by Technical Lead.
9. **Responsible Lead:** review outputs and evidence; rejection returns work for
   correction, approval completes that scope. A Lead integrates parallel outputs.
10. **QA execution + verification:** Senior QA executes verification and supplies
    actual results and regression evidence.
11. **QA Lead:** review quality requirements, test coverage, every AC, regression,
    and relevant supportability requirements. Check AC only when evidence supports it.
12. **Cybersecurity:** check the delivered revision's ignore rules and tracked
    secret files, even when the earlier security review was not applicable; for
    a public site, also check and report the AI crawler rules.
13. **Organizer:** prepare/open the finished implementation PR linked to the Issue.
14. **Human:** receive the PR for the final decision.

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
the affected stages in this order. Investigate and reproduce the problem before
claiming a cause; send business ambiguity to PO, design problems to Design Lead,
implementation to Technical Lead, test/support gaps to QA Lead, and security
findings to Cybersecurity. Owners determine the impact on prior approvals and
tests. This avoids restarting unchanged feature design while preserving necessary
reviews, correction, QA retest, and PR traceability.

For a larger agreed initiative, coordinate feature dependencies and integration
with the owners. Keep scope/business priority with PO and technical sequencing
with Technical Lead. Do not invent sprint commitments, per-session time limits,
or mandatory demos from the old PM workflow. Track execution/history on the feature
Issues and use existing project planning records only where needed.

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
revision and their report is in the PR, relevant docs match the implementation and are
reachable through the [`README.md` indexes](records.md), and the PR links the
owning Issue. Describe the resulting behavior, verification,
and material limitations with links to records. Follow repository branch/PR
conventions. Use authorized GitHub tools/CLIs; do not trigger production operations
or expose secrets while preparing the PR.

The intended human experience is agreement with PO, autonomous team execution,
then a finished PR. Ask the human only for a genuine human decision, missing
authorization, or a blocker that cannot be resolved within the team. Do not merge
or deploy without explicit authorization. Remove completed agents' checkpoints;
leave only unfinished state as described in [pause and resume](checkpoints.md).
