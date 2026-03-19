#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${FIREFOX_DEVTOOLS_MCP_PATH:-}" ]]; then
  exec node "$FIREFOX_DEVTOOLS_MCP_PATH/dist/index.js" "$@"
else
  exec pnpx @padenot/firefox-devtools-mcp "$@"
fi
