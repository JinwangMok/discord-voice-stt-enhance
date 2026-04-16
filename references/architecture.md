# Architecture

## Goal
Package Discord voice-channel quality improvements as an external workspace repo so the upstream Hermes checkout stays clean while the same repo also owns the stronger local STT runtime used by Discord voice.

## Scope of the Hermes patch
The patch updates only these Hermes files:
- `tools/tts_tool.py`
- `tools/transcription_tools.py`
- `gateway/platforms/discord.py`
- `tests/tools/test_managed_media_gateways.py`
- `tests/tools/test_transcription_tools.py`
- `tests/gateway/test_voice_command.py`

## Repo-owned runtime additions
This repo now also owns the local STT runtime pieces:
- `runtime/server.py` — local OpenAI-compatible transcription endpoint backed by `faster-whisper`
- `runtime/client.py` — Hermes `local_command` thin client that POSTs audio to the local server and writes a `.txt` result
- `runtime/setup.sh` — creates a uv-managed local env and installs runtime deps
- `runtime/launch.sh` — runs the hot local STT server on Linux
- `runtime/healthcheck.sh` — checks `/health`
- `runtime/launch-windows.bat` — launches the Windows STT server in the background and records stdout/stderr logs plus a PID file under `runtime\logs\`
- `runtime/stop-windows.bat` — stops the background Windows STT server using the saved PID file
- `service/install-systemd.sh` — optional user-service installation

## Functional changes
1. **TTS config fix**
   - OpenAI TTS now honors `tts.openai.api_key` and `tts.openai.base_url` from config.
2. **Voice pipeline hardening**
   - per-guild FIFO processing queue
   - teardown-safe session generation token
   - bounded queue to avoid unbounded backlog
3. **STT routing simplification**
   - Hermes can now be configured to use `provider: local_command` globally, not only for `discord_voice`.
   - `tools/transcription_tools.py` accepts `stt.local_command.command` from config before falling back to `HERMES_LOCAL_STT_COMMAND`.
4. **Discord voice STT profile**
   - `transcribe_audio(..., profile="discord_voice")`
   - quality-first provider ordering for live voice
   - can still be configured to use `provider: local_command` for Discord voice only
5. **Noise admission filtering**
   - PCM energy/peak/voiced-ratio screening before STT
   - punctuation-only transcript rejection after STT
6. **Local stronger-model runtime**
   - intended default model: `large-v3-turbo`
   - model stays hot in a local HTTP service for lower latency than one-shot CLI loads
   - Hermes remains only a caller, not the runtime owner

## Why this repo exists
The user prefers modular repo boundaries and does not want the Hermes repo to become the long-term home of custom Discord voice logic or local model ops. This repo packages the diff, scripts, docs, and optional service setup needed to reapply the feature cleanly while keeping runtime ownership outside Hermes.
