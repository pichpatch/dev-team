# Roster: which model runs each role

The role guides never name a model. This page is the one place that does. The
human chose these bindings; change one only when the human says so, and change
it here and in the host file listed below in the same edit.

## Roles the human talks to

Each host runs the five conversation roles on these models:

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/deepseek-v4.1-flash`, variant `max` |
| Design Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |
| Technical Lead | `claude-opus-5-5`, effort `high` | `gpt-6.1-sol`, effort `high` | `opencode-go/mimo-v2.6-pro` |
| QA Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `opencode-go/gpt-6-luna`, variant `xhigh` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

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

Both testing roles run on one model, kept out of the Senior pool so a tester
never runs on the model that produced the work it tests. They may share it
because they check different things and neither reviews the other:

| Role | Runs through | Model | Effort |
| --- | --- | --- | --- |
| Design Tester | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |
| Senior QA | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |

### When every model has reached its limit

Use `opencode/space-bunny-free`, for a Senior or a tester. When that is also
exhausted, stop: save a checkpoint, tell the human which limits were reached,
and wait. Do not use any other free model; the others train on what they are
sent.

### Starting a run

Run each from the worktree the task packet names, so it works on its own
files and its [own database](stack.md):

```bash
opencode run -m opencode-go/space-bunny --variant high "<task packet>"
codex exec -m gpt-6-luna -c model_reasoning_effort="high" \
  --sandbox workspace-write -c sandbox_workspace_write.network_access=true \
  -c 'sandbox_workspace_write.writable_roots=["<main checkout>/.AI"]' "<task packet>"
claude -p --model claude-haiku-5-5 --effort high "<task packet>"
agy -p --model <model> "<task packet>"
```

What each needs, tested on the human's machine:

| CLI as a worker | Sandbox | Reaches the local database | Commits in its worktree |
| --- | --- | --- | --- |
| Codex | `workspace-write`, network on | Yes | No: the Organizer commits for it |
| Claude | None; runs with the human's Claude Code permissions | Yes | Yes |
| OpenCode | None | Yes | Yes |
| Antigravity | None (never pass `--sandbox`) | Yes | Yes |

The host that organizes must run without an OS sandbox: OpenCode cannot run
inside Codex's sandbox at all, so Codex organizes from the `my-dev-team` profile
(`codex -p my-dev-team`), which turns its sandbox off. Claude Code, OpenCode,
and Antigravity have no OS sandbox by default.

Check each CLI's `--help` for the flags the installed version supports instead
of assuming these.

### Dedicated DevOps and Cybersecurity models

These roles do not use the shared Senior pool. DevOps is always delegated.
Cybersecurity in conversation uses its row in the conversation table above;
delegated, it follows the cross-provider routes below.

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| DevOps | `claude-sonnet-5-5`, effort `medium` | `gpt-6-sol`, effort `medium` | `opencode-go/mimo-v2.6-flash` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

Technical Lead reviews these roles' outputs. Verify model identifiers with each installed host before dispatch; never silently substitute a different model.

### Cross-provider independent reviewers

Delegated Cybersecurity and QA Lead always run as separate sub-agents on a
different underlying model/provider from Organizer, on every task. A different
effort level of the same model is not independent. Preferred routes: Claude
Organizer -> GPT/Codex (OpenCode fallback on GPT rate limit); GPT/Codex
Organizer -> Claude (OpenCode fallback on Claude rate limit); OpenCode
Organizer -> Claude (GPT/Codex fallback).
The model for each route:

| Organizer | Delegated QA Lead and Cybersecurity run on | If that provider is rate-limited |
| --- | --- | --- |
| Claude Code | Codex: `gpt-6.1-sol`, effort `medium` | OpenCode: the role's OpenCode binding |
| Codex | Claude: `claude-sonnet-5-5`, effort `high` | OpenCode: the role's OpenCode binding |
| OpenCode | Claude: `claude-sonnet-5-5`, effort `high` | Codex: `gpt-6.1-sol`, effort `medium` |

This applies to the delegated roles only. A QA Lead the human talks to keeps its
conversation binding above.

Keep human-approved bindings and verify actual invocation support. If routing
conflicts with bindings or no independent agent is available, ask the human or
report a blocked review; never silently substitute. Direct human invocation
uses the role's conversation binding and is exempt from sub-agent spawning, but
does not establish independent approval. Technical Lead can share Organizer context.

### Other delegated Leads

The three Leads, when delegated, use their role bindings in the conversation table for the organizing host.
