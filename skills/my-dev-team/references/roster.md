# Roster: which model runs each role

The role guides never name a model; this page is the one place that does. The
human chose these bindings and may change any of them. Change one only when the
human says so, here and in the host file below, in the same edit.

## Rules for any binding

- A reviewer runs on a different model from the work it reviews: a Lead and its
  Seniors, Design Tester and Senior Designer, QA and the developers.
- Fallback keeps reviewer independence while any paid route is available. Paid
  models come before any free model. A free model is used only when every paid
  model in the role's row is limited (see [free models](#free-models));
  independence can then be lost.
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
| Design Lead | `claude-opus-5-5`, effort `medium` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |
| Technical Lead | `claude-opus-5-5`, effort `medium` | `gpt-6.1-sol`, effort `high` | `opencode-go/gemini-4-argon`, variant `medium` |
| QA Lead | `claude-opus-5-5`, effort `medium` | `gpt-6-astra`, effort `medium` | `opencode-go/gpt-6-luna`, variant `high` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6.1-sol`, effort `medium` | `opencode-go/glm-5.3-flash`, variant `max` |

Antigravity has no binding: a role there runs on the session's model.
Organizer is the host session itself, not a role; in Claude Code, run it on
`claude-sonnet-5-5`, effort `high`, so Claude Max is kept for the Leads and the
developers.

| Host | Where the binding lives | How the human uses it |
| --- | --- | --- |
| Claude Code | `model` and `effort` in each role command | `/my-tech-lead <message>`. It applies to that turn only; call it again, or set the session model, for a long talk with one role. |
| OpenCode | One agent per role, with `model` and `variant`; the command names the agent | `/my-tech-lead`, or switch agent with Tab and stay in it. |
| Codex | One profile per role | Start on the role: `codex -p my-tech-lead`. `$my-tech-lead` keeps the session's model; switch with `/model` when it matters. |

When the human asks a role something mid-turn, answer on the model already
running, and say so if the role's own model would matter.

## Plan

Claude Max carries the judgement and the code; OpenCode Go carries the testing
and the paperwork; Codex carries the independent approvals.

| Provider | Roles |
| --- | --- |
| Claude (Max) | Organizer, PO, Technical Lead, Design Lead, Senior Developer, Senior Designer, DevOps; QA Lead and Cybersecurity in conversation |
| OpenCode Go | Senior QA, drafting runs for every Lead, backups |
| Codex | QA Lead and Cybersecurity when delegated, Design Tester |
| Antigravity | Nothing automatic; a design second opinion when the human asks |

## Delegated roles

Organizer starts delegated work as separate CLI runs. A Senior Developer and
Senior QA paired on a slice are the exception: they use the same worktree and
write concurrently to separately owned files ([worktrees](delegation.md#worktrees-keep-secrets-out-of-delegated-work)).

When a role's model is limited ([checking for limits](#checking-for-limits)),
it moves along its row, skipping any limited model and any model the row's
rules exclude.

| Role | Model | Backups, in order | Free, last |
| --- | --- | --- | --- |
| Technical Lead | Claude `claude-opus-5-5` `medium` | `gpt-6.1-sol` `high`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/kimi-k3.1-pro` `high`; `opencode-go/deepseek-v4.1-flash` `max` | `opencode/deepseek-v4.1-flash-free` |
| Design Lead | Claude `claude-opus-5-5` `medium` | `gpt-6.1-sol` `medium`; `opencode-go/gemini-4-argon` `medium`; `opencode-go/glm-5.3-flash` `max` | `opencode/glm-5.3-flash-free` |
| QA Lead | Codex `gpt-6-astra` `medium` | `opencode-go/gemini-4-argon` `medium`; `opencode-go/kimi-k3.1-pro` `high`; Claude `claude-opus-5-5` `medium` | `opencode/deepseek-v4.1-flash-free` |
| Cybersecurity | Codex `gpt-6.1-sol` `medium` | `opencode-go/gemini-4-argon` `medium`; `opencode-go/minimax-m3.1-flash` `high` | `opencode/deepseek-v4.1-flash-free`, never for a release review |
| PO | not delegated; backups when its conversation model is limited | `opencode-go/deepseek-v4.1-flash` `max`; `opencode-go/glm-5.3-flash` `max`; `opencode-go/mimo-v2.6-flash` | the [free models](#free-models), in order |
| DevOps | Claude `claude-sonnet-5-5` `medium` | `opencode-go/mimo-v2.6-flash`; `opencode-go/deepseek-v4.1-flash` `high`; `opencode-go/glm-5.3-flash` `high` | the free models, never where it reads production configuration |
| Senior Developer | Claude `claude-sonnet-5-5` `medium`, at most two at once | `opencode-go/deepseek-v4.1-flash` `high`; `opencode-go/mimo-v2.6-flash`; `opencode-go/minimax-m3.1-flash` `high`; `opencode-go/glm-5.3-flash` `high` | the free models |
| Senior Designer | Claude `claude-sonnet-5-5` `medium` | `opencode-go/deepseek-v4.1-flash` `high`; `opencode-go/claude-haiku-5-5` `high`; `opencode-go/mimo-v2.6-flash` | the free models |
| Senior QA | `opencode-go/deepseek-v4.1-flash` `high` | `opencode-go/mimo-v2.6-flash`; `opencode-go/glm-5.3-flash` `high`; `opencode-go/minimax-m3.1-flash` `high` | the free models |
| Design Tester | Codex `gpt-6.1-sol` `medium` | `opencode-go/mimo-v2.6-flash`; `opencode-go/glm-5.3-flash` `high` | the free models |
| Drafting run (any Lead) | `opencode-go/mimo-v2.6-flash` | `opencode-go/glm-5.3-flash` `high`; `opencode-go/minimax-m3.1-flash` `high`; `opencode-go/deepseek-v4.1-flash` `high` | none: the Lead does the work itself |

**Never the same model on both sides.** A reviewer never runs on the model that
made the work, at any effort level. Skip that model in the row:

- Delegated QA Lead and Cybersecurity never run on `claude-sonnet-5-5`, which
  writes the code, and skip whatever model Technical Lead is running. (In
  conversation with the human they keep their conversation binding: they agree
  requirements there, and review nothing.)
- Senior QA never runs on the model its paired Senior Developer is using.
- Design Tester never runs on the model that made the design, and a Senior
  Designer skips the model its Design Lead is running.
- A drafting run's text is checked by its Lead, who runs on a different model.

**Load.** Claude Max is shared by Organizer, the Leads on Opus, and every Sonnet
worker. Run at most two Sonnet Senior Developers at once; a third waits or
starts on its first Go backup. Senior Designers and DevOps are not counted:
they rarely run alongside implementation. If they do and Claude runs short,
they move to their Go backups first. When Claude is
limited, the workers move to their Go backups first, so the Leads keep Claude.

**Backups.** `gemini-4-argon` through OpenCode Go is the strong backup: it
scores close to Sol and Opus, and Go gives it its own allowance. Use it at
`medium`, and through Go, not Antigravity, whose weekly limit is small.
`kimi-k3.1-pro` is strong but has a small allowance: Lead turns only. OpenCode
Go does not offer Sol; OpenCode's `openai/gpt-6.1-sol` runs on the same
ChatGPT subscription as Codex, so it adds nothing once Sol is limited.

**Match the slice to the model.** When a Senior Developer falls back to
`deepseek-v4.1-flash`, give it the simpler, self-contained slices. Its peak
hours (01:00-04:00 and 06:00-10:00 UTC on weekdays) use the allowance twice as
fast; queue large batches outside them when you can.

A transient error or a slow response is not a limit.

### Drafting runs

A Lead (PO and Cybersecurity included) may start a drafting run: its own role,
run on a cheap OpenCode Go model, for work that does not need its judgement.
It is not a new role. Use one to:

- pre-review an Issue, a document, or a diff against a checklist (missing
  sections, untestable AC, docs not updated, missing method comments, env files
  in the diff); every finding cites a file and line, or a command and its
  output;
- draft the Lead's document updates or its Issue section from decisions the
  Lead already made.

A drafting run never decides, approves, posts to the Issue, or commits. It
returns text or a diff. The Lead checks it, changes what is wrong, and only
then posts or commits it. Its findings never block: the Lead decides each one.
Start it like any worker ([starting a run](#starting-a-run)), with a packet
that names the checklist or the decisions to write up.

### Free models

Used in this order: `opencode/deepseek-v4.1-flash-free`, then
`opencode/glm-5.3-flash-free`. Both keep no data and do not train on it. Both
are free for a limited time. Never for client work.

- **Last resort:** only when every paid model in the role's row is limited. Any free model is then acceptable, even one that also
  produced the work being reviewed. Prefer a different one, and record that
  independence could not be kept.
- **One free-model run at a time** across the team, Organizer included. Wait for
  the active free-model run to stop before starting another; never parallelize
  free-model work.
- When every free model is also at its limit, stop and report with a checkpoint.
- Not used: `mimo-v2.6-pro`, `beam-free`, `longcat-2.0`, `qwen3.8-flash`,
  `iceman-contributor-free`, `mimo-v2.6-flash-free`, and
  `opencode/minimax-m3.1-flash-free` (no longer offered).

### Independent reviewers

Delegated QA Lead and Cybersecurity always run as separate sub-agents, on a
different provider from the code's author. The code is written on Claude, so
they run on Codex, whichever host organizes. When Codex is limited, they use
their Go backups; Claude `claude-opus-5-5` is QA Lead's last paid backup.
Record the model that ran; when a review could not stay on another provider,
say so and never present it as independent. Never self-approve. A role the
human talks to directly uses its conversation binding and needs no sub-agent,
but that is not an independent review.

Technical Lead reviews DevOps and Cybersecurity output; a security report is
checked only against
[when the report is complete](owasp-security.md#when-the-report-is-complete).
Verify model IDs with each installed host before dispatch.

## Checking for limits

Claude and ChatGPT limit the whole subscription, so check the subscription.
OpenCode Go limits each model separately (5-hour, weekly, and monthly
allowances), so check the model.

- **Before use,** send `hi` through that CLI (and, on OpenCode Go, that model)
  at its lowest effort. An explicit
  limit or quota error means limited. No answer in 45 seconds is a failed check,
  not proof of a used-up quota. Either way, use the role's next choice for new
  work. A good answer counts for 10 minutes.
- **While a run works,** do not send `hi`. Check the worker itself every 5
  minutes ([watching a running worker](ai-task-delegation.md#watching-a-running-worker)):
  its JSON log, files, card, and CPU. Hand over on a limit error in the log or
  a failed resume, the run's own failure, or a stall that a resume and a
  restart did not clear: confirm the worker stopped, then continue the same
  task on the next model from its worktree and `.AI` record
  ([model fallback](ai-task-delegation.md#model-fallback-and-safe-recovery)).
- Record each switch in the worker's result, with the model that ran.
- **When every model a role may use is exhausted,** stop: save a checkpoint,
  tell the human which limits were hit, and wait.

## Starting a run

Run each worker from the worktree its packet names, so it uses its own files and
its [own database](stack.md). No CLI runs in an OS sandbox
([delegation](delegation.md)).

Start every worker in the background, writing JSON events to its log file, and
record two things in its card: the process ID and the session ID.

Take the CLI, model, and effort from the role's row in
[delegated roles](#delegated-roles), or from the backup in use.

```bash
log="<main-checkout>/.AI/<feature-slug>/<role>-<instance>.log"

# Claude: <model> is claude-opus-5-5 for a delegated Lead, claude-sonnet-5-5 for a worker
nohup claude -p --model <model> --effort <effort> --output-format stream-json --verbose "<task packet>" < /dev/null > "$log" 2>&1 &
# OpenCode Go: Senior QA, drafting runs, Go backups
nohup opencode run -m opencode-go/<model> --variant <effort> --format json "<task packet>" < /dev/null > "$log" 2>&1 &
# Codex: QA Lead (gpt-6-astra), Cybersecurity and Design Tester (gpt-6.1-sol)
nohup codex exec -m <model> -c model_reasoning_effort="<effort>" --sandbox danger-full-access --json "<task packet>" < /dev/null > "$log" 2>&1 &

echo $!   # the process ID: write it in the card
```

For example, Senior QA: `opencode run -m opencode-go/deepseek-v4.1-flash --variant high ...`;
a Senior Developer: `claude -p --model claude-sonnet-5-5 --effort medium ...`.
Omit `--variant` for a Go model that has none, such as `mimo-v2.6-flash`.

- `nohup` keeps the worker running when the shell that started it exits. When
  the host has its own way to run a command in the background (such as a
  background-task option), use it instead, still writing to the log file.
- `< /dev/null` matters: `codex exec` otherwise waits for more input and hangs.
- If the process is gone right after starting, the start failed: read the log,
  fix the command, and do not count it as a stall.
- Antigravity (`agy --model <model> -p="<task packet>"`) has no JSON event log
  here; watch it by its files, card, and CPU only.

**The session ID** is in the first lines of the log. Write it in the card:

| CLI | Find it with |
| --- | --- |
| OpenCode | `grep -o -m1 '"sessionID":"[^"]*"' "$log"` |
| Codex | `grep -o -m1 '"thread_id":"[^"]*"' "$log"` |
| Claude | `grep -o -m1 '"session_id":"[^"]*"' "$log"` |

**Resuming a session** keeps the worker's context. Use it for the status
question in the [stall check](ai-task-delegation.md#watching-a-running-worker).
Append to the same log (`>>`):

```bash
nohup opencode run -m <same model> --variant <same variant> --session <id> --format json "<prompt>" < /dev/null >> "$log" 2>&1 &
nohup codex exec resume <id> -c sandbox_mode="danger-full-access" --json "<prompt>" < /dev/null >> "$log" 2>&1 &
nohup claude -p --resume <id> --model <same model> --output-format stream-json --verbose "<prompt>" < /dev/null >> "$log" 2>&1 &
```

Write the new process ID in the card. Check each CLI's `--help` for the flags
the installed version supports.

The Codex profiles (`codex -p my-dev-team`, `codex -p my-tech-lead`, ...) also
turn the sandbox off: OpenCode cannot run inside Codex's sandbox, and a
sandboxed Codex worker cannot commit.
