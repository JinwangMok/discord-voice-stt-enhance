#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HERMES_DIR="${HERMES_DIR:-$HOME/.hermes/hermes-agent}"
BASE_PATCH_OUT="$REPO_DIR/patches/hermes-discord-voice-stt-enhance.patch"
CONFIG_PATCH_OUT="$REPO_DIR/patches/hermes-config-first-global-stt.patch"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hermes-dir)
      HERMES_DIR="$2"
      shift 2
      ;;
    --base-output)
      BASE_PATCH_OUT="$2"
      shift 2
      ;;
    --config-output)
      CONFIG_PATCH_OUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$(dirname "$BASE_PATCH_OUT")" "$(dirname "$CONFIG_PATCH_OUT")"

HELPER_BASE_PATCH="$TMPDIR/helper-base.patch"
HELPER_CONFIG_PATCH="$TMPDIR/helper-config.patch"
git -C "$REPO_DIR" show HEAD:patches/hermes-discord-voice-stt-enhance.patch > "$HELPER_BASE_PATCH"
git -C "$REPO_DIR" show HEAD:patches/hermes-config-first-global-stt.patch > "$HELPER_CONFIG_PATCH"

resolve_discord_conflict() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding='utf-8')
needle = '''<<<<<<< ours
    def _is_allowed_user(self, user_id: str, author=None) -> bool:
        """Check if user is allowed via DISCORD_ALLOWED_USERS or DISCORD_ALLOWED_ROLES.

        Uses OR semantics: if the user matches EITHER allowlist, they're allowed.
        If both allowlists are empty, everyone is allowed (backwards compatible).
        When author is a Member, checks .roles directly; otherwise falls back
        to scanning the bot's mutual guilds for a Member record.
        """
        # ``getattr`` fallbacks here guard against test fixtures that build
        # an adapter via ``object.__new__(DiscordAdapter)`` and skip __init__
        # (see AGENTS.md pitfall #17 — same pattern as gateway.run).
        allowed_users = getattr(self, "_allowed_user_ids", set())
        allowed_roles = getattr(self, "_allowed_role_ids", set())
        has_users = bool(allowed_users)
        has_roles = bool(allowed_roles)
        if not has_users and not has_roles:
=======
    def _is_low_confidence_voice_transcript(self, transcript: str) -> bool:
        """Reject obviously non-speech transcripts before they reach the agent."""
        normalized = re.sub(r"[\\W_]+", "", transcript, flags=re.UNICODE)
        return not normalized

    def _is_allowed_user(self, user_id: str) -> bool:
        """Check if user is in DISCORD_ALLOWED_USERS."""
        if not self._allowed_user_ids:
>>>>>>> theirs
            return True'''
replacement = '''    def _is_low_confidence_voice_transcript(self, transcript: str) -> bool:
        """Reject obviously non-speech transcripts before they reach the agent."""
        normalized = re.sub(r"[\\W_]+", "", transcript, flags=re.UNICODE)
        return not normalized

    def _is_allowed_user(self, user_id: str, author=None) -> bool:
        """Check if user is allowed via DISCORD_ALLOWED_USERS or DISCORD_ALLOWED_ROLES.

        Uses OR semantics: if the user matches EITHER allowlist, they're allowed.
        If both allowlists are empty, everyone is allowed (backwards compatible).
        When author is a Member, checks .roles directly; otherwise falls back
        to scanning the bot's mutual guilds for a Member record.
        """
        # ``getattr`` fallbacks here guard against test fixtures that build
        # an adapter via ``object.__new__(DiscordAdapter)`` and skip __init__
        # (see AGENTS.md pitfall #17 — same pattern as gateway.run).
        allowed_users = getattr(self, "_allowed_user_ids", set())
        allowed_roles = getattr(self, "_allowed_role_ids", set())
        has_users = bool(allowed_users)
        has_roles = bool(allowed_roles)
        if not has_users and not has_roles:
            return True'''
if needle not in text:
    raise SystemExit(f'Expected discord.py conflict block not found in {path}')
path.write_text(text.replace(needle, replacement), encoding='utf-8')
PY
}

apply_base_subset() {
  local repo_dir="$1"
  set +e
  git -C "$repo_dir" apply --3way \
    --include=gateway/platforms/discord.py \
    --include=tests/gateway/test_voice_command.py \
    --include=tools/transcription_tools.py \
    --include=tests/tools/test_transcription_tools.py \
    "$HELPER_BASE_PATCH"
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    resolve_discord_conflict "$repo_dir/gateway/platforms/discord.py"
    git -C "$repo_dir" add gateway/platforms/discord.py
  fi
}

# --- Build refreshed base patch ---
git clone --quiet "$HERMES_DIR" "$TMPDIR/base"
git -C "$TMPDIR/base" checkout --quiet origin/main
apply_base_subset "$TMPDIR/base"

git -C "$TMPDIR/base" diff --binary origin/main -- \
  gateway/platforms/discord.py \
  tests/gateway/test_voice_command.py \
  tools/transcription_tools.py \
  tests/tools/test_transcription_tools.py > "$BASE_PATCH_OUT"

# --- Build refreshed incremental config-first patch relative to refreshed base ---
git clone --quiet "$HERMES_DIR" "$TMPDIR/config"
git -C "$TMPDIR/config" checkout --quiet origin/main
apply_base_subset "$TMPDIR/config"
git -C "$TMPDIR/config" add \
  gateway/platforms/discord.py \
  tests/gateway/test_voice_command.py \
  tools/transcription_tools.py \
  tests/tools/test_transcription_tools.py
git -C "$TMPDIR/config" -c user.name='Hermes Export' -c user.email='hermes-export@example.invalid' commit -qm 'temp base snapshot'
git -C "$TMPDIR/config" apply --3way "$HELPER_CONFIG_PATCH"

git -C "$TMPDIR/config" diff --binary HEAD -- \
  tools/transcription_tools.py \
  tests/tools/test_transcription_tools.py > "$CONFIG_PATCH_OUT"

echo "Wrote: $BASE_PATCH_OUT"
echo "Wrote: $CONFIG_PATCH_OUT"
