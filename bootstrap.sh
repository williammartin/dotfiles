#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap currently supports macOS only." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: would install Xcode Command Line Tools"
  else
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do
    echo "Waiting for Xcode Command Line Tools installation to complete..."
    sleep 10
  done
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: would install Homebrew"
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

BOOTSTRAP_DRY_RUN="$DRY_RUN" "$REPO_ROOT/scripts/install-brew.sh"
BOOTSTRAP_DRY_RUN="$DRY_RUN" "$REPO_ROOT/scripts/apply-chezmoi.sh"
BOOTSTRAP_DRY_RUN="$DRY_RUN" "$REPO_ROOT/scripts/setup-identity-and-secrets.sh"
BOOTSTRAP_DRY_RUN="$DRY_RUN" "$REPO_ROOT/scripts/post-setup.sh"
BOOTSTRAP_DRY_RUN="$DRY_RUN" "$REPO_ROOT/scripts/verify-setup.sh"

echo "Bootstrap completed successfully."
