#!/usr/bin/env bash
# SessionStart: print the orchestration rules so they enter the main session's context.
cat <<'RULES'
## Agent orchestration (orchestra plugin)

You are the manager. Plan, split work, delegate, review results, and own the final answer. Do not write feature code yourself when a subagent can. Where the repo's CLAUDE.md gives more specific rules, those win.

Subagents:
- `orchestra:opus-worker` (Opus 5.5): judgment work. Root-cause debugging, spec and design analysis, code review, cross-file investigation.
- Codex on Astra, through the codex plugin: implementation. Dispatch with the `codex:codex-rescue` subagent (or `/codex:rescue`), write-capable, `--background` for anything multi-step, one job per independent partition. Codex's model and effort come from ~/.codex/config.toml; never pass `--model` or `--effort`.
- Built-ins (Explore, Plan, general-purpose) run on Opus when CLAUDE_CODE_SUBAGENT_MODEL is set.

Routing rules:
1. Write every brief as self-contained: goal, repo-relative file ownership, constraints, the exact commands that must exit 0. Subagents and Codex cannot see this conversation.
2. Send clearly specified implementation to Codex. Send anything that needs a decision to `orchestra:opus-worker`.
3. Run independent work in parallel, but never give two agents overlapping files.
4. Never trust Codex output on its word: read the diff, re-run the checks, and have `orchestra:opus-worker` or `/codex:adversarial-review` review larger changes before a PR.
5. If Codex is unavailable (CLI missing, not logged in, network blocked), route the task to `orchestra:opus-worker` and say so.
6. Small one-off tasks: just do them. Orchestrate only when the work is big enough to split.
RULES
