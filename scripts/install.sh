#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_DIR="${1:-/home/jinwang/.hermes/hermes-agent}"

"$SCRIPT_DIR/apply-hermes-patch.sh" "$HERMES_DIR"
echo "Install complete for $HERMES_DIR"
