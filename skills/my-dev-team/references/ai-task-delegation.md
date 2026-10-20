# Local .AI task delegation, progress, and handover

This extends [delegation](delegation.md) and [checkpoints](checkpoints.md). GitHub Issues and approved repository documents remain authoritative for business requirements, feature scope, workflows, acceptance criteria, and permanent decisions. The ignored `.AI/` directory is a **temporary local execution system**: assignments, worker-owned plans, progress, evidence pointers, and handovers. It is not a second requirements tracker. Nothing in `.AI/` is committed or pushed.

## Location and ownership

- Organizer maintains one feature coordination record at `<main-checkout>/.AI/<feature-slug>/README.md`. It references the owning GitHub Issue and revision, feature branch, active assignments, dependencies, status, receiving Leads, and review gates.
- Each delegated worker or reviewer has its own file `<main-checkout>/.AI/<feature-slug>/<role>-<instance>.md`, with a stable identifier even when the executing model changes. These paths are **outside** the agent's worktree; they must be passed explicitly as absolute paths. Do not assume ignored `.AI` files are shared between worktrees.
- The assigning Lead owns the immutable assignment section (or issues a revised version). The worker owns only its execution-plan, progress, evidence, and blocker sections. Organizer coordinates ownership and handovers; it does not make technical or domain decisions.
- A worker may write only its assigned record, not another worker's or the feature coordination record. Organizer or the owning Lead updates shared coordination records, serializing concurrent changes. Do not put secrets, credentials, full conversation transcripts, or hidden reasoning in `.AI`.
- Create records only for real assigned work; remove them when the feature is safely closed. Preserve GitHub Issue and repository decisions independently.

## Assignment packet — actionable instructions, not a generic checklist

Before dispatch, the assigning Lead writes a concise task packet identifying: (1) role and worker instance; (2) owning GitHub Issue URL and relevant approved revision; (3) objective and measurable definition of done; (4) worktree and branch, relevant docs and starting files; (5) permitted scope, forbidden changes, dependencies and prerequisite approvals; (6) milestones and deliverables, tests and evidence expected; (7) receiving Lead and escalation route; (8) progress-record path and current owner. The Lead provides enough detail to preserve intent across models, without dictating every implementation command.

The worker reads the assignment **before starting** and creates its own execution checklist under it. Use milestone states `pending`, `in-progress`, `blocked`, `completed`. Before starting a meaningful milestone, mark it in progress; on completion, record concise evidence (file paths, commit/diff references, test results, migration identifiers where applicable) and mark it completed. Update at meaningful boundaries, not after every shell command. Workers may refine their execution plan but may not silently change the assignment, GitHub requirements, or acceptance criteria. Escalate changed scope or blocked dependencies to the owning Lead; requirement changes follow PO/GitHub approval.

A completed implementation is **delivered for review**, not self-approved. Design Tester, Senior QA, QA Lead, and Cybersecurity receive independent assignments and checklists as applicable, grounded in the original GitHub requirements and actual artifacts, not only the implementer's claims. The owning Lead accepts or requests changes, and Organizer updates the coordination record. Each dependent stage starts only after its required predecessor and approval gates complete.

## Model fallback and safe recovery

- Before a model switch, Organizer identifies the worker instance and obtains a checkpoint where possible. Stop the original execution and **confirm it has stopped** before granting the replacement ownership of the same task/worktree. If termination cannot be confirmed, quarantine the task and do not launch a concurrent writer.
- Replacement model receives the **same assignment**, GitHub requirement links/revision, current progress record, worktree path, relevant diff/status, and evidence. Read `.AI` first; do **not** reconstruct the entire feature from scratch.
- Treat `.AI` as the authoritative *reported progress*, not proof of effects. Reconcile the in-progress/blocked milestone and relevant uncommitted changes; investigate broader state only when inconsistencies or risks justify it. A completed checkbox alone is not acceptance evidence.
- For external side effects (database migration, deployment, payment, message delivery, destructive action), check observable state with safe read-only methods before retrying. Prefer idempotent operations and stable operation identifiers. If effects cannot be established, stop and escalate rather than replaying a possibly completed operation. Never infer success from a checkpoint alone.
- Record the actual model(s), switch reason, last verified milestone, unresolved uncertainty, and receiving owner. Preserve the original scope and reviewer independence when changing models.
- A 45-second `hi` timeout indicates a failed health probe, **not proven quota exhaustion**. Distinguish explicit quota errors from transient failures and model-specific availability. A failed separate probe must not kill an otherwise healthy running worker. Confirm an execution's own failure or actual quota exhaustion before handover; do not repeatedly retry a non-idempotent action.
- Treat provider privacy/retention and project data classification as dispatch constraints. The remote `git.lab.tcctech.app` is an indicator of client work, **not** an exhaustive classifier: other remotes and local repos may also contain client or confidential material. If classification is unknown, do not send code, context, or credentials to a free/training-enabled model. Never expose production env values to an unapproved fallback.

## Integration and automatic worktree cleanup

After the responsible Lead approves a worker's deliverable, Technical Lead integrates it into the **feature branch** (not the default branch) and verifies the combined state. After each successful integration, Organizer/Technical Lead **automatically removes that worker's worktree and local worker branch** once it confirms: no unfinished or uncommitted work needs preservation; the integrated commits and evidence are reachable on the feature branch; the worker process has stopped; and no reviewer or other task still needs that worktree. If any check fails, retain it and report the blocker. Never use forced worktree deletion to hide uncommitted changes.

Once all worker changes are integrated and the required feature-branch verification/reviews finish, also remove the temporary **feature worktree** if no process or review needs it, while **retaining the feature branch and its commits** for the PR and any later fixes. Recreate a worktree from that branch if further changes are needed. Do not delete the feature branch before the human's PR merge or rewrite its history. Do not touch the human's main checkout, unrelated worktrees, or another feature's `.AI` files.

Keep local `.AI` coordination and review records until final required review/PR delivery and durable outcomes are recorded in GitHub. Clean up only the completed feature's temporary records after no handover or correction needs them; a failed final review keeps the relevant records. Distinguish **worker/feature worktree cleanup after integration** from **feature branch cleanup after the human merges the PR**.

## Acceptance scenarios

1. Worker finishes milestones 1–5, is interrupted during milestone 6: replacement reads the original packet, verifies milestone 6 and relevant diff/external state, then resumes; it does not rerun steps 1–5 without cause.
2. Original worker cannot be confirmed stopped: no second writer is launched.
3. Migration succeeded but checkpoint says in progress: read-only verification prevents duplicate execution.
4. Senior Developer reports done: independent QA has its own assignment and cannot be marked complete by the developer.
5. Worker branch is integrated and clean: its worktree and local branch are removed automatically, but feature branch and PR remain available.
6. Worktree contains uncommitted/unintegrated changes or active review: cleanup is blocked with a reason, not forced.
7. Unknown/confidential project or uncertain provider retention: unapproved free-model fallback is prohibited.
