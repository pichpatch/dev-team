# Roster: which model runs each role

The role guides never name a model; this page is the one place that does. The
human chose these bindings and may change any of them. Change one only when the
human says so, here and in the host file below, in the same edit.

## Rules for any binding

- A reviewer runs on a different model from the work it reviews: a Lead and its
  Seniors, Design Tester and Senior Designer, QA and the developers.
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
| Technical Lead | `claude-opus-5-5`, effort `high` | `gpt-6.1-sol`, effort `high` | `opencode-go/mimo-v2.6-pro` |
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

### Backups for the Leads

When a Lead's subscription is limited ([checking for limits](#checking-for-limits)),
it moves down its row, skipping its own primary and any limited subscription:

| Lead | Backup 1 | Backup 2 | Backup 3 | Backup 4 (free) |
| --- | --- | --- | --- | --- |
| Technical Lead | `gpt-6.1-sol`, `high` | `opencode-go/mimo-v2.6-pro` | `opencode-go/deepseek-v4.1-flash`, `max` | `opencode/deepseek-v4.1-flash-free` |
| Design Lead | `gpt-6.1-sol`, `medium` | `opencode-go/glm-5.3-flash`, `max` | `opencode-go/claude-haiku-5-5`, `xhigh` | `opencode/glm-5.3-flash-free` |
| QA Lead | `gpt-6-astra`, `medium` | `claude-sonnet-5-5`, `high` | `opencode-go/claude-haiku-5-5`, `xhigh` | `opencode/minimax-m3.1-flash-free` |
| Cybersecurity | `gpt-6.1-sol`, `medium` | `claude-sonnet-5-5`, `high` | `opencode-go/claude-haiku-5-5`, `xhigh` | `opencode/minimax-m3.1-flash-free` |

- QA Lead and Cybersecurity also skip whatever model Technical Lead is running.
- Delegated QA Lead and Cybersecurity use the
  [cross-provider route](#cross-provider-independent-reviewers) first; this
  chain applies after it.
- Backup 4 is free and may train on what it is sent: never for client work.
  Cybersecurity never uses it for a release review, where it may read
  production configuration; it stops and reports instead.
- PO and DevOps have no paid backups. When limited, they go straight to
  `opencode/deepseek-v4.1-flash-free`, then `opencode/glm-5.3-flash-free`, then
  `opencode/minimax-m3.1-flash-free`: never for client work, and DevOps never
  where it would read production configuration.

## Delegated roles

Organizer starts these as separate CLI runs, each in its own worktree.

### Senior pool

Senior Developer, Senior Designer, and Senior QA work. Up to three at once.

| Order | Runs through | Subscription | Model | Effort |
| --- | --- | --- | --- | --- |
| 1 | Codex | ChatGPT | `gpt-6-luna` | `high` |
| 2 | Claude | Claude | `claude-haiku-5-5` | `high` |
| 3 | OpenCode | OpenCode Go | `opencode-go/deepseek-v4.1-flash` | `high` |
| 4 (free) | OpenCode | OpenCode free | `opencode/deepseek-v4.1-flash-free` | `high` |
| 5 (free) | OpenCode | OpenCode free | `opencode/glm-5.3-flash-free` | `max` |
| 6 (free) | OpenCode | OpenCode free | `opencode/minimax-m3.1-flash-free` | `high` |

- **Free rows 4–6** only when 1–3 are limited, and never for client work.
  `opencode/glm-5.3-flash-free` does no Senior Designer work (same model as the
  OpenCode Design Lead).
- **Spare the host's subscription.** Take models from the top, but use the one
  on the organizing host's subscription last: `claude-haiku-5-5` under Claude
  Code, `gpt-6-luna` under Codex.
- **Match the slice to the model.** `gpt-6-luna` is the cheapest and weakest
  coder; give it the simplest, most self-contained slices.
- **Senior QA writes test code,** so it runs on a pool model, never the one any
  Senior Developer on the same feature is using, so tests and code never come
  from the same model. Skip `gpt-6-luna` for it while another model is free.
- **At a limit,** continue that Senior's task on the next model not already
  running a task.

### Design Tester

Design Tester runs outside the Senior pool, so it never runs on the model that
made the design it checks.

| Role | Runs through | Model | Effort |
| --- | --- | --- | --- |
| Design Tester | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |

A limited Design Tester uses Senior pool rows 4–6 in order, skipping the model
that produced the work it tests.

### DevOps and Cybersecurity

They do not use the Senior pool. DevOps is always delegated. Cybersecurity in
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

Limits are per subscription (Claude, ChatGPT, OpenCode Go, OpenCode free), so
check the subscription, not each model.

- **Before use,** send `hi` through that CLI at its lowest effort. An explicit
  limit or quota error means limited. No answer in 45 seconds is a failed check,
  not proof of a used-up quota. Either way, use the role's next choice for new
  work. A good answer counts for 10 minutes.
- **While a run works,** check its subscription every 10 minutes. If it answers,
  the run is just slow: keep waiting. A failed check never stops a running
  worker. Hand over only on an explicit limit error or the run's own failure:
  confirm the worker stopped, then continue the same task on the next model from
  its worktree and `.AI` record ([model fallback](ai-task-delegation.md#model-fallback-and-safe-recovery)).
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
agy -p --model <model> "<task packet>"
```

The Codex profiles (`codex -p my-dev-team`, `codex -p my-tech-lead`, ...) also
turn the sandbox off: OpenCode cannot run inside Codex's sandbox, and a
sandboxed Codex worker cannot commit. Check each CLI's `--help` for the flags
the installed version supports.
