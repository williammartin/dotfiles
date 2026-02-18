#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 validate <issue-number>" >&2
  exit 1
}

[[ $# -eq 2 ]] || usage
[[ "$1" == "validate" ]] || usage

number="$2"
[[ "$number" =~ ^[0-9]+$ ]] || usage

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
prompt="please use gh to fetch issue number $number, explore the code, determine whether there is a real issue and why, and propose a fix. Don't make any changes"

"$script_dir/worktree.sh" issue "$number" --prompt "$prompt"
