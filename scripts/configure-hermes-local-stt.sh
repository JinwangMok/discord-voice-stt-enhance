#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$REPO_DIR/runtime"
SERVER_URL="${HERMES_LOCAL_STT_SERVER_URL:-http://127.0.0.1:8177}"
CLIENT_PY="${HERMES_LOCAL_STT_CLIENT_PY:-$RUNTIME_DIR/client.py}"

# Add this to ~/.hermes/.env
echo "export HERMES_LOCAL_STT_SERVER_URL=${SERVER_URL}"
echo "export HERMES_LOCAL_STT_COMMAND='python ${CLIENT_PY} --input {input_path} --output-dir {output_dir} --language {language} --model {model}'"
echo
echo '# If Hermes is in a VM and the STT runtime is on the Windows GPU host, set HERMES_LOCAL_STT_SERVER_URL to the Windows host IP (for example http://192.168.0.10:8177).'
echo

cat <<'YAML'
stt:
  enabled: true
  provider: local
  local:
    model: base
    language: ''
  discord_voice:
    provider: local_command
    local:
      model: large-v3-turbo
YAML
