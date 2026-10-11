#!/usr/bin/env bash
# Read-only repo checks; installer integration tests use temporary directories.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if [[ $# -gt 0 ]]; then
  case "$1" in
    -h|--help) echo "Usage: ./check.sh (validate bundle and test installer in temporary directories)"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
fi

command -v python3 >/dev/null 2>&1 || { echo "python3 is required" >&2; exit 1; }
bash -n "$REPO_DIR/install.sh" "$REPO_DIR/check.sh"
python3 -B "$REPO_DIR/scripts/validate.py"
python3 -B "$REPO_DIR/tests/test_install.py"
echo "All checks passed. These checks do not prove agent behavior or external CLI availability."
