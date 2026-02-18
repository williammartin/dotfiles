#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${BOOTSTRAP_DRY_RUN:-0}"

read_value() {
  local prompt="$1"
  local default="${2:-}"
  local value
  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " value
    echo "${value:-$default}"
    return
  fi
  read -r -p "$prompt: " value
  echo "$value"
}

git_name="$(git config --global user.name || true)"
git_email="$(git config --global user.email || true)"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: would ensure git identity is configured"
  if command -v gh >/dev/null 2>&1; then
    echo "DRY RUN: would optionally set GitHub token in Keychain if gh is unauthenticated"
  fi
  exit 0
fi

if [[ -z "$git_name" ]]; then
  git_name="$(read_value "Git user.name")"
  if [[ -n "$git_name" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "DRY RUN: git config --global user.name \"$git_name\""
    else
      git config --global user.name "$git_name"
    fi
  fi
fi

if [[ -z "$git_email" ]]; then
  git_email="$(read_value "Git user.email")"
  if [[ -n "$git_email" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "DRY RUN: git config --global user.email \"$git_email\""
    else
      git config --global user.email "$git_email"
    fi
  fi
fi

if command -v gh >/dev/null 2>&1; then
  if ! gh auth status >/dev/null 2>&1; then
    token="$(read_value "Optional GitHub token (leave empty to skip)")"
    if [[ -n "$token" ]]; then
      if [[ "$DRY_RUN" == "1" ]]; then
        echo "DRY RUN: store GitHub token in Keychain and authenticate gh"
      else
        security add-generic-password -U -a "$USER" -s "bootstrap/github-token" -w "$token" >/dev/null
        gh auth login --hostname github.com --with-token <<<"$token"
      fi
      unset token
    fi
  fi
fi
