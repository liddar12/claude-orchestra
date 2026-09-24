#!/usr/bin/env bash
# Add the orchestra setup to a repo's committed .claude/settings.json so cloud
# sessions (claude.ai/code) on that repo load it too.
# Usage: ./apply-to-repo.sh /path/to/repo
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="${1:?usage: apply-to-repo.sh /path/to/repo}"
python3 "$here/merge-settings.py" "$repo/.claude/settings.json"
echo "Commit $repo/.claude/settings.json to apply it in cloud sessions."
