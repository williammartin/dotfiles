#!/usr/bin/env bash
set -euo pipefail
DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

append_if_missing() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >>"$file"
  fi
}

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: would update ~/.zprofile and ~/.zshrc with shell init snippets"
  echo "DRY RUN: would set dock autohide default"
  exit 0
fi

append_if_missing 'eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"' "$HOME/.zprofile"
append_if_missing '[[ -d "$HOME/.nvm" ]] && export NVM_DIR="$HOME/.nvm" && [ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"' "$HOME/.zshrc"
append_if_missing 'command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"' "$HOME/.zshrc"

if command -v rustup >/dev/null 2>&1; then
  rustup default stable >/dev/null 2>&1 || true
fi

defaults write com.apple.dock autohide -bool true
killall Dock >/dev/null 2>&1 || true
