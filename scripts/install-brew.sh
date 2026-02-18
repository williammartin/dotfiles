#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

echo "Installing base Homebrew packages from Brewfile..."
if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: brew bundle --file=$REPO_ROOT/Brewfile"
else
  brew bundle --file="$REPO_ROOT/Brewfile"
fi
