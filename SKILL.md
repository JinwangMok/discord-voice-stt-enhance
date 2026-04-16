---
name: discord-voice-stt-enhance
description: External patch bundle for Hermes Discord voice STT/TTS hardening and live voice filtering.
---

# discord-voice-stt-enhance

Use this repo when you want to keep Discord voice-channel STT/TTS improvements outside the main Hermes repository.

## Included runtime changes
- OpenAI TTS config-driven credential support
- Discord voice queue/worker hardening
- Discord voice-specific STT runtime profile
- Noise gating and low-confidence transcript filtering

## Install
Run:
```bash
scripts/install.sh /path/to/hermes-agent
```

## Verify
Run:
```bash
scripts/verify.sh /path/to/hermes-agent
```
