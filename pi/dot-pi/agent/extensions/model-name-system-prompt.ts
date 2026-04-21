/**
 * Appends the active Pi model identity to the system prompt for each turn.
 *
 * This gives the agent explicit access to the current model name without
 * relying on footer/UI visibility.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Injects the current model name and provider into the system prompt.
 */
export default function modelNameSystemPromptExtension(pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event, ctx) => {
    const model = ctx.model;
    if (!model) return undefined;

    const providerAndId = `${model.provider}/${model.id}`;
    const displayName = model.name.trim();

    return {
      systemPrompt:
        event.systemPrompt +
        `

## Runtime Model

Current active model: ${displayName} (${providerAndId})
`,
    };
  });
}
