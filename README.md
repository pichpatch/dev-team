# Dev Team

A model-independent skill for software delivery through real sub-agents or
already-authorized CLIs. Organizer is the executing host (OpenCode, Claude Code,
Codex, etc.), **not a role**. It coordinates work while the ten roles retain their
domain authority and the human retains final authority. You talk directly to
four roles in one session: PO, Design Lead, Technical Lead, and QA Lead. The host
acts as each in turn, tells you which is speaking, and switches when you ask or
call `/po`, `/design-lead`, `/tech-lead`, or `/qa-lead`. The other roles are
always delegated, and each Lead reviews its own team's work.

Each role guide covers its working method, inputs, evidence, review, handoffs,
and authority boundaries.

## Package

- [Skill entrypoint](skills/dev-team/SKILL.md): role routing and supporting references.
- [Shared contract](skills/dev-team/references/contract.md): authority and access rules.
- [Feature workflow](skills/dev-team/references/orchestration.md): agreement through finished PR.
- [Delegation](skills/dev-team/references/delegation.md): stateless assignments and Lead review.
- [Persistent records](skills/dev-team/references/records.md): repo truth as HTML
  documents indexed by `README.md` files, and feature Issues.
- [Pause/resume](skills/dev-team/references/checkpoints.md): unfinished `.AI` state only.
- [Project defaults](skills/dev-team/references/project-defaults.md): the human's
  standard choices for a new project; an existing project keeps its own.
- [Standard stack](skills/dev-team/references/stack.md): the applications,
  repository layout, typed API contract, and identifiers for a new project.
- [Engineering](skills/dev-team/references/engineering.md),
  [design](skills/dev-team/references/design.md), and
  [quality](skills/dev-team/references/quality.md): detailed practices loaded as needed.

One installable `dev-team` skill contains ten role guides: PO, Technical Lead,
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

| Host | Destination |
| --- | --- |
| Codex | `${CODEX_HOME:-~/.codex}/skills/dev-team` |
| Claude Code | `~/.claude/skills/dev-team` plus `~/.claude/commands/` `dev-team.md`, `po.md`, `design-lead.md`, `tech-lead.md`, and `qa-lead.md` |
| Gemini / Antigravity | `~/.gemini/config/skills/dev-team`, matching the reference repo |
| OpenCode | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/dev-team` |

Installation creates symlinks, so keep this checkout in place. Re-running is safe;
existing unrelated files/directories/links cause a clear failure before links are
created. The installer does not remove other skills, configure models, install
CLIs, log in, or alter host permissions. Host discovery behavior and delegation
support must be verified in the target host; a successful link is not a live CLI test.
Use `--skills-dir` when the host's configured discovery directory differs.

## Use

Invoke `dev-team` in the host's supported skill syntax (the supplied Claude command
is `/dev-team`) with the feature goal or owning Issue. Call `/po`, `/design-lead`,
`/tech-lead`, or `/qa-lead` to talk to that role directly, or just ask for it in
the conversation; on other hosts, ask the skill to act as that role. Organizer
loads only relevant
role guides and sends a complete task packet to each actual agent/CLI. If no real
delegation tool is available, it reports the limitation instead of claiming that a
review occurred.

The intended flow is: you agree the feature with PO and whichever of Design
Lead, Technical Lead, and QA Lead it needs, in one conversation → PO pushes the
agreed documents and creates the feature Issue, `ready to implement` or `draft`
→ relevant Design, Technical, QA, and Cybersecurity preparation → final technical
package → Senior implementation → Lead approval → QA execution and final AC
verification → Cybersecurity delivery checks (secret files, AI crawler rules) →
finished PR for you. Trivial corrections are made by Organizer directly, and
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
env file. The team works on GitHub only.

## Check

`./check.sh` checks shell syntax, skill identity, all ten role guides, local resource
links, resource reachability, the HTML project-doc rule, and installer behavior in
isolated temporary homes.
Tests cover reruns, host selection, environment paths, dry runs, collisions,
literal path handling, and preservation of existing content. They do not run agents,
contact GitHub, or prove model compliance. No Python packages are required.

This is a standalone bundle with no installation or runtime dependency on any
other skill. Roles are not bound to models, and there is no provider-specific
gate.
