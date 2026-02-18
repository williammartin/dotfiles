#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${HOME}/workspace/github/gh"
TARGET_DIR="${REPO_ROOT}/chezmoi/private_dot_local/private_bin"
DRY_RUN=0

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

for name in fr.sh worktree.sh; do
  source_file="${SOURCE_DIR}/${name}"
  target_file="${TARGET_DIR}/executable_${name}"

  if [[ ! -f "$source_file" ]]; then
    echo "Missing source file: $source_file" >&2
    exit 1
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: cp \"$source_file\" \"$target_file\""
    continue
  fi

  mkdir -p "$TARGET_DIR"
  cp "$source_file" "$target_file"
  chmod +x "$target_file"
done

if [[ "$DRY_RUN" != "1" ]]; then
  echo "Synced gh helper scripts to $TARGET_DIR"
fi
