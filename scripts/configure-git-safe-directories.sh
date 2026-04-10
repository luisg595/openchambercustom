#!/bin/sh
set -eu

workspace_root="${1:-/workspace}"

if [ ! -d "$workspace_root" ]; then
  exit 0
fi

add_safe_directory() {
  repo="$1"
  git config --global --get-all safe.directory | grep -Fx "$repo" >/dev/null 2>&1 || \
    git config --global --add safe.directory "$repo"
}

if git -C "$workspace_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  add_safe_directory "$(git -C "$workspace_root" rev-parse --show-toplevel)"
fi

for repo in "$workspace_root"/*; do
  if git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    add_safe_directory "$(git -C "$repo" rev-parse --show-toplevel)"
  fi
done
