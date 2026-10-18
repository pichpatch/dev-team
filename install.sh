#!/usr/bin/env bash
# Link this checkout into selected skill directories without replacing other work.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_SOURCE="$REPO_DIR/skills"
COMMANDS_SOURCE="$REPO_DIR/commands"
AGENTS_SOURCE="$REPO_DIR/agents"
PROFILES_SOURCE="$REPO_DIR/profiles"
# The team skill, the role skills that act as commands where a host has no
# separate command files, and the command wrappers for hosts that do.
ROLE_SKILLS=(my-po my-design-lead my-tech-lead my-qa-lead my-security)
COMMANDS=(my-dev-team my-po my-design-lead my-tech-lead my-qa-lead my-security)
dry_run=0
custom_dir=""
targets=()
destinations=()
sources=()

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--target HOST]... [--dry-run]
       ./install.sh --skills-dir DIRECTORY [--dry-run]

Hosts: codex, claude, agy (also: antigravity, gemini), opencode, all
With no target, install for hosts whose configuration directories already exist.
--target all explicitly selects all four hosts.
--skills-dir installs the team skill and the role skills into a custom directory.
--dry-run prints planned links and checks conflicts without changing files.

Every host gets the my-dev-team skill and a way to call each role directly:
my-dev-team, my-po, my-design-lead, my-tech-lead, my-qa-lead, my-security.

Claude:      ~/.claude/skills/my-dev-team, and ~/.claude/commands/<name>.md
             (call as /my-po; each role command sets its model and effort)
OpenCode:    ${XDG_CONFIG_HOME:-~/.config}/opencode/skills/my-dev-team,
             .../opencode/commands/<name>.md (call as /my-po), and
             .../opencode/agents/<role>.md (each role is an agent with its
             model; switch agents with Tab)
Antigravity: ~/.gemini/config/skills/<name>; a skill is the slash command
             (call as /my-po)
Codex:       ${CODEX_HOME:-~/.codex}/skills/<name>; a skill is the command
             (call as $my-po), and ${CODEX_HOME:-~/.codex}/<role>.config.toml
             (start a session on a role's model with: codex -p my-tech-lead;
             organize with: codex -p my-dev-team)

The model each role runs on is listed in the skill's roster reference.

Requires bash and python3. Existing unrelated files, directories, or links are
never replaced. Keep this checkout in place: installation uses symbolic links.
USAGE
}

die() { echo "Error: $*" >&2; exit 1; }

add_target() {
  local target="$1" existing
  case "$target" in
    agy|antigravity) target=gemini ;;
  esac
  case "$target" in
    codex|claude|gemini|opencode) ;;
    *) die "Unknown host: $target" ;;
  esac
  for existing in "${targets[@]+"${targets[@]}"}"; do
    [[ "$existing" == "$target" ]] && return 0
  done
  targets+=("$target")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "--target needs a host"
      if [[ "$2" == all ]]; then
        for host in codex claude gemini opencode; do add_target "$host"; done
      else
        add_target "$2"
      fi
      shift 2
      ;;
    --skills-dir)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "--skills-dir needs a directory"
      [[ -z "$custom_dir" ]] || die "Specify --skills-dir only once"
      custom_dir="$2"
      shift 2
      ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1 (use --help)" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || die "python3 is required for validation"
python3 -B "$REPO_DIR/scripts/validate.py"

if [[ -n "$custom_dir" ]]; then
  [[ ${#targets[@]} -eq 0 ]] || die "Do not combine --skills-dir and --target"
  for skill in my-dev-team "${ROLE_SKILLS[@]}"; do
    destinations+=("$custom_dir/$skill")
    sources+=("$SKILLS_SOURCE/$skill")
  done
else
  if [[ ${#targets[@]} -eq 0 ]]; then
    [[ ! -d "${CODEX_HOME:-$HOME/.codex}" ]] || add_target codex
    [[ ! -d "$HOME/.claude" ]] || add_target claude
    [[ ! -d "$HOME/.gemini" ]] || add_target gemini
    [[ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" ]] || add_target opencode
  fi
  [[ ${#targets[@]} -gt 0 ]] || die "No host configuration found; select --target or --skills-dir"
  for target in "${targets[@]}"; do
    # commands_dir is set for hosts with command files; the others call a
    # skill by name, so they get the role skills instead.
    commands_dir=""
    case "$target" in
      codex) skills_dir="${CODEX_HOME:-$HOME/.codex}/skills" ;;
      claude) skills_dir="$HOME/.claude/skills"; commands_dir="$HOME/.claude/commands" ;;
      gemini) skills_dir="$HOME/.gemini/config/skills" ;;
      opencode)
        skills_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"
        commands_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands"
        ;;
    esac
    destinations+=("$skills_dir/my-dev-team")
    sources+=("$SKILLS_SOURCE/my-dev-team")
    # Each host binds a role to its model in its own way: Claude in the command,
    # OpenCode in an agent the command names, Codex in a profile.
    if [[ "$target" == opencode ]]; then
      for role in "${ROLE_SKILLS[@]}"; do
        destinations+=("${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents/$role.md")
        sources+=("$AGENTS_SOURCE/opencode/$role.md")
      done
    elif [[ "$target" == codex ]]; then
      for role in my-dev-team "${ROLE_SKILLS[@]}"; do
        destinations+=("${CODEX_HOME:-$HOME/.codex}/$role.config.toml")
        sources+=("$PROFILES_SOURCE/codex/$role.config.toml")
      done
    fi
    if [[ -n "$commands_dir" ]]; then
      for command in "${COMMANDS[@]}"; do
        destinations+=("$commands_dir/$command.md")
        sources+=("$COMMANDS_SOURCE/$target/$command.md")
      done
    else
      for skill in "${ROLE_SKILLS[@]}"; do
        destinations+=("$skills_dir/$skill")
        sources+=("$SKILLS_SOURCE/$skill")
      done
    fi
  done
fi

# Preflight every destination before creating any link. Python performs exact
# canonical path checks, including symlinks and spaces, without shell evaluation.
preflight_args=()
for ((i=0; i<${#destinations[@]}; i++)); do
  preflight_args+=("${sources[$i]}" "${destinations[$i]}")
done
python3 -B - "${preflight_args[@]}" <<'PY'
import os
import sys
from pathlib import Path

errors = []
for source, destination in zip(sys.argv[1::2], sys.argv[2::2]):
    src, dst = Path(source), Path(destination)
    if os.path.lexists(dst):
        if not (dst.is_symlink() and dst.resolve() == src.resolve()):
            errors.append(f"Refusing to replace existing destination: {dst}")
    else:
        parent = dst.parent
        while not os.path.lexists(parent) and parent != parent.parent:
            parent = parent.parent
        if not parent.is_dir():
            errors.append(f"Destination parent is not a directory: {parent}")
for error in errors:
    print(f"Error: {error}", file=sys.stderr)
sys.exit(bool(errors))
PY

for ((i=0; i<${#destinations[@]}; i++)); do
  destination="${destinations[$i]}"
  source="${sources[$i]}"
  if [[ -L "$destination" ]]; then
    echo "Already linked: $destination"
  elif [[ "$dry_run" -eq 1 ]]; then
    echo "Would link: $destination -> $source"
  else
    mkdir -p "$(dirname "$destination")"
    # Never use force: if a destination appeared after preflight, leave it alone.
    # Python also refuses an existing directory instead of placing a link inside it.
    python3 -B - "$source" "$destination" <<'PY'
import os
import sys
os.symlink(sys.argv[1], sys.argv[2])
PY
    echo "Linked: $destination -> $source"
  fi
done

if [[ "$dry_run" -eq 1 ]]; then
  echo "Dry run complete; nothing installed."
else
  echo "Installed. Start a new host session to discover my-dev-team. No authentication or model settings changed."
fi
