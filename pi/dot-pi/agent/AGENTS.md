# Global AGENTS.md

## Communication

- Give brief progress updates for multi-step work.
- Before a batch of edits or commands, say what you are about to do.
- After an important step, say what changed or what you ruled out.
- Be clear, direct, concise, and mention file paths when relevant.
- Do not use emojis.

## Planning and Tasking

- Always decompose work into concrete steps, even if no tasks are created.
- If there is only one simple non-exploratory action, do it directly without creating a task.
- Treat code search, repo inspection, file discovery, tracing, comparison, and “find where X is defined” requests as exploratory work even if the final answer is short.
- For multi-step work, create separate concrete tasks.
- When using task tools and the likely steps are already known, create the initial task set up front.
- Use task tools when available; mark tasks in progress before starting and completed when done.
- Make tasks granular and delegable; for Explore, use one focused question or tracing goal per task, and split multi-domain scopes when practical.
- For exploratory work, create at least one concrete task unless it is just reading one explicitly named file with no additional lookup.
- If work splits into 2+ independent parts, create one task per part and run them in parallel when practical.
- If an Explore scope spans several domains, prefer one task per domain area.

## Subagents and Explore

- Prefer read-only subagents for explore, search, inspection, and planning.
- For a global `Explore` agent, prefer a bounded scout role: use read-only search tools like `read`, `grep`, `find`, and `ls` when possible, avoid `bash` unless it is actually needed, and bias prompts toward sufficiency, confidence, and the next question instead of exhaustive research.
- Keep Explore work bounded: name the initial scope, ask for compact evidence, and require confidence plus the next file or question if confidence is not high.
- Do not give one Explore agent multiple unrelated search, compare, and synthesis goals unless that breadth is explicitly required.
- Only skip a subagent for a trivial single-file, single-question read with no search, comparison, or branching; say why if you skip it.
- Integrate subagent results; prefer exact paths, short answers, and explicit unknowns.
- When a subagent completion notification arrives with a result preview, do not call `get_subagent_result` or `TaskOutput` to re-fetch the same result unless the preview is truncated and you need the full content for the next step. If the preview is sufficient, summarize it directly without an extra fetch.

## Policy Precedence

- Follow the most local applicable `AGENTS.md`.
- Local or repo `AGENTS.md` policy can be stricter than generic Pi defaults or README guidance; follow the local policy and installed tooling rather than assuming Pi core behavior is the ceiling.

## Skills and Documentation

- When adding or changing reusable helper scripts in a skill, update `SKILL.md` and nearby reference docs in the same pass so later sessions discover the supported entrypoints.

## Git and Commits

- Before any `git commit`, show a short summary of the pending changes, list the files to be committed, show the drafted commit message, and ask the user for explicit confirmation. Do not commit without that confirmation.
- Use conventional commits.
- Prefer no commit body except the footer; if a body is needed, keep it super concise.
- Always add the footer `Assisted-by: agent name (model name)`.
