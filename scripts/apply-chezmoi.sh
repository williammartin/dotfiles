#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

if ! command -v chezmoi >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: brew install chezmoi"
  else
    brew install chezmoi
  fi
fi

echo "Applying chezmoi source state..."
if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: chezmoi init --apply --source=$REPO_ROOT/chezmoi"
else
  chezmoi init --apply --source="$REPO_ROOT/chezmoi"
fi
