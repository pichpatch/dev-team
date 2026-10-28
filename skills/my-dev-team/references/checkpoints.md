# Pause, interruption, and resume

`.AI/` lives at the root of the main checkout, never inside a worktree, so there
is one place to look when resuming. It is git-ignored and never committed. It
holds temporary execution state (task packets, progress, checkpoints;
[local task delegation](ai-task-delegation.md)), never requirements or
documentation.

An agent in a worktree writes only its own checkpoint file. Its packet gives the
absolute path; that is the one path outside its worktree it may write.

| State | Checkpoint |
| --- | --- |
| No task | None. A role with no task has no card or file |
| Assigned, not started | The assigning Lead's `todo` card is enough |
| Working | Update the progress record at meaningful milestones |
| Paused or interrupted | Save resumable state |
| Blocked, or cannot finish | Save resumable state |
| Handing over to another context or model | Save resumable state |
| Finished | Keep progress and evidence through review and integration, then clean up with the feature |
| Cancelled | Move lasting knowledge to the docs or Issue, then remove that agent's checkpoint |

**Files.** Everything under `.AI/` is Markdown, at
`.AI/{feature-slug}/{role}-{instance}.md`, for example
`.AI/meetup-create-event/senior-developer-1.md`. The instance suffix is always
there, so two agents of one role never overwrite each other. A worker's card and
its checkpoint are the same file. Create no empty folders or records for future
tasks.

**Pausing.** When the human says pause, stop scheduling new work and have each
active agent save a checkpoint, before interrupting it where possible. After a
crash, Organizer records only facts it can observe and marks unknowns; never
claim a missing agent saved or finished work.

**What a checkpoint holds** ([template](../assets/checkpoint.md)): role, Issue,
state, done and current work, findings, decisions made (as links), relevant
files, remaining work, blockers, and the next action. Add the workspace,
revision, and agent identity when needed to resume. List questions for the human
with options, a recommendation, and what each blocks, so they can be settled in
one conversation. Never include credentials, hidden reasoning, or transcripts.

**Resuming.** Re-read the Issue, repo instructions, relevant docs, the real
workspace state, and that agent's checkpoint. Reconcile what changed since. A
checkpoint is not approval or proof of finished work.

**Cleaning up.** Keep a checkpoint until a finished handoff or task makes it
obsolete; refresh it if work stops again. When work finishes, move lasting
outcomes to the docs or Issue and remove only that agent's checkpoint. Remove
empty folders, never another agent's unfinished work.
