# Roster: which model runs each role

The role guides never name a model; this page is the one place that does. The
human chose these bindings and may change any of them. Change one only when the
human says so, here and in the host file below, in the same edit.

## Rules for any binding

- A reviewer runs on a different model from the work it reviews: a Lead and its
  Seniors, Design Tester and Senior Designer, QA and the developers.
- Fallback keeps reviewer independence while any paid route is available. Only
  when OpenCode Go, Claude, and Codex are all at their limit may a free model
  be used (see [free models](#free-models)); independence can then be lost.
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
- PO and DevOps have no paid backups. When limited, they go straight to the
  [free models](#free-models), in order: never for client work, and DevOps never
  where it would read production configuration.

## Delegated roles

Organizer starts delegated work as separate CLI runs. A Senior Developer and
Senior QA paired on a slice are the exception: they use the same worktree with
sequential write ownership ([worktrees](delegation.md#worktrees-keep-secrets-out-of-delegated-work)).

### Senior pool

Senior Designer uses the Senior pool below. Senior Developer and Senior QA use
the OpenCode Go route below. Independent tasks and independent Dev/QA pairs may
run in parallel; the work inside one pair is sequential.

| Order | Runs through | Subscription | Model | Effort |
| --- | --- | --- | --- | --- |
| 1 | Codex | ChatGPT | `gpt-6-luna` | `high` |
| 2 | Claude | Claude | `claude-haiku-5-5` | `high` |
| 3 | OpenCode | OpenCode Go | `opencode-go/deepseek-v4.1-flash` | `high` |

- Senior Developer normally uses OpenCode Go `opencode-go/deepseek-v4.1-flash`;
  Senior QA uses the distinct OpenCode Go model `opencode-go/mimo-v2.6-flash`.
  The reviewer model must differ from the model used for the code it reviews.
- If OpenCode Go returns an explicit quota-limit response, a pair worker
  continues on the paid pool rows above (Codex `gpt-6-luna`, Claude
  `claude-haiku-5-5`), keeping Senior QA on a different model from the Senior
  Developer whose code it confirms. A transient error or slow response is not a
  quota limit. Free models come only after OpenCode Go, Claude, and Codex are
  all at their limit ([free models](#free-models)).
- **Spare the host's subscription.** Take models from the top, but use the one
  on the organizing host's subscription last: `claude-haiku-5-5` under Claude
  Code, `gpt-6-luna` under Codex.
- **Match the slice to the model.** `gpt-6-luna` is the cheapest and weakest
  coder; give it the simplest, most self-contained slices.
- Senior QA uses `opencode-go/mimo-v2.6-flash`, distinct from Senior
  Developer's `opencode-go/deepseek-v4.1-flash`, so implementation and
  integration tests come from different models.
- At a limit on the Senior Designer pool, continue on the next available model
  in the pool, then the [free models](#free-models).

### Free models

Three OpenCode free models, used in this order: `opencode/deepseek-v4.1-flash-free`,
`opencode/glm-5.3-flash-free`, `opencode/minimax-m3.1-flash-free`. They may
train on what they are sent, so never for client work.

- **Last resort for Seniors and Design Tester:** only when OpenCode Go, Claude,
  and Codex are all at their limit. Any free model is then acceptable, even one
  that also produced the work being reviewed. Prefer a different one, and record
  that independence could not be kept. Do not stop for this.
- **Backups for the Leads, PO, and DevOps** are listed above.
- **One free-model run at a time** across the team, Organizer included. Wait for
  the active free-model run to stop before starting another; never parallelize
  free-model work.
- When every free model is also at its limit, stop and report with a checkpoint.

### Design Tester

Design Tester runs outside the Senior pool, so it never runs on the model that
made the design it checks.

| Role | Runs through | Model | Effort |
| --- | --- | --- | --- |
| Design Tester | OpenCode | `opencode-go/mimo-v2.6-flash` | (none to set) |

When OpenCode Go returns an explicit quota-limit response, Design Tester uses a
paid pool model other than the one that made the design. Only when OpenCode Go,
Claude, and Codex are all at their limit does it use the [free models](#free-models).

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
