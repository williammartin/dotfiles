#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

failures=0

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing command: $cmd"
    failures=$((failures + 1))
  fi
}

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: would verify required commands and configured git identity"
  echo "verification passed"
  exit 0
fi

require_cmd brew
require_cmd git
require_cmd gh
require_cmd chezmoi
require_cmd rg

if [[ ! -f "$REPO_ROOT/Brewfile" ]]; then
  echo "missing Brewfile"
  failures=$((failures + 1))
fi

if ! git config --global user.name >/dev/null; then
  echo "git user.name not configured"
  failures=$((failures + 1))
fi

if ! git config --global user.email >/dev/null; then
  echo "git user.email not configured"
  failures=$((failures + 1))
fi

if [[ "$failures" -gt 0 ]]; then
  echo "verification failed ($failures issues)"
  exit 1
fi

echo "verification passed"
