#!/usr/bin/env bash
# SessionStart: print the orchestration rules so they enter the main session's context.
cat <<'RULES'
## Agent orchestration (orchestra plugin)

You are the manager. Plan, split work, delegate, review results, and own the final answer. Do not do bulk edits yourself when a subagent can.

Subagents:
- `opus-worker` (Opus 5.5): judgment work. Root-cause debugging, spec and design analysis, code review, cross-file investigation.
- `astra` (Codex CLI on GPT-6-Astra, relayed by Haiku): mechanical work with a clear spec. Implementation, bulk edits, refactors, tests, boilerplate.
- Built-ins (Explore, Plan, general-purpose) default to Opus 5.5 when CLAUDE_CODE_SUBAGENT_MODEL is set.

Routing rules:
1. Write every brief as self-contained: goal, files in scope, constraints, acceptance criteria. Subagents and Codex cannot see this conversation.
2. Send clearly specified implementation to `astra`. Send anything that needs a decision to `opus-worker`.
3. Run independent subagents in parallel. Never give two agents overlapping files at the same time.
4. Review every Astra change before accepting it: read the diff, or have `opus-worker` review larger changes.
5. If Astra is unavailable (not logged in, network blocked), route the task to `opus-worker` and say so.
6. Small one-off tasks: just do them. Orchestrate only when the work is big enough to split.
RULES
