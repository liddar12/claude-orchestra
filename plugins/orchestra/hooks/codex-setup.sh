#!/usr/bin/env bash
# SessionStart: make Codex (used through the codex@openai-codex plugin) run on Astra.
# - Pins model and effort in ~/.codex/config.toml, only where they are not already set.
# - Cloud sessions: installs the Codex CLI and logs in from OPENAI_API_KEY.
# Prints nothing to stdout, so it adds nothing to the session context.
set -u

ASTRA_MODEL="gpt-6-astra"
ASTRA_EFFORT="high"

codex_home="${CODEX_HOME:-$HOME/.codex}"
cfg="$codex_home/config.toml"
mkdir -p "$codex_home"
touch "$cfg"

# Is a key set at top level (before the first [table])?
has_top_key() {
  awk -v k="$1" '/^[[:space:]]*\[/ { exit 1 } $0 ~ "^[[:space:]]*" k "[[:space:]]*=" { found = 1; exit 0 } END { exit !found }' "$cfg"
}

# Top-level TOML keys must come before any [table], so prepend missing ones.
prepend=""
has_top_key model || prepend+="model = \"$ASTRA_MODEL\"\n"
has_top_key model_reasoning_effort || prepend+="model_reasoning_effort = \"$ASTRA_EFFORT\"\n"
if [[ -n "$prepend" ]]; then
  tmp="$(mktemp)"
  { printf "%b" "$prepend"; cat "$cfg"; } > "$tmp" && mv "$tmp" "$cfg"
fi

if [[ "${CLAUDE_CODE_REMOTE:-}" == "true" ]] && ! command -v codex >/dev/null 2>&1; then
  npm install -g @openai/codex >/dev/null 2>&1 || echo "orchestra: Codex CLI install failed" >&2
fi

if [[ ! -f "$codex_home/auth.json" && -n "${OPENAI_API_KEY:-}" ]] && command -v codex >/dev/null 2>&1; then
  printenv OPENAI_API_KEY | codex login --with-api-key >/dev/null 2>&1 || echo "orchestra: codex login failed" >&2
fi
exit 0
