#!/usr/bin/env bash
# Link this checkout into selected skill directories without replacing other work.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILL_SOURCE="$REPO_DIR/skills/dev-team"
COMMAND_SOURCE="$REPO_DIR/commands/dev-team.md"
dry_run=0
custom_dir=""
targets=()
destinations=()
sources=()

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--target HOST]... [--dry-run]
       ./install.sh --skills-dir DIRECTORY [--dry-run]

Hosts: codex, claude, gemini, opencode, all
With no target, install for hosts whose configuration directories already exist.
--target all explicitly selects all four hosts.
--skills-dir installs only the skill into a custom directory.
--dry-run prints planned links and checks conflicts without changing files.

Codex:    ${CODEX_HOME:-~/.codex}/skills/dev-team
Claude:   ~/.claude/skills/dev-team and ~/.claude/commands/dev-team.md
Gemini:   ~/.gemini/config/skills/dev-team (the reference repo's convention)
OpenCode: ${XDG_CONFIG_HOME:-~/.config}/opencode/skills/dev-team

Requires bash and python3. Existing unrelated files, directories, or links are
never replaced. Keep this checkout in place: installation uses symbolic links.
USAGE
}

die() { echo "Error: $*" >&2; exit 1; }

add_target() {
  local target="$1" existing
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
  destinations+=("$custom_dir/dev-team")
  sources+=("$SKILL_SOURCE")
else
  if [[ ${#targets[@]} -eq 0 ]]; then
    [[ ! -d "${CODEX_HOME:-$HOME/.codex}" ]] || add_target codex
    [[ ! -d "$HOME/.claude" ]] || add_target claude
    [[ ! -d "$HOME/.gemini" ]] || add_target gemini
    [[ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" ]] || add_target opencode
  fi
  [[ ${#targets[@]} -gt 0 ]] || die "No host configuration found; select --target or --skills-dir"
  for target in "${targets[@]}"; do
    case "$target" in
      codex) destination="${CODEX_HOME:-$HOME/.codex}/skills/dev-team" ;;
      claude) destination="$HOME/.claude/skills/dev-team" ;;
      gemini) destination="$HOME/.gemini/config/skills/dev-team" ;;
      opencode) destination="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/dev-team" ;;
    esac
    destinations+=("$destination")
    sources+=("$SKILL_SOURCE")
    if [[ "$target" == claude ]]; then
      destinations+=("$HOME/.claude/commands/dev-team.md")
      sources+=("$COMMAND_SOURCE")
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
  echo "Installed. Start a new host session to discover dev-team. No authentication or model settings changed."
fi
