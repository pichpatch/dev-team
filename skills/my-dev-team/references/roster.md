# Roster: which model runs each role

The role guides never name a model. This page is the one place that does. The
human chose these bindings and can change any of them at any time. Change one
only when the human says so, and change it here and in the host file listed below
in the same edit.

## Roles the human talks to

Each host runs the five conversation roles on these models:

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/deepseek-v4.1-flash`, variant `max` |
| Design Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |
| Technical Lead | `claude-opus-5-5`, effort `high` | `gpt-6.1-sol`, effort `high` | `opencode-go/mimo-v2.6-pro` |
| QA Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `openai/gpt-6-sol`, variant `high` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

Antigravity has no binding: a role there runs on the model the session is using.

### Backups for the Leads

When a Lead's own subscription is limited ([checking for limits](#checking-for-limits)),
it moves down its chain, skipping its own primary and any limited subscription:

| Lead | Backup 1 | Backup 2 | Backup 3 | Backup 4 (free) |
| --- | --- | --- | --- | --- |
| Technical Lead | `gpt-6.1-sol`, `high` | `opencode-go/mimo-v2.6-pro` | `opencode-go/deepseek-v4.1-flash`, `max` | `opencode/deepseek-v4.1-flash-free` |
| Design Lead | `gpt-6.1-sol`, `medium` | `opencode-go/glm-5.3-flash`, `max` | `opencode-go/glm-5.3`, `max` | `opencode/glm-5.3-flash-free` |
| QA Lead | `gpt-6-astra`, `medium` | `claude-sonnet-5-5`, `high` | `opencode-go/glm-5.3`, `max` | `opencode/minimax-m3.1-flash-free` |
| Cybersecurity | `gpt-6.1-sol`, `medium` | `claude-sonnet-5-5`, `high` | `opencode-go/glm-5.3`, `max` | `opencode/minimax-m3.1-flash-free` |

- QA Lead and Cybersecurity also skip any model the Technical Lead is running
  at the time.
- A delegated QA Lead or Cybersecurity takes the cross-provider route below
  first; this chain applies once that route is exhausted.
- Cybersecurity never uses its free backup for a draft release review, where it
  may read production configuration: there it stops and reports instead.
- PO and DevOps have no paid backup chain. When their own subscription is
  limited, they move straight to the three OpenCode free models, in this order:
  `opencode/deepseek-v4.1-flash-free`, `opencode/glm-5.3-flash-free`,
  `opencode/minimax-m3.1-flash-free`. The free-model rules below apply: never in
  a client-work repository, and DevOps never where it would read production
  configuration.
- Backup 4 is a free model and may train on what it is sent: never use it in a
  client-work repository. There, a Lead whose paid backups are all limited
  stops and reports.

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
| 1 | Codex | ChatGPT | `gpt-6-luna` | `high` |
| 2 | Claude | Claude | `claude-haiku-5-5` | `high` |
| 3 | OpenCode | OpenCode Go | `opencode-go/deepseek-v4.1-flash` | `high` |
| 4 (free) | OpenCode | OpenCode free | `opencode/deepseek-v4.1-flash-free` | `high` |
| 5 (free) | OpenCode | OpenCode free | `opencode/glm-5.3-flash-free` | `max` |
| 6 (free) | OpenCode | OpenCode free | `opencode/minimax-m3.1-flash-free` | `high` |

Rows 4 to 6 are free models, used only when 1 to 3 are limited, and never in a
client-work repository. `opencode/glm-5.3-flash-free` does no Senior Designer
work, since it is the same model as the OpenCode Design Lead.

- **Spare the host's own subscription.** Seniors use the most tokens, and a
  worker on the subscription the Organizer is running on competes with the
  Leads for one limit. Take models from the top, but skip the one on the
  host's subscription until the others are exhausted: in Claude Code,
  `claude-haiku-5-5` is used last; in Codex, `gpt-6-luna` is used last.
- **Match the slice to the model.** `gpt-6-luna` is the cheapest and the
  weakest coder in the pool; give it the simplest, most self-contained slices.
- **When a model reaches its limit,** continue that Senior's task on the next
  model in the table that is not already running a task
  ([checking for limits](#checking-for-limits)).

### Testers

Both testing roles run on one model, kept out of the Senior pool so a tester
never runs on the model that produced the work it tests. They may share it
because they check different things and neither reviews the other:

| Role | Runs through | Model | Effort |
| --- | --- | --- | --- |
| Design Tester | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |
| Senior QA | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |

### Checking for limits

Limits apply per subscription (Claude, ChatGPT, OpenCode Go, OpenCode free), so
Organizer checks a subscription, not each model:

- **Before using it,** send `hi` through that CLI at its lowest effort. An
  explicit limit or quota error means it is limited. No answer within 45
  seconds is a failed check, not proof the quota is used up. Either way, use
  the next choice for the role for new work.
  A successful answer counts for 10 minutes; check again after that.
- **While a delegated run is working,** check its subscription the same way
  every 10 minutes. If it answers, the run is only slow: keep waiting. A failed
  check alone never stops a running worker. Hand the task over only on an
  explicit limit error or the run's own failure: confirm the worker has stopped,
  then continue the same task on the next model from its worktree and `.AI`
  record ([model fallback](ai-task-delegation.md)), not from the start.
- Record each switch in the worker's result, with the model that actually ran.

### When every model has reached its limit

A tester whose model is limited uses the Senior pool's free rows 4 to 6, in
order, skipping the model that produced the work it is testing. When every
model a role may use is exhausted, stop: save a checkpoint, tell the human
which limits were reached, and wait.

Free models may train on what they are sent. They are allowed only as this last
resort, and never for a client-work repository (one whose remote is
`git.lab.tcctech.app`): there, use only models that do not train on what they
are sent, and stop when those are exhausted.

### Starting a run

Run each from the worktree the task packet names, so it works on its own
files and its [own database](stack.md). None runs in an OS sandbox
([delegation](delegation.md)):

```bash
opencode run -m opencode-go/deepseek-v4.1-flash --variant high "<task packet>"
codex exec -m gpt-6-luna -c model_reasoning_effort="high" --sandbox danger-full-access "<task packet>"
claude -p --model claude-haiku-5-5 --effort high "<task packet>"
agy -p --model <model> "<task packet>"
```

The Codex profiles (`codex -p my-dev-team`, `codex -p my-tech-lead`, and the
other roles) also turn Codex's sandbox off. OpenCode cannot run inside Codex's
sandbox at all, and a sandboxed Codex worker cannot commit.

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
