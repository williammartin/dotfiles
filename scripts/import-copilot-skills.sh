#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${HOME}/.copilot/skills"
TARGET_DIR="${REPO_ROOT}/chezmoi/private_dot_copilot/private_skills"
DRY_RUN=0
DELETE_EXTRANEOUS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --delete)
      DELETE_EXTRANEOUS=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "No skills found at $SOURCE_DIR"
  exit 0
fi

mkdir -p "$TARGET_DIR"

if [[ "$DRY_RUN" == "1" ]]; then
  if [[ "$DELETE_EXTRANEOUS" == "1" ]]; then
    echo "DRY RUN: rsync -a --delete \"$SOURCE_DIR/\" \"$TARGET_DIR/\""
  else
    echo "DRY RUN: rsync -a \"$SOURCE_DIR/\" \"$TARGET_DIR/\""
  fi
  exit 0
fi

if [[ "$DELETE_EXTRANEOUS" == "1" ]]; then
  rsync -a --delete "$SOURCE_DIR/" "$TARGET_DIR/"
else
  rsync -a "$SOURCE_DIR/" "$TARGET_DIR/"
fi
echo "Synced Copilot skills to $TARGET_DIR"
