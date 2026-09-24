#!/usr/bin/env bash
# Local install: every repo on this machine gets the orchestra setup.
#   - registers both marketplaces and installs orchestra + codex plugins at user scope
#   - sets the main and subagent models in ~/.claude/settings.json
#   - installs the Codex CLI if missing
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

claude plugin marketplace add "$here"
claude plugin marketplace add openai/codex-plugin-cc
claude plugin install orchestra@claude-orchestra --scope user
claude plugin install codex@openai-codex --scope user
python3 "$here/merge-settings.py" "$HOME/.claude/settings.json" --no-plugin

command -v codex >/dev/null 2>&1 || npm install -g @openai/codex
"$here/plugins/orchestra/hooks/codex-setup.sh"
if [[ ! -f "${CODEX_HOME:-$HOME/.codex}/auth.json" ]]; then
  echo "Next: run 'codex login'."
fi
echo "Done. Restart Claude Code, then run /codex:setup once to confirm Codex is ready."
