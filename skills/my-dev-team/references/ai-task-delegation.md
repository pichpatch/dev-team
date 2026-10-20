# Local .AI task delegation, progress, and handover

This extends [delegation](delegation.md) and [checkpoints](checkpoints.md). GitHub Issues and approved repository documents remain authoritative for business requirements, feature scope, workflows, acceptance criteria, and permanent decisions. The ignored `.AI/` directory is a **temporary local execution system**: assignments, worker-owned plans, progress, evidence pointers, and handovers. It is not a second requirements tracker. Nothing in `.AI/` is committed or pushed.

## Location and ownership

- `.AI/<feature-slug>/` is the AI team's **kanban board** for one feature; the GitHub Issue only shows the feature's status. Each task is a card: the worker's own record file. Organizer keeps the board at `<main-checkout>/.AI/<feature-slug>/README.md`: the owning Issue and revision, the feature branch, receiving Leads, review gates, and one row per card with its role and instance, the model running it, its dependencies, and its status.
- Card statuses are `todo`, `in-progress`, `blocked`, `review`, and `done`. A Lead creates a card as `todo` with its assignment. The worker moves its own card: `in-progress` when it starts, `blocked` with the reason when it cannot continue, `review` when it delivers. Only the receiving Lead moves a card to `done`, on approval, or back to `in-progress` with corrections. The worker writes the status at the top of its own record; Organizer mirrors every change into the board row, so two workers never edit the same file.
- Each delegated worker or reviewer has its own file `<main-checkout>/.AI/<feature-slug>/<role>-<instance>.md`, with a stable identifier even when the executing model changes. These paths are **outside** the agent's worktree; they must be passed explicitly as absolute paths. Do not assume ignored `.AI` files are shared between worktrees.
- The assigning Lead owns the immutable assignment section (or issues a revised version). The worker owns only its execution-plan, progress, evidence, and blocker sections. Organizer coordinates ownership and handovers; it does not make technical or domain decisions.
- A worker may write only its assigned record, not another worker's or the feature coordination record. Organizer or the owning Lead updates shared coordination records, serializing concurrent changes. Do not put secrets, credentials, full conversation transcripts, or hidden reasoning in `.AI`.
- Create records only for real assigned work; remove them when the feature is safely closed. Preserve GitHub Issue and repository decisions independently.

## Feature authorization and branch creation

The human initiates or approves a feature and its business scope; Organizer must not invent or expand product requirements. The PO records approved requirements and acceptance criteria in GitHub. Once the human authorizes execution, **Technical Lead creates the feature branch** (`feat/{issue-number}-{slug}`), the feature worktree and the worker worktrees, breaks the work into tasks, and delegates them. Organizer creates the feature coordination record, and runs the Git commands on Technical Lead's instruction only when Technical Lead cannot run them itself. Delegated workers never create a new feature or commit directly to the default branch.

## Assignment packet — actionable instructions, not a generic checklist

Before dispatch, the assigning Lead writes the [task packet](delegation.md#task-packet) into the worker's record as its assignment. It carries enough detail to preserve intent across models, without dictating every implementation command.

The worker reads the assignment **before starting** and creates its own execution checklist under it. Use milestone states `pending`, `in-progress`, `blocked`, `completed`. Before starting a meaningful milestone, mark it in progress; on completion, record concise evidence (file paths, commit/diff references, test results, migration identifiers where applicable) and mark it completed. Update at meaningful boundaries, not after every shell command. Workers may refine their execution plan but may not silently change the assignment, GitHub requirements, or acceptance criteria. Escalate changed scope or blocked dependencies to the owning Lead; requirement changes follow PO/GitHub approval.

A completed implementation is **delivered for review**, not self-approved. Design Tester, Senior QA, QA Lead, and Cybersecurity receive independent assignments and checklists as applicable, grounded in the original GitHub requirements and actual artifacts, not only the implementer's claims. The owning Lead accepts or requests changes, and Organizer updates the coordination record. Each dependent stage starts only after its required predecessor and approval gates complete.

## Model fallback and safe recovery

- Before a model switch, Organizer identifies the worker instance and obtains a checkpoint where possible. Stop the original execution and **confirm it has stopped** before granting the replacement ownership of the same task/worktree. If termination cannot be confirmed, quarantine the task and do not launch a concurrent writer.
- Replacement model receives the **same assignment**, GitHub requirement links/revision, current progress record, worktree path, relevant diff/status, and evidence. Read `.AI` first; do **not** reconstruct the entire feature from scratch.
- Treat `.AI` as the authoritative *reported progress*, not proof of effects. Reconcile the in-progress/blocked milestone and relevant uncommitted changes; investigate broader state only when inconsistencies or risks justify it. A completed checkbox alone is not acceptance evidence.
- For external side effects (database migration, deployment, payment, message delivery, destructive action), check observable state with safe read-only methods before retrying. Prefer idempotent operations and stable operation identifiers. If effects cannot be established, stop and escalate rather than replaying a possibly completed operation. Never infer success from a checkpoint alone.
- Record the actual model(s), switch reason, last verified milestone, unresolved uncertainty, and receiving owner. Preserve the original scope and reviewer independence when changing models.
- A 45-second `hi` timeout indicates a failed health probe, **not proven quota exhaustion**. Distinguish explicit quota errors from transient failures and model-specific availability. A failed separate probe must not kill an otherwise healthy running worker. Confirm an execution's own failure or actual quota exhaustion before handover; do not repeatedly retry a non-idempotent action.
- Free models are used only after every paid model a role may use is limited, in any repository except client work (a `git.lab.tcctech.app` remote), which never uses a model that trains on what it is sent. Never expose production env values to a free or unapproved fallback ([roster](roster.md)).

## Integration and automatic worktree cleanup

After the responsible Lead approves a worker's deliverable, Technical Lead integrates it into the **feature branch** (not the default branch) and verifies the combined state. After each successful integration, Organizer/Technical Lead **automatically removes that worker's worktree and local worker branch** once it confirms all of these:

1. `git status` in the worktree is clean: nothing uncommitted or untracked needs preserving.
2. The worker branch is merged into the feature branch (`git branch --merged <feature-branch>` lists it), so its commits and evidence are reachable there.
3. The worker process has stopped, and no reviewer or other task still needs the worktree.

Then drop the worker's own `_wt_` database, with the [localhost check](stack.md), and remove the worktree with `git worktree remove` **without** `--force`. If any check fails, retain everything and report the blocker; never force removal to get past uncommitted changes.

Once all worker changes are integrated and the required feature-branch verification/reviews finish, also remove the temporary **feature worktree** if no process or review needs it, while **retaining the feature branch and its commits** for the PR and any later fixes. Recreate a worktree from that branch if further changes are needed. Do not delete the feature branch before the human's PR merge or rewrite its history. Do not touch the human's main checkout, unrelated worktrees, or another feature's `.AI` files.

Keep local `.AI` coordination and review records until final required review/PR delivery and durable outcomes are recorded in GitHub. Clean up only the completed feature's temporary records after no handover or correction needs them; a failed final review keeps the relevant records. Distinguish **worker/feature worktree cleanup after integration** from **feature branch cleanup after the human merges the PR**.

## Final integrated verification and interrupted-cleanup recovery

After all approved worker changes are integrated, Technical Lead verifies the **combined feature branch** (including relevant build, tests, integration behavior, and dependencies); QA independently verifies applicable acceptance criteria against that integrated revision. A worker's passing tests do not replace integrated verification. Failed verification routes targeted corrections back to the owning Lead and retains the needed `.AI` records and workspaces.

Organizer reconciles managed worktrees on resume/startup for an active feature. If integration succeeded but cleanup was interrupted, inspect Git's worktree/branch state, the feature branch's reachable commits, dirty/untracked files, running processes, and pending review needs. Complete only safe pending cleanup; repeating reconciliation must be **idempotent**. If state is uncertain, leave the worktree untouched and report the blocker. Never delete the human's checkout, unrelated worktrees, or unmerged/uncommitted changes. A missing worktree is not evidence that its work was integrated.

## Explicit direct-checkout exception

The human may explicitly authorize an interactive host such as OpenCode to work directly in the human's existing checkout, rather than through a delegated worker worktree. This is an exception **only for that authorized interactive task**, not permission for Organizer to silently place delegated workers there.

- Before editing, identify the actual checkout path, current branch, and dirty/uncommitted state. A main checkout is a directory, not necessarily the `main` branch. Do not switch branches, discard local changes, or overwrite the human's work without authorization.
- This work may leave uncommitted changes in the main checkout. When it does, tell the human which files are changed and that they are not committed.
- Use the same GitHub requirement authority and temporary `.AI` instructions/progress where applicable, but do not invent a worker worktree, worker-branch merge, or worktree cleanup stage.
- If the human authorizes edits on `main`, preserve the existing explicit approval and repository rules for committing/pushing to the default branch. Do not treat local edits as automatically approved for commit, push, or PR merge.
- Never run automatic worktree removal, local branch deletion, or `.AI` cleanup against the human's main checkout. Only delete worktrees the team created and owns, after verifying safe integration.
- If direct-checkout work is to enter a feature branch or PR, use the normal review and integration path appropriate to the actual branch and changes; do not claim a merge occurred when none did.

## Acceptance scenarios

1. Worker finishes milestones 1–5, is interrupted during milestone 6: replacement reads the original packet, verifies milestone 6 and relevant diff/external state, then resumes; it does not rerun steps 1–5 without cause.
2. Original worker cannot be confirmed stopped: no second writer is launched.
3. Migration succeeded but checkpoint says in progress: read-only verification prevents duplicate execution.
4. Senior Developer reports done: independent QA has its own assignment and cannot be marked complete by the developer.
5. Worker branch is integrated and clean: its worktree and local branch are removed automatically, but feature branch and PR remain available.
6. Worktree contains uncommitted/unintegrated changes or active review: cleanup is blocked with a reason, not forced.
7. Unknown/confidential project or uncertain provider retention: unapproved free-model fallback is prohibited.
