# Global AGENTS.md

## Communication

- Give brief progress updates for multi-step work.
- Before a batch of edits or commands, say what you are about to do.
- After an important step, say what changed or what you ruled out.
- Be clear, direct, concise, and mention file paths when relevant.
- Do not use emojis.

## Plans

- Always break the work into concrete steps, even if you do not need to call `update_plan`.
- If there is only one simple non-exploratory action, do it directly without a plan update.
- Treat code search, repo inspection, file discovery, tracing, comparison, and “find where X is defined” as exploratory work even if the final answer will be short.
- For multi-step or exploratory work, use `update_plan` early with small outcome-oriented steps.
- Use Codex plan statuses literally: `pending`, `in_progress`, and `completed`.
- Keep exactly one plan step `in_progress` at a time.
- When the likely path is already clear, create the initial plan up front instead of narrating an implicit plan.
- Keep steps granular enough to finish, verify, or hand off cleanly.
- If the work splits into 2+ independent parts, represent them as separate steps and parallelize only when the workflow supports it.
- Update the plan when scope changes, and mark steps completed as soon as the result is actually in hand.
- Mark a step `completed` before starting the next step or presenting the task as finished.
- If you finish a step and continue working, immediately move the next active step to `in_progress` so stale state does not linger.
- Before the final response, do a quick stale-state pass and fix any step that is still `pending` or `in_progress` despite already being done.

## Agents and Exploration

- Do not use `spawn_agent` unless the user explicitly asks for delegation, agents, or parallel agent work.
- When delegation is not explicitly requested, do exploration locally with read-oriented commands such as `rg`, `sed`, `ls`, and `git diff`.
- If delegation is explicitly requested, use `explorer` for bounded codebase questions and `worker` for implementation work with a clear write scope.
- Keep delegated prompts narrow: one concrete question, trace, or ownership area per agent unless broader scope is clearly required.
- If multiple delegated tasks are independent, give each agent a disjoint responsibility and continue the main thread locally instead of waiting immediately.
- Reuse an existing agent with `send_input` when the follow-up stays on the same thread of work.
- Call `wait_agent` sparingly and mainly when the next critical-path step is blocked on that result.
- Integrate agent results directly, preferring exact paths, concise findings, and explicit unknowns.

## Skills and Documentation

- When adding or changing reusable helper scripts in a skill, update `SKILL.md` and nearby reference docs in the same pass so later sessions discover the supported entrypoints.

## Git and Commits

- Before any `git commit`, show a short summary of the pending changes, list the files to be committed, show the drafted commit message, and ask the user for explicit confirmation. Do not commit without that confirmation.
- Use conventional commits.
- Prefer no commit body except the footer; if a body is needed, keep it super concise.
- Always add the footer `Assisted-by: agent name (model name)`.
