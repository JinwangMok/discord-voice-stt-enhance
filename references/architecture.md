# Architecture

## Goal
Package Discord voice-channel quality improvements as an external workspace repo so the upstream Hermes checkout stays clean and the feature can be reapplied with a small patch bundle.

## Scope of the Hermes patch
The patch updates only these Hermes files:
- `tools/tts_tool.py`
- `tools/transcription_tools.py`
- `gateway/platforms/discord.py`
- `tests/tools/test_managed_media_gateways.py`
- `tests/tools/test_transcription_tools.py`
- `tests/gateway/test_voice_command.py`

## Functional changes
1. **TTS config fix**
   - OpenAI TTS now honors `tts.openai.api_key` and `tts.openai.base_url` from config.
2. **Voice pipeline hardening**
   - per-guild FIFO processing queue
   - teardown-safe session generation token
   - bounded queue to avoid unbounded backlog
3. **Discord voice STT profile**
   - `transcribe_audio(..., profile="discord_voice")`
   - quality-first provider ordering for live voice
4. **Noise admission filtering**
   - PCM energy/peak/voiced-ratio screening before STT
   - punctuation-only transcript rejection after STT

## Why this repo exists
The user prefers modular repo boundaries and does not want the Hermes repo to become the long-term home of custom Discord voice logic. This repo packages the diff, scripts, and documentation needed to reapply the feature cleanly.
