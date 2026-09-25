#!/usr/bin/env bash
# Regenerates the file lists bootstrap.sh downloads from raw.githubusercontent.com.
#   manifest.txt                 this repo's files
#   vendor/codex-plugin-cc.txt   openai/codex-plugin-cc files, pinned to a commit
# Run after adding/removing files here, or to move the Codex plugin to a newer commit:
#   tools/refresh-manifests.sh [path-to-codex-plugin-cc-clone]
set -euo pipefail
cd "$(dirname "$0")/.."
git ls-files | grep -vE '^(manifest\.txt)$' > manifest.txt
echo manifest.txt >> manifest.txt

src="${1:-}"
if [[ -z "$src" ]]; then
  src="$(mktemp -d)"
  git clone -q --depth 1 https://github.com/openai/codex-plugin-cc "$src"
fi
{
  echo "sha $(git -C "$src" rev-parse HEAD)"
  git -C "$src" ls-files -- .claude-plugin/marketplace.json plugins/codex LICENSE NOTICE
} > vendor/codex-plugin-cc.txt
echo "manifest.txt: $(wc -l < manifest.txt) files; codex-plugin-cc: $(($(wc -l < vendor/codex-plugin-cc.txt) - 1)) files"
