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
- [Performance](skills/my-dev-team/references/performance.md): hard rules for bulk
  writes (batches of 500), indexes (proof of concept, then the human decides),
  endpoints split by speed, and jobs that hand off before the runner's time limit.

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

On Windows (PowerShell), use the equivalent scripts: `./check.ps1`, `./install.ps1 -DryRun`,
`./install.ps1`, with `-Target codex,claude`. Without Developer Mode, Windows cannot create
symlinks, so `install.ps1` copies the files instead; re-run `./install.ps1 -Update` after
changing this checkout. If scripts are blocked, run once:
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

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
PO creates the feature Issue, `draft`, and each role writes what it agreed into
its own Issue section, then `ready to implement` once you confirm → relevant Design, Technical, QA, and
Cybersecurity preparation → final technical package → Senior implementation →
Lead approval → QA execution and final AC verification → Cybersecurity feature
check (only what the diff touches) → finished PR for you. From `ready to
implement` the team runs to the PR without asking you to confirm steps: it
records what it assumed, and the PR is its one report, with the commands to test
it and a numbered list of anything left for you to decide. Every PR also shows
the updated regression document and user manual, or says `No new regression
test` or `No manual update` with the reason; the regression document stays ready
to run in full, and a full run happens only when you ask. Answer with a
numbered list of fixes and it runs them in one pass. Trivial corrections are made by Organizer directly, and
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
| Design Lead | Opus 5.5, medium | GPT-6.1 Sol, medium | `glm-5.3-flash`, max |
| Technical Lead | Opus 5.5, medium | GPT-6.1 Sol, high | `gemini-4-argon`, medium |
| QA Lead | Opus 5.5, medium | GPT-6 Astra, medium | `gpt-6-luna`, high |
| Cybersecurity | Sonnet 5.5, high | GPT-6.1 Sol, medium | `glm-5.3-flash`, max |

### Delegated roles

Claude Max carries the judgement and the code, OpenCode Go the testing and the
paperwork, Codex the independent approvals. Organizer runs on Sonnet 5.5 high in
Claude Code.

| Role | Model | Backups, then notes |
| --- | --- | --- |
| Technical Lead | Claude Opus 5.5 medium | Sol high, `gemini-4-argon` medium, `kimi-k3.1-pro`, `deepseek-v4.1-flash` max |
| Design Lead | Claude Opus 5.5 medium | Sol medium, `gemini-4-argon` medium, `glm-5.3-flash` max. Owns the Design System and approves every change to it |
| QA Lead | Codex `gpt-6-astra` medium | `gemini-4-argon` medium, `kimi-k3.1-pro`, Opus 5.5 medium. Never Sonnet, which writes the code |
| Cybersecurity | Codex `gpt-6.1-sol` medium | `gemini-4-argon` medium, `minimax-m3.1-flash`. Never Sonnet; never a free model for a release review |
| Senior Developer | Claude Sonnet 5.5 medium, at most two at once | Go `deepseek-v4.1-flash` high, `mimo-v2.6-flash`, `minimax-m3.1-flash`, `glm-5.3-flash` |
| Senior Designer | Claude Sonnet 5.5 medium | Go `deepseek-v4.1-flash` high, `claude-haiku-5-5` high, `mimo-v2.6-flash`. Maintains the Design System; Design Lead approves |
| DevOps | Claude Sonnet 5.5 medium | Go `mimo-v2.6-flash`, `deepseek-v4.1-flash`, `glm-5.3-flash` |
| Senior QA | OpenCode Go `deepseek-v4.1-flash` high | `mimo-v2.6-flash`, `glm-5.3-flash`, `minimax-m3.1-flash`. Never its paired Developer's model |
| Design Tester | Codex `gpt-6.1-sol` medium | Go `mimo-v2.6-flash`, `glm-5.3-flash`. Never the designer's model |
| Drafting runs (any Lead) | OpenCode Go `mimo-v2.6-flash` | `glm-5.3-flash`, `minimax-m3.1-flash`, `deepseek-v4.1-flash`. Pre-review and paperwork; the Lead checks before posting |
| PO backups | Go `deepseek-v4.1-flash` max, `glm-5.3-flash` max, `mimo-v2.6-flash` | Then the free models |
| Free models, last resort | `deepseek-v4.1-flash-free`, then `glm-5.3-flash-free` | Only when every paid model in the role's row is limited; one run at a time; never for client work |
| Every model at its limit | Stop and report | |

### Scores and allowances

[Artificial Analysis Intelligence Index](https://artificialanalysis.ai/leaderboards/models),
read on 2026-11-03, after the index was re-based (every model scores lower than
on the earlier scale). It measures general intelligence, not coding alone.
Requests are OpenCode's own estimates for the Go plan, from
[its Go page](https://opencode.ai/docs/go/), read on 2026-11-03. Each model has
its own monthly limit per plan, so the drop from Go Plus is not the same for
every model. Claude and ChatGPT models share their subscription's limit.

| Model | Through | Effort | Score | Requests per 5 h (Go) | Per week |
| --- | --- | --- | --- | --- | --- |
| Claude Opus 5.5 | Claude | high | 52 | subscription | |
| GPT-6 Astra | Codex | medium | 51 | subscription | |
| GPT-6.1 Sol | Codex | high | 50 | subscription | |
| GPT-6.1 Sol | Codex | medium | 46 | subscription | |
| Claude Sonnet 5.5 | Claude | high | 41 | subscription | |
| `gemini-4-argon` | OpenCode Go | high | 50 | 440 | 1,080 |
| `kimi-k3.1-pro` | OpenCode Go | | 46 | 147 | 368 |
| `claude-haiku-5-5` | OpenCode Go | xhigh / high | 34 / 30 | 3,850 | 9,620 |
| `deepseek-v4.1-flash` | OpenCode Go | max / high | 32 / 29 | 43,330 | 108,330 |
| `minimax-m3.1-flash` | OpenCode Go | | 29 | 3,880 | 9,690 |
| `glm-5.3-flash` | OpenCode Go | | 28 | 6,320 | 15,790 |
| `mimo-v2.6-flash` | OpenCode Go | | 27 | 30,100 | 75,200 |
| `gpt-6-luna` | Codex or OpenCode Go | high | 21 | 4,230 (Go) | 10,560 (Go) |

`gpt-6-sol` has no current score. The free `deepseek` and `glm` models score as
their paid versions. Not used: `mimo-v2.6-pro`, `beam-free`, `longcat-2.0`,
`qwen3.8-flash`, `iceman-contributor-free`, `mimo-v2.6-flash-free`.

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
