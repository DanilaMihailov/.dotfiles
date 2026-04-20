/**
 * Module summary: registers the custom `bothub` provider, pointing Pi at an
 * OpenAI-compatible Bothub endpoint and exposing the `gemini-3-flash-preview`
 * model with reasoning support and provider metadata.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Registers the custom Bothub provider and its Gemini model metadata.
 */
export default function bothubExtension(pi: ExtensionAPI) {
  pi.registerProvider("bothub", {
    baseUrl: "https://bothub.chat/api/v2/openai/v1",
    apiKey: "BOTHUB_KEY", // env var name or literal value
    api: "openai-completions", // which streaming API to use
    models: [
      {
        id: "gemini-3-flash-preview",
        name: "Gemini 3 Flash",
        reasoning: true, // supports extended thinking
        input: ["text"],
        cost: {
          input: 0.5, // $/million tokens
          output: 3.0,
          cacheRead: 0.3,
          cacheWrite: 3.75,
        },
        contextWindow: 1000000,
        maxTokens: 16384,
      },
    ],
  });
}
