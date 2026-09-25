#!/usr/bin/env bash
# Installs the orchestra setup at user scope, so every repo on this machine or
# cloud environment uses it. Safe to re-run.
#   Usually run by bootstrap.sh:
#   curl -fsSL https://raw.githubusercontent.com/liddar12/claude-orchestra/main/bootstrap.sh | bash
# Steps:
#   - registers both marketplaces and installs orchestra + codex plugins
#   - sets the main and subagent model aliases in ~/.claude/settings.json
#   - installs the Codex CLI if missing and pins its model
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
fail=0

step() { echo "orchestra: $1"; }
run() { "$@" >/dev/null 2>&1 || { echo "orchestra: failed: $*" >&2; fail=1; }; }

has_marketplace() { claude plugin marketplace list 2>/dev/null | grep -q "$1"; }
has_plugin() { claude plugin list 2>/dev/null | grep -q "$1"; }

step "marketplaces"
has_marketplace claude-orchestra || run claude plugin marketplace add "$here"
if ! has_marketplace openai-codex; then
  if ! claude plugin marketplace add openai/codex-plugin-cc >/dev/null 2>&1; then
    # Fallback: fetch the marketplace over HTTPS and register it from disk.
    cache="$HOME/.cache/orchestra/codex-plugin-cc"
    rm -rf "$cache" && mkdir -p "$cache"
    if git clone -q --depth 1 https://github.com/openai/codex-plugin-cc "$cache" 2>/dev/null \
       || curl -fsSL https://codeload.github.com/openai/codex-plugin-cc/tar.gz/refs/heads/main | tar xz --strip-components=1 -C "$cache"; then
      run claude plugin marketplace add "$cache"
    else
      echo "orchestra: failed: could not fetch openai/codex-plugin-cc" >&2; fail=1
    fi
  fi
fi
run claude plugin marketplace update

step "plugins"
has_plugin orchestra@claude-orchestra || run claude plugin install orchestra@claude-orchestra --scope user
has_plugin codex@openai-codex || run claude plugin install codex@openai-codex --scope user

step "settings"
run python3 "$here/merge-settings.py" "$HOME/.claude/settings.json"

step "codex"
command -v codex >/dev/null 2>&1 || run npm install -g @openai/codex
CLAUDE_CODE_REMOTE="${CLAUDE_CODE_REMOTE:-}" "$here/plugins/orchestra/hooks/codex-setup.sh"
[[ -f "${CODEX_HOME:-$HOME/.codex}/auth.json" ]] || echo "orchestra: Codex not logged in yet (run 'codex login', or set OPENAI_API_KEY in the cloud environment)."

if [[ $fail -eq 0 ]]; then echo "orchestra: done"; else echo "orchestra: finished with errors" >&2; fi
exit $fail
