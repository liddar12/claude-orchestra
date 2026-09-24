#!/usr/bin/env bash
# Local install: makes every repo on this machine use the orchestra setup.
#   - registers this marketplace and installs the plugin at user scope
#   - sets model/env/permissions in ~/.claude/settings.json
#   - installs Codex CLI if missing
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

claude plugin marketplace add "$here"
claude plugin install orchestra@claude-orchestra --scope user
python3 "$here/merge-settings.py" "$HOME/.claude/settings.json" --no-plugin

if ! command -v codex >/dev/null 2>&1; then
  npm install -g @openai/codex
fi
if [[ ! -f "${CODEX_HOME:-$HOME/.codex}/auth.json" && -z "${OPENAI_API_KEY:-}" ]]; then
  echo "Next: run 'codex login' so the astra subagent can reach GPT-6-Astra."
fi
echo "Done. Restart Claude Code."
