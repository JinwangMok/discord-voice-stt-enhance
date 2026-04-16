#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HERMES_DIR="${1:-/home/jinwang/.hermes/hermes-agent}"

if [[ ! -d "$HERMES_DIR/.git" ]]; then
  echo "Hermes git repo not found: $HERMES_DIR" >&2
  exit 1
fi

mapfile -t PATCHES < <(find "$REPO_DIR/patches" -maxdepth 1 -type f -name '*.patch' | sort)
if [[ ${#PATCHES[@]} -eq 0 ]]; then
  echo "No patch files found under $REPO_DIR/patches" >&2
  exit 1
fi

ORDERED_PATCHES=()
BASE_PATCH="$REPO_DIR/patches/hermes-discord-voice-stt-enhance.patch"
if [[ -f "$BASE_PATCH" ]]; then
  ORDERED_PATCHES+=("$BASE_PATCH")
fi
for PATCH_PATH in "${PATCHES[@]}"; do
  if [[ "$PATCH_PATH" == "$BASE_PATCH" ]]; then
    continue
  fi
  ORDERED_PATCHES+=("$PATCH_PATH")
done

for PATCH_PATH in "${ORDERED_PATCHES[@]}"; do
  if git -C "$HERMES_DIR" apply --reverse --check "$PATCH_PATH" >/dev/null 2>&1; then
    echo "Patch already applied: $PATCH_PATH"
    continue
  fi

  git -C "$HERMES_DIR" apply --check "$PATCH_PATH"
  git -C "$HERMES_DIR" apply "$PATCH_PATH"
  echo "Applied patch: $PATCH_PATH"
done
