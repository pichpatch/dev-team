# Local .AI task delegation, progress, and handover

This extends [delegation](delegation.md) and [checkpoints](checkpoints.md). The
Issue and the repository docs stay the authority for requirements, scope, AC,
and decisions. The ignored `.AI/` folder is a **temporary local work board**:
assignments, plans, progress, evidence pointers, and handovers. It is never a
second tracker, and nothing in it is committed or pushed.

## The board

- `.AI/<feature-slug>/` is the team's kanban board for one feature; the Issue
  only shows the feature's status. Organizer keeps the board at
  `<main-checkout>/.AI/<feature-slug>/README.md`: the Issue and revision, the
  feature branch, receiving Leads, review gates, and one row per card with role
  and instance, the model running it, dependencies, and status.
- **Each task is a card:** the worker's own file,
  `<main-checkout>/.AI/<feature-slug>/<role>-<instance>.md`, with a stable name
  even when the model changes. It is outside the worktree, so pass its absolute
  path explicitly; never assume worktrees share `.AI`.
- **Card statuses:** `todo`, `in-progress`, `blocked`, `review`, `done`.

| Who | Moves the card to |
| --- | --- |
| The assigning Lead | `todo`, when it writes the assignment |
| The worker | `in-progress` when it starts; `blocked` with the reason; `review` when it delivers |
| The receiving Lead | `done` on approval, or back to `in-progress` with corrections and each finding's round number ([review loop limits](contract.md#every-review-loop-is-bounded)) |

- The worker writes its status at the top of its own file; Organizer mirrors it
  into the board row, so no two agents edit one file.
- The assigning Lead owns the assignment section (it may issue a revised one).
  The worker owns only its plan, progress, evidence, and blocker sections. A
  worker writes only its own card.
- Organizer or the owning Lead updates shared records, one change at a time.
- Never put secrets, credentials, transcripts, or hidden reasoning in `.AI`.
- Create cards only for real work; remove them once the feature is safely closed.

## Feature branch creation

The human starts or approves a feature and its scope; Organizer never invents
or expands requirements. PO records the agreed requirement and AC on the Issue.
Once the feature is `ready to implement`, **Technical Lead creates the feature
branch** (`feat/{issue-number}-{slug}`), the feature worktree, and the worker
worktrees, splits the work, and delegates it. Organizer creates the board, and
runs the git commands for Technical Lead only when it cannot. Workers never
create a feature or commit to the default branch.

## Assignment and progress

- Before dispatch, the assigning Lead writes the
  [task packet](delegation.md#task-packet) into the worker's card as its
  assignment: enough to keep intent across models, without dictating every
  command.
- The worker reads it **before starting** and writes its own checklist under it,
  with milestones `pending`, `in-progress`, `blocked`, `completed`. Mark a
  milestone in progress before starting it; on completion, add short evidence
  (file paths, commits, test results, migration IDs). Update at milestones, not
  after every command.
- **Heartbeat:** before a step that may take more than 5 minutes (the full test
  suite, an install, a build), add one line to your card with the step and how
  long you expect it to take, for example
  `Heartbeat 14:05: full integration suite, about 40 minutes`. Organizer reads
  it to tell a long step from a stuck worker.
- A worker may refine its plan but never silently change the assignment, the
  Issue, or the AC. Changed scope or a blocked dependency goes to the owning
  Lead; requirement changes go through PO.
- Finished work is **delivered for review**, never self-approved. Design Tester,
  Senior QA, QA Lead, and Cybersecurity get their own assignments, grounded in
  the Issue and the real artifacts, not the implementer's claims. The owning
  Lead accepts or asks for changes. Each dependent stage starts only after its
  predecessor's approval.

## Watching a running worker

Check the worker every 5 minutes. A provider that answers `hi` does not show that
the worker is working, so always check the worker itself.

**Step 1: look for activity.** Any one of these since the last check means the
worker is working. Keep waiting and start the count again.
- The log file grew (`wc -c` on `.AI/<feature-slug>/<role>-<instance>.log`).
- The output of `git -C <worktree> status --short` or `git -C <worktree> diff --stat`
  changed, or there is a new commit.
- The worker's card was updated.
- A heartbeat line was added to the card (a long step started).
- A process in the worker's process group is using CPU: a test run, install,
  or build, however deep it runs. Find the group with
  `ps -o pgid= -p <pid>`, then list it with `ps -o pid=,pcpu=,command= -g <pgid>`.
  CPU alone counts for at most 30 minutes in a row, or until the time the
  latest heartbeat gave has passed, whichever is longer, but never more than
  2 hours. After that, only a log, file, or card change resets the clock.

**Step 2: no activity, so the stall clock runs.**

| Silent for | Do this |
| --- | --- |
| 15 minutes | Check the process is alive (`ps -p <pid>`). Send `hi` to the worker's model. A limit error: use [model fallback](#model-fallback-and-safe-recovery). It answers, or there is no answer: do nothing yet; keep the clock running and act at 20 minutes. |
| 20 minutes | The worker is stalled. Copy `git status --short`, `git diff --stat`, and the last 20 log lines into its card. Stop the process and its group (`kill -- -<pgid>`), and confirm it stopped (`ps -p <pid>` shows nothing). If it was a paired worker, check the pair lock (below). Restart the same task from its card, in the same worktree, on the same model. |
| 20 more minutes, silent again | Do the same, but continue on the next model in the roster row. |

Write each stall in the card, with the time and the model. If the process is
already gone and the card is not `review` or `done`, the run failed: use
[model fallback](#model-fallback-and-safe-recovery). A restart follows the same
rules as a handover: stop first, confirm, and check side effects read-only
before repeating anything.

**A stopped paired worker may leave the pair lock.** After stopping a Senior
Developer or Senior QA that shares a paired worktree, check for the lock:
`ls -d "$(git -C <worktree> rev-parse --git-dir)/pair.lock"`. If it exists, tell
Technical Lead, who removes it (`rmdir` on the same path) now that the holder's
process is confirmed stopped, before either worker continues
([pair lock](delegation.md#paired-developerqa-worktree)).

**Slow is not silent.** A slow model still produces output. Peak hours, a busy
provider, or a long answer never explain 20 minutes with no log output, no file
change, and no card update.

**Step 3: report facts.** Each time you tell the human about a running worker,
say all four: the last activity and what it was (log, files, card, or child
process); whether the process is alive; the provider check result (ok, limit,
no answer, or not run); and what you will do next. Never fill the gap with a
guess such as "may be peak-hour slowdown".

## Model fallback and safe recovery

- **Stop before handing over.** Organizer identifies the worker, gets a
  checkpoint where possible, stops the run, and **confirms it stopped** before a
  replacement takes the same task or worktree. If it cannot confirm, quarantine
  the task; never start a second writer.
- **Same task, not a restart.** The replacement gets the same assignment, Issue
  links and revision, progress record, worktree, diff and status, and evidence.
  It reads `.AI` first and does not rebuild the feature from scratch.
- **`.AI` is reported progress, not proof.** Check the in-progress or blocked
  milestone and uncommitted changes; look wider only when something is
  inconsistent. A ticked box alone is not acceptance evidence.
- **External side effects** (migration, deployment, payment, message, destructive
  action): check real state read-only before retrying. Prefer idempotent
  operations with stable IDs. If the effect cannot be established, stop and
  escalate; never replay something that may have completed.
- **Record** the models that ran, the reason for the switch, the last verified
  milestone, open uncertainty, and the receiving owner. Keep the original scope
  and reviewer independence.
- **A timed-out `hi` is a failed probe, not proof of a used-up quota.** Separate
  explicit quota errors from transient failures. A failed probe never kills a
  healthy worker. Confirm the run's own failure or real quota exhaustion before
  handing over; never repeat a non-idempotent action.
- **Senior Developer/QA fallback:** OpenCode Go is the normal route. After an
  explicit Go quota-limit response, a pair worker continues on the paid pool
  rows in the [roster](roster.md), keeping Senior QA on a different model from
  the Developer whose code it confirms. Only when OpenCode Go, Claude, and Codex
  are all at their limit may it use a [free model](roster.md#free-models): any
  of them, one active at a time, never for client work. Independence may then be
  lost; record it, and do not stop for it. A transient error or slow response
  does not establish quota exhaustion. Other roles follow their roster entries.
  Never expose production values to a free or unapproved model.

## Integration and worktree cleanup

After the Lead approves a deliverable, Technical Lead merges it into the
**feature branch** (never the default branch) and verifies the combined state.
Then Organizer or Technical Lead **removes the worker's worktree and local
branch**, but only when all of these hold:

1. `git status` in the worktree is clean: nothing uncommitted or untracked
   needs keeping.
2. `git branch --merged <feature-branch>` lists the worker branch.
3. The worker process has stopped, and no reviewer or task still needs the
   worktree.

Then drop the worker's own `_wt_` database (after the
[localhost check](stack.md)) and run `git worktree remove` **without**
`--force`. If any check fails, keep everything and report the blocker.

- Once all work is integrated and the feature branch is verified, remove the
  **feature worktree** too when nothing needs it, but **keep the feature
  branch** for the PR and later fixes; recreate a worktree from it if needed.
- Never delete the feature branch before the human merges, or rewrite its
  history. Never touch the human's main checkout, unrelated worktrees, or another
  feature's `.AI` files.
- Keep `.AI` records until the PR is delivered and outcomes are recorded on the
  Issue. A failed final review keeps the records it needs.

## Final integrated verification and recovery

After integration, Technical Lead verifies the **combined feature branch**
(build, tests, integration, dependencies), and QA verifies the AC on that
integrated revision. A worker's passing tests never replace this. Failures go
back to the owning Lead, keeping the needed records and worktrees.

On resume, Organizer reconciles the feature's worktrees: if integration
succeeded but cleanup was interrupted, inspect worktrees, branches, reachable
commits, dirty files, running processes, and pending reviews, and finish only
the safe cleanup. Repeating this must be harmless. If state is unclear, leave
it and report. A missing worktree is not evidence its work was integrated.

## Direct-checkout exception

The human may explicitly let an interactive host work directly in the human's
checkout instead of a worker worktree. This covers only that task; it never lets
Organizer place delegated workers there.

- Before editing, note the checkout path, current branch, and uncommitted
  state. A main checkout is a folder, not necessarily the `main` branch. Do not
  switch branches, discard changes, or overwrite the human's work without
  permission.
- Changes may stay uncommitted; then tell the human which files changed.
- Use the same Issue authority and `.AI` progress where they apply, but invent
  no worker worktree, merge, or cleanup.
- Edits on `main` follow the repository's rules for committing and pushing to
  the default branch; local edits are never automatically approved for commit,
  push, or merge.
- Never run worktree removal, branch deletion, or `.AI` cleanup against the
  human's checkout. Delete only worktrees the team created, after verifying
  integration.
- If this work is to reach a feature branch or PR, use the normal review and
  integration path; never claim a merge that did not happen.

## Scenarios

1. A worker finished milestones 1–5 and was interrupted in 6: the replacement
   reads the packet, checks milestone 6 and the diff, and resumes; it does not
   redo 1–5 without cause.
2. The original worker cannot be confirmed stopped: no second writer starts.
3. A migration succeeded but the card says in progress: a read-only check
   prevents running it twice.
4. Senior Developer reports done: Technical Lead freezes the revision and
   Senior QA verifies it in the paired worktree; the developer cannot mark QA
   complete.
5. An independent worker branch or paired Developer/QA branch is merged and
   clean: its worktree and branch are removed only after all worker processes
   have stopped; the feature branch and PR remain.
6. A worktree has uncommitted or unmerged changes, or an active review: cleanup
   is blocked with a reason, never forced.
7. Client work or a provider with unclear data use: no free-model fallback.
