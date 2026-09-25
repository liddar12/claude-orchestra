#!/usr/bin/env bash
# One-line installer for cloud environment setup scripts and new machines:
#   curl -fsSL https://raw.githubusercontent.com/liddar12/claude-orchestra/main/bootstrap.sh | bash
# Downloads this repo to ~/claude-orchestra over HTTPS (git clone as fallback),
# then runs install.sh. Output is also logged to ~/.claude/orchestra-install.log.
set -uo pipefail
dest="$HOME/claude-orchestra"
repo="liddar12/claude-orchestra"
mkdir -p "$HOME/.claude"
log="$HOME/.claude/orchestra-install.log"

{
  echo "== orchestra bootstrap $(date -u +%FT%TZ)"
  tmp="$(mktemp -d)"
  if curl -fsSL "https://codeload.github.com/$repo/tar.gz/refs/heads/main" | tar xz --strip-components=1 -C "$tmp"; then
    echo "orchestra: downloaded tarball"
  elif git clone -q --depth 1 "https://github.com/$repo" "$tmp/clone"; then
    echo "orchestra: cloned with git"
    tmp="$tmp/clone"
  else
    echo "orchestra: could not download $repo" >&2
    exit 1
  fi
  rm -rf "$dest" && mv "$tmp" "$dest"
  "$dest/install.sh"
} 2>&1 | tee -a "$log"
exit "${PIPESTATUS[0]}"
