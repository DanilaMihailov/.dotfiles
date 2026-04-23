import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const HAS_EXTERNAL_EDITOR = !!(process.env.VISUAL || process.env.EDITOR);

/**
 * Adds /system-prompt, which opens the current effective system prompt in a
 * modal editor. Pi's extension editor already supports Ctrl+G to hand off the
 * content to $VISUAL/$EDITOR without overwriting the main input editor.
 */
export default function showSystemPromptExtension(pi: ExtensionAPI) {
  pi.registerCommand("system-prompt", {
    description: "Show the current system prompt; press Ctrl+G for external editor",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) {
        ctx.ui.notify("/system-prompt requires interactive mode", "error");
        return;
      }

      const prompt = ctx.getSystemPrompt();
      if (!prompt.trim()) {
        ctx.ui.notify("System prompt is empty", "warning");
        return;
      }

      if (!HAS_EXTERNAL_EDITOR) {
        ctx.ui.notify("Set $VISUAL or $EDITOR if you want Ctrl+G to open an external editor", "warning");
      }

      await ctx.ui.editor(
        HAS_EXTERNAL_EDITOR
          ? `Current system prompt (${prompt.length} chars) — Ctrl+G for external editor`
          : `Current system prompt (${prompt.length} chars)`,
        prompt,
      );
    },
  });
}
