# claude-orchestra

Shared Claude Code setup for all of my repos. Fable (`claude-fable-5-1`) runs the main session and manages the work. Subagents do it:

| Agent | Runs on | Use for |
|---|---|---|
| `opus-worker` | Opus 5.5 (`claude-opus-5-5`) | Judgment: debugging, spec and design analysis, code review |
| `astra` | Codex CLI on GPT-6-Astra (`gpt-6-astra`), relayed by Haiku | Mechanical work with a clear spec: implementation, bulk edits, refactors, tests |
| Built-ins (Explore, Plan, general-purpose) | Opus 5.5 via `CLAUDE_CODE_SUBAGENT_MODEL` | Search and planning |

## What's in here

- `plugins/orchestra/`: the Claude Code plugin
  - `agents/opus-worker.md`, `agents/astra.md`
  - `bin/astra`: `codex exec` wrapper, on PATH whenever the plugin is enabled
  - `hooks/routing.sh`: SessionStart hook that loads the routing rules into every session
- `templates/settings.json`: model, env, permissions, and plugin settings
- `install.sh`: local install for every repo on a machine
- `apply-to-repo.sh`: adds the settings to one repo so cloud sessions pick it up

## Local CLI (every repo on this machine)

```sh
git clone https://github.com/liddar12/claude-orchestra ~/claude-orchestra
~/claude-orchestra/install.sh
codex login
```

This registers the marketplace, installs the plugin at user scope, and writes the model and env settings into `~/.claude/settings.json`.

## Cloud sessions (claude.ai/code)

Cloud containers start clean, so each repo carries a small `.claude/settings.json` that points at this marketplace:

```sh
~/claude-orchestra/apply-to-repo.sh /path/to/repo
```

Then commit `.claude/settings.json` in that repo. Applied so far: `ayso`, `NFL2026`.

Cloud environment settings also need, once per environment:
- Network: allow `api.openai.com`
- Environment variable: `OPENAI_API_KEY`

## Astra settings

`astra [--read-only] "<prompt>"` reads these env vars:

| Var | Default |
|---|---|
| `CODEX_ASTRA_MODEL` | `gpt-6-astra` |
| `CODEX_ASTRA_EFFORT` | `high` |
| `CODEX_ASTRA_SANDBOX` | `workspace-write` (`read-only` with `--read-only`) |

If the Codex sandbox fails inside a container, set `CODEX_ASTRA_SANDBOX=danger-full-access`. The container is already isolated.

## Changing the setup

Edit here, bump `version` in `plugins/orchestra/.claude-plugin/plugin.json`, push. Local: `claude plugin update orchestra@claude-orchestra`. Cloud sessions fetch the latest on start.
