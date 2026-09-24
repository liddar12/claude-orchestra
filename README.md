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

- Claude models: `templates/settings.json` uses aliases (`fable`, `opus`), so repos carry no model IDs. `orchestra:opus-worker` pins `claude-opus-5-5` in this plugin.
- Codex model: `~/.codex/config.toml`. The orchestra SessionStart hook writes `model = "gpt-6-astra"` and `model_reasoning_effort = "high"` there only if those keys are not already set. To change the Codex model, edit `ASTRA_MODEL` in `plugins/orchestra/hooks/codex-setup.sh` (for new machines and cloud sessions) or your own `~/.codex/config.toml`.

## What's in here

- `plugins/orchestra/`: the Claude Code plugin
  - `agents/opus-worker.md`
  - `hooks/codex-setup.sh`: pins the Codex model; in cloud sessions also installs the Codex CLI and logs in from `OPENAI_API_KEY`
  - `hooks/routing.sh`: loads the routing rules into every session
- `templates/settings.json`: models, both marketplaces, both plugins enabled
- `install.sh`: local install for every repo on a machine
- `apply-to-repo.sh`: adds the settings to one repo so cloud sessions pick it up

## Local CLI (every repo on this machine)

```sh
git clone https://github.com/liddar12/claude-orchestra ~/claude-orchestra
~/claude-orchestra/install.sh
codex login
```

## Cloud sessions (claude.ai/code)

Cloud containers start clean, so each repo commits a small `.claude/settings.json`:

```sh
~/claude-orchestra/apply-to-repo.sh /path/to/repo
```

Applied so far: `ayso`, `NFL2026`.

Each cloud environment also needs, once:
- Network: allow `api.openai.com`
- Environment variable: `OPENAI_API_KEY`

## Changing the setup

Edit here, bump `version` in `plugins/orchestra/.claude-plugin/plugin.json`, push. Local: `claude plugin update orchestra@claude-orchestra`. Cloud sessions fetch the latest when they start.
