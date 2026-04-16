---
name: discord-voice-stt-enhance
description: External patch bundle plus local large-v3-turbo runtime for Hermes Discord voice STT/TTS hardening.
---

# discord-voice-stt-enhance

Use this repo when you want to keep Discord voice-channel STT/TTS improvements outside the main Hermes repository while still running a stronger local STT model on the same machine.

## Included runtime changes
- OpenAI TTS config-driven credential support in the Hermes patch
- Discord voice queue/worker hardening
- Discord voice-specific STT runtime profile
- Noise gating and low-confidence transcript filtering
- Local `faster-whisper` HTTP runtime for `large-v3-turbo`
- Thin `local_command` client for Hermes-to-local-runtime wiring
- Optional user `systemd` service installation helpers

## Install Hermes patch
Run:
```bash
scripts/install.sh /path/to/hermes-agent
```

## Set up the local STT runtime
Run:
```bash
runtime/setup.sh
runtime/launch.sh
```

## Configure Hermes
Run:
```bash
scripts/configure-hermes-local-stt.sh
```
Then copy the printed env and YAML snippet into `~/.hermes/.env` and `~/.hermes/config.yaml`.

## Optional persistent service
Run:
```bash
service/install-systemd.sh
```

## Verify
Run:
```bash
scripts/verify.sh /path/to/hermes-agent
```
