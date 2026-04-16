# discord-voice-stt-enhance

Patch bundle for Hermes Discord voice-channel improvements, packaged outside the main `hermes-agent` repo.

## What this bundle contains
- OpenAI TTS config fix for `tts.openai.api_key` / `tts.openai.base_url`
- Discord voice pipeline hardening with per-guild FIFO workers and session tokens
- Discord voice STT quality-first runtime profile (`discord_voice`)
- Front-end audio/noise filtering and low-confidence transcript rejection
- Regression tests for the above behavior

## Repo layout
- `patches/hermes-discord-voice-stt-enhance.patch` — patch to apply inside Hermes
- `scripts/apply-hermes-patch.sh` — idempotent patch application
- `scripts/install.sh` — convenience wrapper
- `scripts/verify.sh` — validates patch state and runs focused tests
- `references/architecture.md` — design notes and scope

## Install
```bash
~/workspace/discord-voice-stt-enhance/scripts/install.sh /home/jinwang/.hermes/hermes-agent
```

If no argument is given, the script defaults to `/home/jinwang/.hermes/hermes-agent`.

## Verify
```bash
~/workspace/discord-voice-stt-enhance/scripts/verify.sh /home/jinwang/.hermes/hermes-agent
```

## Notes
This repo keeps the feature outside the upstream Hermes repository. Hermes itself only receives the patch from this bundle.
