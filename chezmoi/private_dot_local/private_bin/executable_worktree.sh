#!/usr/bin/env bash
set -euo pipefail

SOURCE_REPO="$HOME/workspace/github/gh/cli"
WORKTREE_BASE="$HOME/workspace/github/gh"

usage() {
  echo "Usage: $(basename "$0") <new|pr|issue> <target> [--prompt <text>]"
  echo
  echo "Uses 'wt' to create a worktree from $SOURCE_REPO for <target>,"
  echo "then opens a new tmux pane in that directory running 'copilot --yolo'."
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

COMMAND="$1"
TARGET="$2"
shift 2
BRANCH=""
WORKTREE_NAME=""
COPILOT_PROMPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)
      [[ $# -ge 2 ]] || usage
      COPILOT_PROMPT="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

mkdir -p "$WORKTREE_BASE"
case "$COMMAND" in
  new)
    BRANCH="$TARGET"
    WORKTREE_NAME="${BRANCH//\//-}"
    WORKTREE_DIR="$WORKTREE_BASE/$WORKTREE_NAME"
    (cd "$SOURCE_REPO" && wt new "$BRANCH" --checkout -e none -p "$WORKTREE_DIR")
    ;;
  pr)
    WORKTREE_NAME="pr-${TARGET//\//-}"
    WORKTREE_DIR="$WORKTREE_BASE/$WORKTREE_NAME"
    (cd "$SOURCE_REPO" && wt pr "$TARGET" -e none -p "$WORKTREE_DIR")
    BRANCH="$(cd "$WORKTREE_DIR" && git branch --show-current)"
    ;;
  issue)
    BRANCH="$(cd "$SOURCE_REPO" && gh issue develop --list "$TARGET" | head -n 1 | cut -f 1)"
    if [[ -z "$BRANCH" ]]; then
      (cd "$SOURCE_REPO" && gh issue develop "$TARGET")
      BRANCH="$(cd "$SOURCE_REPO" && gh issue develop --list "$TARGET" | head -n 1 | cut -f 1)"
    fi
    if [[ -z "$BRANCH" ]]; then
      echo "Failed to determine branch for issue $TARGET."
      exit 1
    fi
    WORKTREE_NAME="${BRANCH//\//-}"
    WORKTREE_DIR="$WORKTREE_BASE/$WORKTREE_NAME"
    if [[ "$(cd "$SOURCE_REPO" && git branch --show-current)" == "$BRANCH" ]]; then
      DEFAULT_BRANCH="$(cd "$SOURCE_REPO" && git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)"
      if [[ -z "$DEFAULT_BRANCH" ]]; then
        echo "Could not determine default branch to free '$BRANCH' from $SOURCE_REPO."
        exit 1
      fi
      (cd "$SOURCE_REPO" && git checkout "$DEFAULT_BRANCH")
    fi
    EXISTING_WORKTREE="$(cd "$SOURCE_REPO" && git worktree list --porcelain | awk -v branch="refs/heads/$BRANCH" 'BEGIN { path="" } /^worktree / { path=$2 } /^branch / { if ($2 == branch) { print path; exit } }')"
    if [[ -n "$EXISTING_WORKTREE" ]]; then
      WORKTREE_DIR="$EXISTING_WORKTREE"
    else
      (cd "$SOURCE_REPO" && wt new "$BRANCH" --checkout -e none -p "$WORKTREE_DIR")
    fi
    ;;
  *)
    usage
    ;;
esac

if [[ -n "${TMUX:-}" ]]; then
  copilot_cmd=(copilot --yolo)
  if [[ -n "$COPILOT_PROMPT" ]]; then
    copilot_cmd+=(-i "$COPILOT_PROMPT")
  fi
  copilot_cmd_str="$(printf '%q ' "${copilot_cmd[@]}")"
  tmux new-window -n "${BRANCH:-$WORKTREE_NAME}" -c "$WORKTREE_DIR" "${copilot_cmd_str% }"
else
  echo "Not inside a tmux session. Worktree created at: $WORKTREE_DIR"
fi
