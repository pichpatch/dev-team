# Pause, interruption, and resume

`.AI/` lives at the root of the main checkout, never inside a worktree, so there
is one place to look when resuming. It is git-ignored and never committed. It is
temporary unfinished state, not a task tracker or permanent documentation.

An agent working in a worktree writes only its own checkpoint file there. Its
task packet gives the absolute path; that is the one path outside its worktree
it may write.

| State | Checkpoint behavior |
| --- | --- |
| Not started | No checkpoint |
| Currently working | Normally no checkpoint |
| Paused or interrupted | Save resumable state |
| Blocked or cannot finish | Save resumable state |
| Context/model handoff | Save resumable unfinished state |
| Finished | Remove that agent's checkpoint |
| Cancelled | Transfer durable knowledge, then remove that agent's checkpoint |

Everything under `.AI/` is Markdown. Use `.AI/{feature-slug}/{role}.md`, for example
`.AI/meetup-create-event/senior-developer.md`. If multiple agents have the same
role, use stable instance suffixes so they cannot overwrite one another.
Create no empty folders or checkpoints for future tasks.

When the human tells Organizer to pause, stop scheduling new work and have each
active unfinished agent save a checkpoint. Where possible request checkpointing
before interrupting a running agent. An abrupt crash may prevent a final write;
Organizer records only recoverable observed facts and explicitly marks unknowns,
without claiming the missing agent saved or completed work.

Use [the checkpoint template](../assets/checkpoint.md). Include role, Issue,
current state, completed/current work, important findings, decisions already made,
relevant files, remaining work, blockers, and the recommended next action. Include
workspace/revision and agent identity when needed to resume accurately. Link to
durable decisions instead of making the checkpoint their permanent home. List
items blocked on the human as questions with the options, a recommendation, and
what each blocks, so they can all be settled in one conversation. Never
include credentials, hidden reasoning, or transcript dumps.

On resume, re-read the owning Issue, applicable repo instructions, relevant docs,
actual workspace state, and that agent's checkpoint. Reconcile changes since the
checkpoint before proceeding; a checkpoint is not approval or proof of completed work.
Retain the useful checkpoint until a completed handoff or task makes it obsolete;
refresh it if work stops again. Once work finishes, transfer all durable outcomes
to repo docs/Issue and remove only that agent's checkpoint. Remove empty checkpoint
directories if appropriate, without deleting another agent's unfinished work.
