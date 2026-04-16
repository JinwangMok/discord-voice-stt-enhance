#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PATCH_PATH="$REPO_DIR/patches/hermes-discord-voice-stt-enhance.patch"
HERMES_DIR="${1:-/home/jinwang/.hermes/hermes-agent}"

if [[ ! -d "$HERMES_DIR/.git" ]]; then
  echo "Hermes git repo not found: $HERMES_DIR" >&2
  exit 1
fi

if git -C "$HERMES_DIR" apply --reverse --check "$PATCH_PATH" >/dev/null 2>&1; then
  echo "Patch already applied: $PATCH_PATH"
  exit 0
fi

git -C "$HERMES_DIR" apply --check "$PATCH_PATH"
git -C "$HERMES_DIR" apply "$PATCH_PATH"
echo "Applied patch: $PATCH_PATH"
