# Roster: which model runs each role

The role guides never name a model; this page is the one place that does. The
human chose these bindings and may change any of them. Change one only when the
human says so, here and in the host file below, in the same edit.

## Rules for any binding

- A reviewer runs on a different model from the work it reviews: a Lead and its
  Seniors, Design Tester and Senior Designer, QA and the developers.
- Fallback keeps reviewer independence while any paid route is available. Paid
  OpenCode Go models come before any free model. Only when OpenCode Go, Claude,
  and Codex are all at their limit may a free model be used (see
  [free models](#free-models)); independence can then be lost.
- Only models the human approved for private code
  ([shared contract](contract.md)). A free model that trains on what it is sent
  is not approved, except the free last-resort rows below.
- Record the model that actually ran. Never report the bound model when another
  stood in.
- When a bound model is unavailable, tell the human and wait, or use the
  fallback listed here or named by the human. Never pick a substitute yourself.
- **Client work** is a repository whose remote is `git.lab.tcctech.app`. It
  never uses a free model. When its paid models are exhausted, stop and report.

## Roles the human talks to

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/deepseek-v4.1-flash`, variant `max` |
| Design Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |
| Technical Lead | `claude-opus-5-5`, effort `medium` | `gpt-6.1-sol`, effort `high` | `opencode-go/gemini-4-argon`, variant `medium` |
| QA Lead | `claude-sonnet-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `opencode-go/gpt-6-luna`, variant `high` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

Antigravity has no binding: a role there runs on the session's model.

| Host | Where the binding lives | How the human uses it |
| --- | --- | --- |
| Claude Code | `model` and `effort` in each role command | `/my-tech-lead <message>`. It applies to that turn only; call it again, or set the session model, for a long talk with one role. |
| OpenCode | One agent per role, with `model` and `variant`; the command names the agent | `/my-tech-lead`, or switch agent with Tab and stay in it. |
| Codex | One profile per role | Start on the role: `codex -p my-tech-lead`. `$my-tech-lead` keeps the session's model; switch with `/model` when it matters. |

When the human asks a role something mid-turn, answer on the model already
running, and say so if the role's own model would matter.

### Backups for the Leads, PO, and DevOps

When a role's model is limited ([checking for limits](#checking-for-limits)),
it moves along its row, skipping its own primary and any limited model:

| Role | Backups, in order | Free, last |
| --- | --- | --- |
| Technical Lead | `gpt-6.1-sol` `high`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/kimi-k3.1-pro` `high`; `opencode-go/deepseek-v4.1-flash` `max` | `opencode/deepseek-v4.1-flash-free` |
| Design Lead | `gpt-6.1-sol` `medium`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/glm-5.3-flash` `max` | `opencode/glm-5.3-flash-free` |
| QA Lead | `gpt-6-astra` `medium`; `claude-sonnet-5-5` `high`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/minimax-m3.1-flash` `high` | `opencode/deepseek-v4.1-flash-free` |
| Cybersecurity | `gpt-6.1-sol` `medium`; `claude-sonnet-5-5` `high`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/minimax-m3.1-flash` `high` | `opencode/deepseek-v4.1-flash-free` |
| PO | `opencode-go/deepseek-v4.1-flash` `max`; `opencode-go/glm-5.3-flash` `max`; `opencode-go/mimo-v2.6-flash` | the [free models](#free-models), in order |
| DevOps | `opencode-go/mimo-v2.6-flash`; `opencode-go/deepseek-v4.1-flash` `high`; `opencode-go/glm-5.3-flash` `high` | the [free models](#free-models), in order |

- `gemini-4-argon` through OpenCode Go is the strong backup: it scores close to
  Sol and Opus, and Go gives it its own allowance, so it never uses up the
  workers'. Use `medium` to stretch it, and use it there, not through
  Antigravity, whose weekly limit is small. `kimi-k3.1-pro` is strong but has a
  small allowance: Lead turns only. OpenCode Go does not offer Sol; OpenCode's
  `openai/gpt-6.1-sol` runs on the same ChatGPT subscription as Codex, so it
  adds nothing once Sol is limited.
- QA Lead and Cybersecurity also skip whatever model Technical Lead is running.
- Delegated QA Lead and Cybersecurity use the
  [cross-provider route](#cross-provider-independent-reviewers) first; this
  row applies after it.
- The free column may train on what it is sent: never for client work.
  Cybersecurity never uses it for a release review, where it may read
  production configuration; it stops and reports instead. DevOps never uses it
  where it would read production configuration.

## Delegated roles

Organizer starts delegated work as separate CLI runs. A Senior Developer and
Senior QA paired on a slice are the exception: they use the same worktree and
write concurrently to separately owned files ([worktrees](delegation.md#worktrees-keep-secrets-out-of-delegated-work)).

### Workers: smart scope, cheap heavy work

The Leads write the scope and the instructions; the heavy work runs on cheap
OpenCode Go models with large allowances. OpenCode Go limits each model
separately, so a worker moves to the next Go model before leaving Go.

| Worker | Models, in order | Then |
| --- | --- | --- |
| Senior Developer | `opencode-go/deepseek-v4.1-flash` `high` (`max` for a hard slice); `opencode-go/mimo-v2.6-flash`; `opencode-go/minimax-m3.1-flash` `high`; `opencode-go/glm-5.3-flash` `high` | Claude `claude-haiku-5-5` `high`; Codex `gpt-6-luna` `high`; then the [free models](#free-models) |
| Senior QA | Claude `claude-haiku-5-5` `high`; `opencode-go/mimo-v2.6-flash`; `opencode-go/glm-5.3-flash` `high`; `opencode-go/minimax-m3.1-flash` `high`; `opencode-go/deepseek-v4.1-flash` `high` | Codex `gpt-6-luna` `high`; then the free models |
| Senior Designer | `opencode-go/deepseek-v4.1-flash` `high`; `opencode-go/claude-haiku-5-5` `high`; `opencode-go/mimo-v2.6-flash` | Codex `gpt-6-luna` `high`; Claude `claude-haiku-5-5` `high`; then the free models |
| Design Tester | Codex `gpt-6-luna` `high`; `opencode-go/mimo-v2.6-flash`; `opencode-go/glm-5.3-flash` `high`; `opencode-go/minimax-m3.1-flash` `high` | Claude `claude-haiku-5-5` `high`; then the free models |

- **Senior QA starts on Claude** (`claude-haiku-5-5`, through `claude -p`), so its
  work uses the Claude allowance and the OpenCode Go allowance goes to the
  Senior Developer. If Claude is limited, Senior QA moves to the Go models in
  the row.
- **Never the same model on both sides.** Senior QA never runs on the model the
  Senior Developer it pairs with is using, and Design Tester never on the one
  that made the design: skip that model in the row. A Senior Designer skips the
  model its Design Lead is running.
- A Senior Developer and Senior QA paired on a slice share one worktree with
  concurrent authoring in separately owned files
  ([worktrees](delegation.md#worktrees-keep-secrets-out-of-delegated-work)).
  Independent tasks and independent pairs may run in parallel.
- **Match the slice to the model.** `deepseek-v4.1-flash` takes most of the
  work: the largest allowance and a fast first answer. Its peak hours
  (01:00-04:00 and 06:00-10:00 UTC on weekdays) use the allowance twice as fast;
  queue large batches outside them when you can. `gpt-6-luna` is the weakest
  coder: the simplest, most self-contained slices only.
- A transient error or a slow response is not a limit. Free models come only
  after OpenCode Go, Claude, and Codex are all at their limit.

### Free models

Used in this order: `opencode/deepseek-v4.1-flash-free`, then
`opencode/glm-5.3-flash-free`. Both keep no data and do not train on it. Both
are free for a limited time. Never for client work.

- **Last resort for workers:** only when OpenCode Go, Claude, and Codex are all
  at their limit. Any free model is then acceptable, even one that also
  produced the work being reviewed. Prefer a different one, and record that
  independence could not be kept. Do not stop for this.
- **One free-model run at a time** across the team, Organizer included. Wait for
  the active free-model run to stop before starting another; never parallelize
  free-model work.
- When every free model is also at its limit, stop and report with a checkpoint.
- Not used: `mimo-v2.6-pro`, `beam-free`, `longcat-2.0`, `qwen3.8-flash`,
  `iceman-contributor-free`, `mimo-v2.6-flash-free`, and
  `opencode/minimax-m3.1-flash-free` (no longer offered).

### DevOps and Cybersecurity

They do not use the worker rows above. DevOps is always delegated. Cybersecurity in
conversation uses its row in the table above; delegated, it takes the
cross-provider route below.

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| DevOps | `claude-sonnet-5-5`, effort `medium` | `gpt-6-sol`, effort `medium` | `opencode-go/mimo-v2.6-flash` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

Technical Lead reviews their outputs; a security report is checked only against
[when the report is complete](owasp-security.md#when-the-report-is-complete).
Verify model IDs with each installed host before dispatch.

### Cross-provider independent reviewers

Delegated QA Lead and Cybersecurity always run as separate sub-agents,
preferably on another provider than Organizer. A different effort of the same
model does not count. The preference never blocks the work.

| Organizer | Delegated QA Lead and Cybersecurity run on | If that provider is limited |
| --- | --- | --- |
| Claude Code | Codex: `gpt-6.1-sol`, effort `medium` | OpenCode: the role's OpenCode binding |
| Codex | Claude: `claude-sonnet-5-5`, effort `high` | OpenCode: the role's OpenCode binding |
| OpenCode | Claude: `claude-sonnet-5-5`, effort `high` | Codex: `gpt-6.1-sol`, effort `medium` |

When both are unavailable, use any other approved model as a separate
sub-agent, Organizer's own provider if need be. Record the model that ran and
that the review was not cross-provider; never present it as independent, and
never self-approve. A role the human talks to directly uses its conversation
binding and needs no sub-agent, but that is not an independent review.

### Other delegated Leads

Delegated Design Lead and Technical Lead use their conversation binding for the
organizing host. Technical Lead may share Organizer's context.

## Checking for limits

Claude and ChatGPT limit the whole subscription, so check the subscription.
OpenCode Go limits each model separately (5-hour, weekly, and monthly
allowances), so check the model.

- **Before use,** send `hi` through that CLI (and, on OpenCode Go, that model)
  at its lowest effort. An explicit
  limit or quota error means limited. No answer in 45 seconds is a failed check,
  not proof of a used-up quota. Either way, use the role's next choice for new
  work. A good answer counts for 10 minutes.
- **While a run works,** check the worker every 5 minutes
  ([watching a running worker](ai-task-delegation.md#watching-a-running-worker)).
  A provider that answers `hi` does not show the worker is working. A failed
  `hi` alone never stops a running worker. Hand over on an explicit limit error,
  the run's own failure, or a stall (20 minutes with no activity): confirm the
  worker stopped, then continue the same task on the next model from its
  worktree and `.AI` record
  ([model fallback](ai-task-delegation.md#model-fallback-and-safe-recovery)).
- Record each switch in the worker's result, with the model that ran.
- **When every model a role may use is exhausted,** stop: save a checkpoint,
  tell the human which limits were hit, and wait.

## Starting a run

Run each from the worktree its packet names, so it uses its own files and its
[own database](stack.md). No CLI runs in an OS sandbox ([delegation](delegation.md)):

```bash
opencode run -m opencode-go/deepseek-v4.1-flash --variant high "<task packet>"
codex exec -m gpt-6-luna -c model_reasoning_effort="high" --sandbox danger-full-access "<task packet>"
claude -p --model claude-haiku-5-5 --effort high "<task packet>"
agy --model <model> -p="<task packet>"
```

Start every worker in the background with `nohup`, so it keeps running when the
shell that started it exits. Send its output to the log file the
[stall check](ai-task-delegation.md#watching-a-running-worker) reads, and write
its process ID in its card:

```bash
log="<main-checkout>/.AI/<feature-slug>/<role>-<instance>.log"
nohup opencode run -m opencode-go/deepseek-v4.1-flash --variant high "<task packet>" > "$log" 2>&1 &
echo $!   # write this process ID in the card
```

Start the other commands above the same way: `nohup` before, `> "$log" 2>&1 &`
after. When the host has its own way to run a command in the background (such
as a background-task option), use it instead, still writing to the log file.
If the stall check finds the process gone right after starting it, the start
failed: read the log, fix the command, and do not count it as a stall.

The Codex profiles (`codex -p my-dev-team`, `codex -p my-tech-lead`, ...) also
turn the sandbox off: OpenCode cannot run inside Codex's sandbox, and a
sandboxed Codex worker cannot commit. Check each CLI's `--help` for the flags
the installed version supports.
