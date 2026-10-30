# Dev Team

A model-independent skill for software delivery through real sub-agents or
already-authorized CLIs. Organizer is the executing host (OpenCode, Claude Code,
Codex, etc.), **not a role**. It coordinates work while the ten roles retain their
domain authority and the human retains final authority. You talk directly to
five roles in one session: PO, Design Lead, Technical Lead, QA Lead, and
Cybersecurity. The host acts as each in turn, tells you which is speaking, and
switches when you ask or call `/my-po`, `/my-design-lead`, `/my-tech-lead`,
`/my-qa-lead`, or `/my-security`. The other roles are always delegated, and each
Lead reviews its own team's work.

Each role guide covers its working method, inputs, evidence, review, handoffs,
and authority boundaries.

## Package

- [Skill entrypoint](skills/my-dev-team/SKILL.md): role routing and supporting references.
- [Shared contract](skills/my-dev-team/references/contract.md): authority and access rules.
- [Feature workflow](skills/my-dev-team/references/orchestration.md): agreement through finished PR.
- [Delegation](skills/my-dev-team/references/delegation.md): stateless assignments and Lead review.
- [Persistent records](skills/my-dev-team/references/records.md): repo truth as HTML
  documents indexed by `README.md` files, and feature Issues.
- [Pause/resume](skills/my-dev-team/references/checkpoints.md): unfinished `.AI` state only.
- [Project defaults](skills/my-dev-team/references/project-defaults.md): the human's
  standard choices for a new project; an existing project keeps its own.
- [Standard stack](skills/my-dev-team/references/stack.md): the applications,
  repository layout, typed API contract, and identifiers for a new project.
- [Engineering](skills/my-dev-team/references/engineering.md),
  [design](skills/my-dev-team/references/design.md), and
  [quality](skills/my-dev-team/references/quality.md): detailed practices loaded as needed.

One installable `my-dev-team` skill contains ten role guides: PO, Technical Lead,
Senior Developer, Design Lead, Senior Designer, Design Tester, QA Lead, Senior QA,
DevOps, and Cybersecurity. Keeping the guides and shared references in one bundle
makes every handoff self-contained without copying rules into ten installations.

## Install

Requires Bash and Python 3. From this checkout:

```sh
./check.sh
./install.sh --dry-run
./install.sh
```

The default detects existing host configuration directories. Select hosts
explicitly, or use a custom skill directory:

```sh
./install.sh --target codex --target claude
./install.sh --target all --dry-run
./install.sh --skills-dir /path/to/skills
```

Every host gets the `my-dev-team` skill and a way to call each role directly:
`my-dev-team`, `my-po`, `my-design-lead`, `my-tech-lead`, `my-qa-lead`, and `my-security`.

| Host | Skill | Role commands | Call a role as |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills/my-dev-team` | Command files in `~/.claude/commands/` | `/my-po` |
| OpenCode | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/my-dev-team` | Command files in `.../opencode/commands/` | `/my-po` |
| Antigravity (`agy`) | `~/.gemini/config/skills/my-dev-team` | Role skills beside it; a skill is the slash command | `/my-po` |
| Codex | `${CODEX_HOME:-~/.codex}/skills/my-dev-team` | Role skills beside it; a skill is the command | `$my-po` |

`--target agy`, `antigravity`, and `gemini` all select Antigravity.

The installer also links each host's role-to-model binding: `model` and `effort`
in the Claude Code commands, an agent per role in
`.../opencode/agents/`, and a profile per role in `${CODEX_HOME:-~/.codex}/`
(`codex -p my-tech-lead`). The bindings are listed in the
[roster](skills/my-dev-team/references/roster.md). In Codex, organize from
`codex -p my-dev-team`. No CLI runs in an OS sandbox: each worker is kept to its
worktree by the worktree and its task packet.

Installation creates symlinks, so keep this checkout in place. Re-running is safe;
existing unrelated files/directories/links cause a clear failure before links are
created. The installer does not remove other skills, change a host's default
model, install CLIs, log in, or alter host permissions. Host discovery behavior and delegation
support must be verified in the target host; a successful link is not a live CLI test.
Use `--skills-dir` when the host's configured discovery directory differs.

## Use

Invoke `my-dev-team` in the host's skill or command syntax with the feature goal
or owning Issue. Call `my-po`, `my-design-lead`, `my-tech-lead`, `my-qa-lead`, or `my-security`
the same way to talk to that role directly, or just ask for it in the
conversation. Organizer loads only relevant
role guides and sends a complete task packet to each actual agent/CLI. If no real
delegation tool is available, it reports the limitation instead of claiming that a
review occurred.

The intended flow is: you agree the feature with PO and whichever of Design
Lead, Technical Lead, QA Lead, and Cybersecurity it needs, in one conversation →
each role pushes its agreed documents and PO creates the feature Issue, `draft`,
then `ready to implement` once you confirm → relevant Design, Technical, QA, and
Cybersecurity preparation → final technical package → Senior implementation →
Lead approval → QA execution and final AC verification → Cybersecurity feature
check (only what the diff touches) → finished PR for you. Trivial corrections are made by Organizer directly, and
small changes take a shorter owner route. Lead approval completes its scope;
downstream QA remains.

Repository docs hold current truth as HTML documents, indexed by `README.md`
files from the root down; the feature Issue holds lifetime history.
Bugs/gaps normally return to that same Issue. `.AI` holds only Markdown
checkpoints of unfinished work at pause, interruption, blockage, or context/model
handoff.

There is no launcher or OS sandbox. Every repository is treated as private and
sent only to models the human approved as safe. Every agent asks before reading
any credential. Technical Lead gives each Senior a git worktree that holds no real
env file. The team works on whatever source control the repository uses (GitHub,
GitLab, or another host) when you call it.

## Models

Which model runs each role. The [roster](skills/my-dev-team/references/roster.md)
is the authoritative copy and holds the rules; change both together.

### Roles you talk to

| Role | Claude Code | Codex | OpenCode |
| --- | --- | --- | --- |
| PO | Sonnet 5.5, high | GPT-6.1 Sol, medium | `deepseek-v4.1-flash`, max |
| Design Lead | Sonnet 5.5, high | GPT-6.1 Sol, medium | `glm-5.3-flash`, max |
| Technical Lead | Opus 5.5, high | GPT-6.1 Sol, high | `mimo-v2.6-pro` |
| QA Lead | Sonnet 5.5, high | GPT-6 Astra, medium | `gpt-6-luna`, high |
| Cybersecurity | Sonnet 5.5, high | GPT-6.1 Sol, medium | `glm-5.3-flash`, max |

### Delegated roles

| Role | Model | Notes |
| --- | --- | --- |
| Senior pool 1 | Codex `gpt-6-luna`, high | Senior Developer, Senior Designer, and Senior QA; up to three at once. Simplest slices; used last when Codex organizes |
| Senior pool 2 | Claude `claude-haiku-5-5`, high | Used last when Claude Code organizes |
| Senior pool 3 | OpenCode `deepseek-v4.1-flash`, high | |
| Senior pool 4 to 6 (free) | OpenCode `deepseek-v4.1-flash-free`, `glm-5.3-flash-free`, `minimax-m3.1-flash-free` | Only when 1 to 3 are limited; never for client-work repos |
| Design Tester | OpenCode `mimo-v2.6-flash` | |
| Senior QA | A Senior pool model | Never the model a Senior Developer on the same feature uses; skips `gpt-6-luna` while another is free |
| DevOps | Claude Sonnet 5.5 medium, Codex `gpt-6-sol` medium, or OpenCode `mimo-v2.6-flash`, by host | Always delegated |
| QA Lead and Cybersecurity, delegated | Preferably a different provider from the Organizer: Codex `gpt-6.1-sol` medium under Claude Code; Claude Sonnet 5.5 high under Codex or OpenCode | If that provider is rate-limited: OpenCode under Claude Code or Codex, Codex under OpenCode |
| Lead backups | Technical Lead: Sol high, `mimo-v2.6-pro`, `deepseek-v4.1-flash` max, `deepseek-v4.1-flash-free`. Design Lead: Sol medium, `glm-5.3-flash` max, `claude-haiku-5-5` xhigh (OpenCode Go), `glm-5.3-flash-free`. QA Lead: Astra medium, Sonnet 5.5 high, `claude-haiku-5-5` xhigh (OpenCode Go), `minimax-m3.1-flash-free`. Cybersecurity: Sol medium, Sonnet 5.5 high, `claude-haiku-5-5` xhigh (OpenCode Go), `minimax-m3.1-flash-free` | Free last backup never for client-work repos, nor for a draft release review |
| PO and DevOps backups | The three OpenCode free models: `deepseek-v4.1-flash-free`, `glm-5.3-flash-free`, `minimax-m3.1-flash-free` | Never for client-work repos; DevOps never where it would read production configuration |
| Every model at its limit | Stop and report | |

### Scores

[Artificial Analysis Intelligence Index](https://artificialanalysis.ai/leaderboards/models),
read on 2026-10-14. The index measures general intelligence, not coding alone.
Cost per task is from API prices; on a subscription, read it as how fast a model
uses the limit. Wait is the time before the first words of an answer.

| Model | Through | Effort | Score | Cost per task | Wait (s) |
| --- | --- | --- | --- | --- | --- |
| Claude Opus 5.5 | Claude | xhigh | 56 | $3.46 | 159 |
| Claude Opus 5.5 | Claude | high | 54 | $1.82 | 53 |
| Claude Sonnet 5.5 | Claude | xhigh | 52 | $2.01 | 38 |
| Claude Sonnet 5.5 | Claude | high | 47 | $0.88 | 14 |
| Claude Sonnet 5.5 | Claude | medium | 41 | $0.48 | 1 |
| Claude Haiku 5.5 | Claude | high | 38 | $0.08 | 25 |
| GPT-6 Astra | Codex | high | 51 | $1.73 | 111 |
| GPT-6 Astra | Codex | medium | 50 | $1.54 | 6 |
| GPT-6.1 Sol | Codex | high | 50 | $0.32 | 60 |
| GPT-6.1 Sol | Codex | medium | 48 | $0.21 | 8 |
| GPT-6 Luna | Codex or OpenCode Go | xhigh | 35 | $0.04 | 42 |
| GPT-6 Luna | Codex or OpenCode Go | high | 33 | $0.03 | 20 |
| `mimo-v2.6-pro` | OpenCode Go | none | 46 | $0.13 | 4 |
| `glm-5.3` | OpenCode Go | max | 45 | $2.01 | 3 |
| `qwen3.8-max` | OpenCode Go | none | 45 | $5.41 | 3 |
| `kimi-k3` | OpenCode Go | max | 44 | $2.00 | 3 |
| `claude-haiku-5-5` | OpenCode Go | max | 43 | $0.21 | 310 |
| `claude-haiku-5-5` | OpenCode Go | xhigh | 41 | $0.12 | 73 |
| `glm-5.3-flash` | OpenCode Go | none | 42 | $0.28 | 3 |
| `deepseek-v4.1-flash` | OpenCode Go | max | 39 | $0.27 | 1 |
| `mimo-v2.6-flash` | OpenCode Go | none | 38 | $0.06 | 3 |
| `deepseek-v4-pro` | OpenCode Go | max | 36 | $0.67 | 2 |
| `minimax-m3` | OpenCode Go | none | 29 | $0.51 | 1 |
| `hy3` | OpenCode Go | none | 25 | $0.07 | 3 |
| `longcat-2.0` | OpenCode Go | none | 19 | $0.15 | 3 |

The Haiku xhigh, `hy3` and `longcat-2.0` rows were read on 2026-10-27.
`gpt-6-sol` and `qwen3.8-flash` are not on the leaderboard. An
effort of "none" means the leaderboard lists a single result for the model.

## Check

`./check.sh` checks shell syntax, skill identity, all ten role guides, local resource
links, resource reachability, the HTML project-doc rule, and installer behavior in
isolated temporary homes.
Tests cover reruns, host selection, environment paths, dry runs, collisions,
literal path handling, and preservation of existing content. They do not run agents,
contact GitHub, or prove model compliance. No Python packages are required.

This is a standalone bundle with no installation or runtime dependency on any
other skill. Each role is bound to a model in the roster, and the human can
change any binding at any time.
