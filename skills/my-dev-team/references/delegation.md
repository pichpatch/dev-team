# Stateless delegation and review

## Real agents and portable hosts

Use the host's actual available sub-agent tools or already-authorized external
CLIs. A host may route between OpenCode, Claude Code, Codex, AGY, and other available
agents, but none is required merely because it appears in this list. Inspect the
installed tool/CLI help for supported invocation and resume mechanisms instead
of inventing command flags. Do not install tools or alter authentication as an
implicit part of routing work.

The role guides name no model; the [roster](roster.md) holds the human's
bindings. For a delegated role, use a real sub-agent and explicitly select an approved
model consistent with the roster and cross-provider routing policy. Do not silently inherit the parent session's
model when the roster has a binding. Respect any explicit model/provider choice
the human makes. If the bound model cannot be selected, report the limitation and
ask the human when a model choice is required; do not silently fall back to the
parent model. All models remain limited to those the human approved as safe for
private code ([contract](contract.md)). Record actual model identity when
observable, and `unknown` when it is not. Do not claim a named provider ran
because another model role-played it. If genuine delegation is unavailable,
report that limitation and preserve pending work rather than presenting
self-review as independent role approval.

Organizer dispatches owners; Leads determine Senior tasks and review their work.
If nested agent calls are unavailable, Organizer can dispatch a Senior on a Lead's
behalf using the Lead's task packet and return the output to that Lead. This is a
transport adaptation, not transfer of domain authority.

## Routing and invocation loop

Before substantial work, verify the runtime and worktree named in the task
packet: confirm the repository root, branch, current worktree status, allowed
write locations, and that the required Git operations are available. Confirm
the actual launch mode uses the documented no-sandbox invocation/profile for
that CLI or host, consistent with this guide and the [roster](roster.md). If the
runtime blocks an allowed worktree or Git operation, stop before implementation
and correct the invocation/configuration instead of repeatedly restarting
workers.

If a worker fails after starting, confirm the process has stopped, preserve its
last verified progress and diagnostic evidence in the assigned record, and
reconcile the same worktree's Git state. After correcting the cause, resume from
that record in the same worktree; do not restart from the full repository or
re-read unrelated context. Follow the detailed interruption and handover rules
in [local AI task delegation](ai-task-delegation.md).

PO is not in this table: the host carries it out itself in conversation with the
human. The three Leads are delegated as shown, and the human can also talk to
each of them directly ([orchestration](orchestration.md)). When a Lead or
Cybersecurity is engaged directly by the human, it stays in the conversation, on
the model its role command sets; do not spawn a same-role sub-agent merely to
satisfy the roster. DevOps is never engaged directly. When Organizer or Technical Lead delegates Cybersecurity or QA Lead on any task,
use a separate sub-agent, preferably on a different underlying model/provider
from the Organizer; different effort settings do not count. Preferred routing: Claude
Organizer -> GPT/Codex, then OpenCode if GPT is rate-limited; GPT/Codex
Organizer -> Claude, then OpenCode if Claude is rate-limited; OpenCode Organizer
-> Claude, then GPT/Codex as fallback. When no other provider is available or
within its limit, still delegate to a separate sub-agent on another approved
model, the Organizer's own provider if need be, and record that the review was
not cross-provider. Do not stop the work for this.
Verify approved bindings and actual cross-CLI support, and never self-approve. When the human directly
invokes Cybersecurity or QA Lead, the role stays in that conversation and is
exempt from mandatory sub-agent spawning; its own work is not independently
verified by that exception. Technical Lead may share Organizer context/model. Senior roles and Design Tester are
execution roles and always use real sub-agents with their roster bindings. Each
Lead reviews its own team's work; review is tied to the role, never to a model.

| Delegating owner | Execution role | Approval/reporting owner |
| --- | --- | --- |
| Organizer | Design Lead | Design Lead |
| Design Lead | Senior Designer(s), Design Tester | Design Lead |
| Organizer | Technical Lead | Technical Lead |
| Technical Lead | Senior Developer(s) | Technical Lead |
| Organizer | QA Lead | QA Lead |
| QA Lead | Senior QA(s) | QA Lead |
| Technical Lead | DevOps | Technical Lead |
| Technical Lead | Cybersecurity | Technical Lead; an overruled security requirement is reported to the human |

Do not add extra reviewer/worker roles. Assign investigation,
unit/integration work, E2E, and design critique to the appropriate existing role.
PO, DevOps, and Cybersecurity do not gain invented Senior tiers.

For each actual dispatch:

1. Identify the required role, relevant skills, available execution mechanism,
   authorized model choice, and scope. Construct the task packet below.
2. Invoke the real tool/CLI and retain its task/session handle for this run. Pass
   role instructions and durable artifact references explicitly. Do not transfer
   raw credentials, unrelated conversation, or the Lead's private reasoning.
3. Continue independent work or await progress using the host's supported wait/
   status mechanism. A submitted job is not completed work. Do not open the final
   PR while required agents/reviews are still running or uncollected.
4. Receive the artifacts and execution result; send them to the responsible owner
   for review. A Senior returns delivered work, not an approval. Record tool errors,
   timeouts, and missing outputs as incomplete rather than inventing a verdict.
5. On rejection, return actionable corrections to the same Senior or an explicitly
   reassigned instance, with updated artifact context. On approval, the owner records
   completion and evidence on the owning Issue when one exists, otherwise in the PR or linked repository records, and the next dependent stage can proceed.

Keep handoffs lean: send relevant diffs, affected files, findings, decisions,
requirements and test evidence, not the full conversation. Preserve unaffected
approvals and recheck changed scope plus dependencies justified by risk.
Reuse a live agent when useful, but do not assume it remembers decisions. Rebuild
the packet from persistent records when changing context/model or resuming. Respect
tool/runtime limits; queue excess work. If repeated attempts make no progress,
have the owner diagnose the blocker rather than launching an endless review loop.
Ask the human only when resolving it requires a human decision or authorization.

## Task packet

Use [the handoff template](../assets/handoff.md) as needed. Each invocation gets:

- Assigned role and the absolute path to this skill's entrypoint and role guide.
- Applicable additional skills and where to load them; missing required skills
  are a reported dependency, not something an agent silently invents.
- Owning feature Issue URL/identifier when one exists; otherwise the descriptive branch name and task purpose.
- Repository/worktree path, relevant branch/revision and uncommitted work context.
- The documents to start from: the application `README.md` and the module
  documents for the task, plus the requirements, designs, and verification
  evidence it needs. Name them, so the agent does not search for them.
- For security-scoped Senior Developer or Senior QA assignments, include the
  applicable Cybersecurity `SEC-` requirement and its concrete input/expected-
  outcome examples intact. Do not replace them with a lossy summary; preserve
  valid/control cases and the specified storage, output, and side-effect
  expectations.
- The objective and a measurable definition of done.
- Concrete task, constraints, scope/files owned, forbidden changes,
  dependencies, prerequisite approvals, and expected outputs.
- Milestones and deliverables, with the tests and evidence expected for each.
- Decision owner/receiving Lead, reporting route, escalation route, and the
  existing approvals that apply.
- The absolute path of its `.AI` progress record and checkpoint, and the record
  to resume from if there is one
  ([local AI task delegation](ai-task-delegation.md)).

Persist the meaningful assignment and decisions in the owning Issue (when one exists) or repository records before
handoff. A transient packet may carry links and execution details, but must not be
the only copy of important knowledge. For active assignments, maintain the local `.AI` work instruction and progress
record described in [local AI task delegation](ai-task-delegation.md); separate
interruption checkpoints are needed only when work stops unexpectedly. The parent must not assume a child inherited conversation context,
even if a tool can technically fork it.

## Split and integrate

A Lead may use two or more Seniors on independent tasks and different models.
Give each a clear file/scope boundary, inputs, outputs, and integration dependency.
Avoid concurrent edits to the same files or Issue body; serialize shared changes
or use isolated worktrees with explicit integration responsibility. Respect the
host's concurrency limit; queue extra work without creating not-started checkpoints.

Seniors return artifact paths, changes, test/research evidence, limitations,
remaining work, and evidenced challenges. They do not update the Issue (if any) or approve
their own work. The Lead inspects outputs and relevant evidence, integrates them,
and approves or returns specific corrections. Verify the integrated result where
combination can change behavior; individual task success is not integration proof.

Approved scope is complete. The Lead records the outcome on the owning Issue if present, otherwise on the PR or linked repository records, and routes
the durable handoff. A rejected scope remains unfinished. Correct Senior challenges
should change the Lead's decision when warranted and count positively in evaluation.

Use a concise result record: role/instance, actual model if observable, scope and
revision/artifacts, outcome, evidence, material findings/decisions, remaining work,
and receiving owner. Owners may record approved, changes requested, blocked, or
reasoned not applicable; Seniors report delivered or unfinished work. Keep tool
completion, domain approval, and QA's tested outcome distinct. These are record
fields, not another status ceremony after approval.

## Worktrees keep secrets out of delegated work

The main checkout is the human's workspace and may hold real secrets in ignored
files such as `.env`. A git worktree contains tracked files only, so it starts
without them. All repository writes for a feature happen in worktrees, with one
exception: documents agreed live with the human before the Issue exists. PO and
the Leads in conversation commit and push those on the default branch in the main
checkout ([talking to the Leads](orchestration.md)).

```text
projects/
  my-app/                                     main checkout: the human's, real `.env`
  worktrees/my-app/
    meetup-create-event/                      feature branch: Leads integrate here
    meetup-create-event-senior-developer-1/   `.env.example` only (fake values)
    meetup-create-event-senior-qa/            `.env.test` (test-only credentials)
```

- Technical Lead creates the worktrees, outside the repository, at
  `../worktrees/{repo}/{feature-slug}` for the feature branch and
  `../worktrees/{repo}/{feature-slug}-{instance}` for each Senior, unless the
  project already has a convention. One worktree and branch per agent instance.
- Do not switch branches or leave uncommitted changes in the main checkout. The
  one exception is work the human explicitly authorized there
  ([direct-checkout exception](ai-task-delegation.md)); it may leave changes
  uncommitted, and says so to the human.
- Never copy a real env file into a worktree. When the work needs runnable
  configuration, provide values derived from `.env.example`, or a `.env.test`
  holding test-only credentials the human supplied for that purpose. Include a
  local connection for the worker's [own database](stack.md) only when the task
  needs database-backed implementation or verification.
- **No OS sandbox.** No CLI runs in an OS sandbox, Codex included: each worker
  is kept to its worktree by the worktree and its task packet, the same way for
  Codex, Claude, OpenCode, and Antigravity. This lets every worker reach the
  local database, commit on its own branch, and write its `.AI` record, and lets
  any host start the others as sub-agents. The [roster](roster.md) gives each
  CLI's start command.
- Name the worktree in the task packet. A Senior stays inside its worktree and
  does not read the main checkout, other worktrees, or the user's home directory.
  The one exception is its own [checkpoint](checkpoints.md) file under the main
  checkout's `.AI/`, at the path the packet gives.
- Other Leads ask Technical Lead for a worktree when their Seniors write to the
  repository. When a Lead cannot run git itself, Organizer creates the worktree
  on that Lead's instruction.
- After approved work is integrated into the feature branch, automatically remove
  the worker's worktree and local worker branch once its changes are preserved,
  its process is stopped, and no unfinished work/review needs it. Follow the
  safeguards in [local AI task delegation](ai-task-delegation.md).

Branches, commits, and pushing:

- Feature branches use `feat/{issue-number}-{slug}`. Issue-free bugs and minor changes
  use `fix/{descriptive-slug}` without an issue number. Each Senior's branch is
  the owning branch name plus `-{instance}`, unless the project already has a convention.
- A Senior commits its own work on its own branch, in small commits that
  reference the Issue when one exists; otherwise use the descriptive task name. It does not merge, push, or touch another branch.
- The responsible Lead reviews. Technical Lead then merges the approved branches
  into the feature branch and verifies the combined result.
- Organizer pushes only the feature branch and opens the PR.
- Nobody commits to the default branch except PO, Cybersecurity, and the Leads,
  and only for documents that have no effect on code (the documents agreed live
  with the human, described above, and other project documents). Each pushes
  its own commits; nothing else is ever pushed to the default branch. Nobody force-pushes or rewrites history that has been pushed.
- Do not leave integrated worker worktrees waiting for the PR merge. Remove the
  feature worktree after feature-branch verification when no review still needs it,
  retaining the feature branch for PR delivery. After the human merges the PR,
  Technical Lead or Organizer on its behalf removes the now-obsolete local feature
  branch when safe. Follow [local AI task delegation](ai-task-delegation.md).

A Lead can reach the main checkout and its real files. The human accepted that
exposure; the contract's ask-before-reading rule still applies to Leads. A
worktree keeps secrets out of a Senior's working directory but does not stop a
process from opening another path, so the rule matters for Seniors too.

## Performance evidence

Leads maintain `docs/evaluation/{feature-slug}-{role}-{model}.html` using
[the evaluation template](../assets/evaluation.html) where helpful. Evaluate actual
work: correctness, understanding, independence, reasoning quality visible in
decisions, research/evidence, risks discovered, introduced complexity, standards,
corrections needed, useful challenges, deliverable quality, and observable efficiency/cost.

Link artifacts and concrete review findings; capture meaningful Senior ↔ Lead
discussion as concise claims, evidence, responses, and outcomes. Do not store
chain-of-thought or whole transcripts. Distinguish model performance from unclear
instructions, missing tools, or environment failures. Never invent cost, timings,
scores, or a model identity that is not observable.

Use filesystem-safe slugs; preserve the full observed role/model identity inside
the report. If normalization causes a collision, disambiguate the model slug.
For repeated work by the same feature/role/model, update the existing report and
retain task/revision context instead of creating unrequested evaluation files.
