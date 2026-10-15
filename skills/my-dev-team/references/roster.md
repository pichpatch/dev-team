# Roster: which model runs each role

The role guides never name a model. This page is the one place that does. The
human chose these bindings; change one only when the human says so, and change
it here and in the host file listed below in the same edit.

## Roles the human talks to

Each host runs the four conversation roles on these models:

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/deepseek-v4.1-flash`, variant `max` |
| Design Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |
| Technical Lead | `claude-opus-5-5`, effort `high` | `gpt-6.1-sol`, effort `high` | `opencode-go/mimo-v2.6-pro` |
| QA Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `opencode-go/gpt-6-luna`, variant `xhigh` |

Antigravity has no binding: a role there runs on the model the session is using.

## How each host applies it

| Host | Where the binding lives | How the human gets it |
| --- | --- | --- |
| Claude Code | `model` and `effort` in each role command | Call the command: `/my-tech-lead <message>`. It applies to that turn; the next message returns to the session's model, so call the command again or set the session model for a long talk with one role. |
| OpenCode | An agent per role, with its `model` and `variant`; the role command names the agent | Call `/my-tech-lead`, or switch agent with Tab and stay in that role for as long as needed. |
| Codex | A profile per role | Start the session on the role: `codex -p my-tech-lead`. A skill cannot change the model inside a session, so calling `$my-tech-lead` keeps the session's model; switch with `/model` when it matters. |

When the human asks a role a question in the middle of another role's turn,
answer as that role on the model already running, and say so if the role's own
model would matter for the answer.

## Rules for any binding

- A role that reviews work runs on a different model from the role that did it:
  a Lead and its Seniors, the Design Tester and the Senior Designer, QA and the
  developers.
- Only models the human approved for private code are used
  ([shared contract](contract.md)). A free model that trains on what it is sent
  is not approved.
- Record the model that actually ran on evaluations and results. Never report a
  role as having run on its bound model when another model stood in.
- When a bound model is unavailable, tell the human and wait or use the fallback
  the human named; do not pick a substitute yourself.

## Delegated roles

Organizer starts these as separate CLI runs, each in its own worktree, from
whichever host is organizing.

### Senior pool

Senior Developer and Senior Designer work comes from this pool. Run up to three
Seniors at once:

| Order | Runs through | Subscription | Model | Effort |
| --- | --- | --- | --- | --- |
| 1 | OpenCode | OpenCode Go | `opencode-go/space-bunny` | `high` |
| 2 | Codex | ChatGPT | `gpt-6-luna` | `high` |
| 3 | Claude | Claude | `claude-haiku-5-5` | `high` |
| 4 | OpenCode | OpenCode Go | `opencode-go/deepseek-v4.1-flash` | `high` |

- **Spare the host's own subscription.** Seniors use the most tokens, and a
  worker on the subscription the Organizer is running on competes with the
  Leads for one limit. Take models from the top, but skip the one on the
  host's subscription until the others are exhausted: in Claude Code,
  `claude-haiku-5-5` is used last; in Codex, `gpt-6-luna` is used last.
- **Match the slice to the model.** `gpt-6-luna` is the cheapest and the
  weakest coder in the pool; give it the simplest, most self-contained slices.
- **When a model reaches its limit,** continue that Senior's task on the next
  model in the table that is not already running a task.

### Testers

The two testing roles each have their own model, kept out of the Senior pool so
a tester never runs on the model that produced the work it tests:

| Role | Runs through | Model | Effort |
| --- | --- | --- | --- |
| Design Tester | OpenCode | `opencode-go/qwen3.8-flash` | `xhigh` |
| Senior QA | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |

### When every model has reached its limit

Use `opencode/space-bunny-free`, for a Senior or a tester. When that is also
exhausted, stop: save a checkpoint, tell the human which limits were reached,
and wait. Do not use any other free model; the others train on what they are
sent.

### Starting a run

```bash
opencode run -m opencode-go/space-bunny --variant high "<task packet>"
codex exec -m gpt-6-luna -c model_reasoning_effort="high" --sandbox workspace-write "<task packet>"
claude -p --model claude-haiku-5-5 --effort high "<task packet>"
```

Check each CLI's `--help` for the flags the installed version supports instead
of assuming these, and run each from the worktree the task packet names.

### Dedicated DevOps and Cybersecurity models

These roles do not use the shared Senior pool. Direct human conversations remain on the current session model; delegated work uses the host-specific bindings below.

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| DevOps | `claude-sonnet-5-5`, effort `medium` | `gpt-6-sol`, effort `medium` | `opencode-go/mimo-v2.6-flash` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6-sol`, effort `high` | `opencode-go/gpt-6-luna`, variant `high` |

Technical Lead reviews these roles' outputs. Verify model identifiers with each installed host before dispatch; never silently substitute a different model.

### Other delegated Leads

The three Leads, when delegated, use their role bindings in the conversation table for the organizing host.
