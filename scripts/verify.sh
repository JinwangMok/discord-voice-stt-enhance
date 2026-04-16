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
  echo "Patch state: applied"
else
  echo "Patch state: not applied"
  git -C "$HERMES_DIR" apply --check "$PATCH_PATH"
  echo "Patch can be applied cleanly"
fi

cd "$HERMES_DIR"
source venv/bin/activate
python -m pytest   tests/tools/test_managed_media_gateways.py -q   tests/tools/test_transcription_tools.py -q   tests/gateway/test_voice_command.py -q   tests/gateway/test_discord_opus.py -q   tests/gateway/test_stt_config.py -q   tests/integration/test_voice_channel_flow.py -q
