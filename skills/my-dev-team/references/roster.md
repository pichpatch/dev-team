# Roster: which model runs each role

The role guides never name a model. This page is the one place that does. The
human chose these bindings; change one only when the human says so, and change
it here and in the host file listed below in the same edit.

## Roles the human talks to

Each host runs the four conversation roles on these models:

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | `claude-opus-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `opencode-go/deepseek-v4.1-flash`, variant `max` |
| Design Lead | `claude-opus-5-5`, effort `high` | `gpt-6-astra`, effort `medium` | `opencode-go/qwen3.8-max`, variant `xhigh` |
| Technical Lead | `claude-opus-5-5`, effort `high` | `gpt-6-astra`, effort `high` | `opencode-go/mimo-v2.6-pro` |
| QA Lead | `claude-sonnet-5-5`, effort `xhigh` | `gpt-6.1-sol`, effort `high` | `gpt-6-luna` |

Antigravity has no binding: a role there runs on the model the session is using.

## Delegated role mappings agreed so far

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| Senior Developer | `claude-sonnet-5-5`, effort `medium` | `gpt-6-luna`, effort `high` | `opencode-go/deepseek-v4.1-flash`, variant `max` |

Senior QA, Senior Designer, Design Tester, and delegated Lead executions remain subject to separate reconciliation with `main` and are not changed by the DevOps/Cybersecurity decision.

### Dedicated DevOps and Cybersecurity models

These two roles do not use the shared Senior pool. When delegated, they run as real sub-agents with the host-specific mapping below. A direct human conversation with either role stays on the current session model.

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| DevOps | `claude-sonnet-5-5`, effort `medium` | `gpt-6-sol`, effort `medium` | `opencode-go/mimo-v2.6-flash` |
| Cybersecurity | `claude-sonnet-5-5`, effort `high` | `gpt-6-sol`, effort `high` | `opencode-go/gpt-6-luna`, variant `high` |

Technical Lead reviews DevOps and Cybersecurity work. Security-sensitive production changes still require human approval; complex security cases may consult Technical Lead without silently switching the Cybersecurity model. Verify exact model identifiers against the installed provider before execution.

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

Senior Developer, DevOps, and Cybersecurity have explicit mappings above. DevOps and Cybersecurity are dedicated roles and never draw from the Senior worker pool. For other delegated roles not yet reconciled on this PR branch, consult the current `main` roster before changing their mappings; do not silently substitute the parent model.
