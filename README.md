# Dev Team

A model-independent skill for software delivery through real sub-agents or
already-authorized CLIs. Organizer is the executing host (OpenCode, Claude Code,
Codex, etc.), **not a role**. It coordinates work while the ten roles retain their
domain authority and the human retains final authority. The host carries out one
role itself: it tells you it is now acting as PO, agrees the requirement with you
in conversation, and returns to organizing. The other nine roles are delegated.

This draft combines the agreed team structure with role methods adapted from
`ai-skills` and general delivery practices. The latest user specification takes
precedence over conflicting old conventions. Each role guide now covers its
working method, inputs, evidence, review, handoffs, and authority boundaries.
See [draft sources and adaptations](docs/draft-notes.md) for what was retained,
changed, or treated as a configurable default.

## Package

- [Skill entrypoint](skills/dev-team/SKILL.md): role routing and supporting references.
- [Shared contract](skills/dev-team/references/contract.md): authority and access rules.
- [Feature workflow](skills/dev-team/references/orchestration.md): agreement through finished PR.
- [Delegation](skills/dev-team/references/delegation.md): stateless assignments and Lead review.
- [Persistent records](skills/dev-team/references/records.md): repo truth as HTML
  documents indexed by `README.md` files, and feature Issues.
- [Pause/resume](skills/dev-team/references/checkpoints.md): unfinished `.AI` state only.
- [Project defaults](skills/dev-team/references/project-defaults.md): inherited
  starting preferences, subordinate to the project and owner decisions.
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
| Claude Code | `~/.claude/skills/dev-team` plus `~/.claude/commands/dev-team.md` |
| Gemini / Antigravity | `~/.gemini/config/skills/dev-team`, matching the reference repo |
| OpenCode | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/dev-team` |

Installation creates symlinks, so keep this checkout in place. Re-running is safe;
existing unrelated files/directories/links cause a clear failure before links are
created. The installer does not replace old `my-*` skills, configure models, install
CLIs, log in, or alter host permissions. Host discovery behavior and delegation
support must be verified in the target host; a successful link is not a live CLI test.
Use `--skills-dir` when the host's configured discovery directory differs.

## Use

Invoke `dev-team` in the host's supported skill syntax (the supplied Claude command
is `/dev-team`) with the feature goal or owning Issue. Organizer loads only relevant
role guides and sends a complete task packet to each actual agent/CLI. If no real
delegation tool is available, it reports the limitation instead of claiming that a
review occurred.

The intended flow is human + PO agreement → PO creates the feature Issue → relevant
Design, Technical, QA, and Cybersecurity preparation → final technical package →
Senior implementation → Lead approval → QA execution and final AC verification →
Cybersecurity delivery checks (secret files, AI crawler rules) → finished PR for
the human. Trivial corrections
are made by Organizer directly, and small changes take a shorter owner route. Lead approval completes its scope; downstream QA remains.

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

This is a standalone bundle: `ai-skills` is a drafting source, not an installation
or runtime dependency. Its old model bindings, local progress tracker, and
provider-specific gates are not part of this team's contract.
