# claude-orchestra

Shared Claude Code setup for all of my repos. Fable runs the main session and manages the work. Subagents do it:

| Who | Runs on | Use for |
|---|---|---|
| Main session | Fable (`fable` alias) | Plan, partition, brief, review, ship |
| `orchestra:opus-worker` | Opus 5.5 (`claude-opus-5-5`) | Judgment: debugging, spec and design analysis, code review |
| Codex, via `codex:codex-rescue` | GPT-6-Astra (`gpt-6-astra`) | Implementation from a clear brief |
| Built-ins (Explore, Plan, general-purpose) | Opus (`CLAUDE_CODE_SUBAGENT_MODEL=opus`) | Search and planning |

Codex runs through OpenAI's official plugin, [`codex@openai-codex`](https://github.com/openai/codex-plugin-cc) (codex-rescue subagent, background jobs, `/codex:review`, `/codex:adversarial-review`, optional stop-time review gate). This repo does not wrap Codex itself.

## One source of truth for models

- Claude models: `templates/settings.json` uses aliases (`fable`, `opus`) and lives in user settings, so repos carry no model IDs. `orchestra:opus-worker` pins `claude-opus-5-5` in this plugin.
- Codex model: `~/.codex/config.toml`. The orchestra SessionStart hook writes `model = "gpt-6-astra"` and `model_reasoning_effort = "high"` there only if those keys are not already set. To change the Codex model, edit `ASTRA_MODEL` in `plugins/orchestra/hooks/codex-setup.sh` (for new machines and cloud sessions) or your own `~/.codex/config.toml`.

## What's in here

- `plugins/orchestra/`: the Claude Code plugin
  - `agents/opus-worker.md`
  - `hooks/codex-setup.sh`: pins the Codex model; in cloud sessions also installs the Codex CLI and logs in from `OPENAI_API_KEY`
  - `hooks/routing.sh`: loads the routing rules into every session
- `bootstrap.sh`: one-line entry point; downloads this repo to `~/claude-orchestra` and OpenAI's Codex plugin (pinned commit) to `~/.cache/orchestra`, then runs `install.sh`
- `manifest.txt`, `vendor/codex-plugin-cc.txt`: file lists for the bootstrap; regenerate with `tools/refresh-manifests.sh` after adding files or to move the Codex plugin pin
- `install.sh`: user-scope install for every repo on a machine or cloud environment. Safe to re-run.
- `templates/settings.json`: model aliases merged into `~/.claude/settings.json`

## Local CLI (every repo on this machine)

```sh
curl -fsSL https://raw.githubusercontent.com/liddar12/claude-orchestra/main/bootstrap.sh | bash
codex login
```

## Cloud sessions (claude.ai/code, every repo in an environment)

Claude Code only trusts a GitHub-hosted plugin marketplace when it is declared in user or managed settings, not in a repo's `.claude/settings.json`. So cloud environments install this at user scope from their setup script.

In each cloud environment (environment menu in the session title bar, then Edit):
1. Setup script: `curl -fsSL https://raw.githubusercontent.com/liddar12/claude-orchestra/main/bootstrap.sh | bash`
   (Cloud sessions can only `git clone` or download archives of repos attached to that session, so it downloads each file from raw.githubusercontent.com using `manifest.txt` and `vendor/codex-plugin-cc.txt`. Output is logged to `~/.claude/orchestra-install.log`.)
2. Environment variable: `OPENAI_API_KEY`
3. Network: allow `api.openai.com`

Pick Fable in the session's model picker. In cloud sessions the picker decides the main model, and `model` in settings does not override it.

## Changing the setup

Edit here, bump `version` in `plugins/orchestra/.claude-plugin/plugin.json`, push. Local: `git -C ~/claude-orchestra pull && claude plugin update orchestra@claude-orchestra`. Cloud sessions clone the latest when they start.
