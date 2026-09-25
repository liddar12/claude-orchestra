#!/usr/bin/env bash
# One-line installer for cloud environment setup scripts and new machines:
#   curl -fsSL https://raw.githubusercontent.com/liddar12/claude-orchestra/main/bootstrap.sh | bash
# Cloud sessions can only git clone (or download archives of) repos attached to
# the session, but raw.githubusercontent.com is reachable. So this downloads
# each file listed in manifest.txt, plus OpenAI's Codex plugin files listed in
# vendor/codex-plugin-cc.txt (pinned commit), then runs install.sh.
# Output is also logged to ~/.claude/orchestra-install.log.
set -uo pipefail
raw="https://raw.githubusercontent.com"
repo="liddar12/claude-orchestra"
dest="$HOME/claude-orchestra"
codex_dest="$HOME/.cache/orchestra/codex-plugin-cc"
mkdir -p "$HOME/.claude"
log="$HOME/.claude/orchestra-install.log"

fetch_list() {  # base_url list_file out_dir
  local base="$1" list="$2" out="$3" path
  while IFS= read -r path; do
    [[ -z "$path" || "$path" == sha\ * ]] && continue
    mkdir -p "$out/$(dirname "$path")"
    curl -fsSL "$base/$path" -o "$out/$path" || { echo "orchestra: failed to fetch $base/$path" >&2; return 1; }
  done < "$list"
}

{
  echo "== orchestra bootstrap $(date -u +%FT%TZ)"
  tmp="$(mktemp -d)"
  curl -fsSL "$raw/$repo/main/manifest.txt" -o "$tmp/.manifest" \
    && fetch_list "$raw/$repo/main" "$tmp/.manifest" "$tmp" \
    || { echo "orchestra: could not download $repo" >&2; exit 1; }
  rm -f "$tmp/.manifest"
  find "$tmp" -name '*.sh' -exec chmod +x {} + ; chmod +x "$tmp/merge-settings.py"
  rm -rf "$dest" && mv "$tmp" "$dest"
  echo "orchestra: downloaded $repo"

  sha="$(awk '/^sha /{print $2}' "$dest/vendor/codex-plugin-cc.txt")"
  ctmp="$(mktemp -d)"
  if fetch_list "$raw/openai/codex-plugin-cc/$sha" "$dest/vendor/codex-plugin-cc.txt" "$ctmp"; then
    rm -rf "$codex_dest" && mkdir -p "$(dirname "$codex_dest")" && mv "$ctmp" "$codex_dest"
    echo "orchestra: downloaded openai/codex-plugin-cc@${sha:0:7}"
  else
    echo "orchestra: could not download openai/codex-plugin-cc; install.sh will try GitHub directly" >&2
  fi

  "$dest/install.sh"
} 2>&1 | tee -a "$log"
exit "${PIPESTATUS[0]}"
