#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/williammartin/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REF="${DOTFILES_REF:-}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer currently supports macOS only." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools (includes git)..."
  xcode-select --install || true
  until command -v git >/dev/null 2>&1; do
    echo "Waiting for git to become available..."
    sleep 10
  done
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  git -C "$DOTFILES_DIR" fetch --all --prune
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [[ -n "$DOTFILES_REF" ]]; then
  git -C "$DOTFILES_DIR" checkout "$DOTFILES_REF"
fi

exec "$DOTFILES_DIR/bootstrap.sh"
