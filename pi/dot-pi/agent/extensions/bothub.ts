/**
 * Module summary: registers the custom `bothub` provider, pointing Pi at an
 * OpenAI-compatible Bothub endpoint and exposing its configured
 * models with reasoning support and provider metadata.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Registers the custom Bothub provider and its model metadata.
 */
export default function bothubExtension(pi: ExtensionAPI) {
  // Inject OpenRouter provider routing for models that define compat.openRouterRouting.
  // Pi only does this automatically when baseUrl contains "openrouter.ai", but Bothub
  // passes through OpenRouter body params, so apply routing to Bothub requests here.
  pi.on("before_provider_request", (event, ctx) => {
    if (ctx.model?.provider !== "bothub" || ctx.model.api !== "openai-completions") return;
    const compat = ctx.model.compat;
    const routing = compat && "openRouterRouting" in compat ? compat.openRouterRouting : undefined;
    if (!routing) return;
    if (!event.payload || typeof event.payload !== "object" || Array.isArray(event.payload)) return;
    const payload = event.payload as Record<string, unknown>;
    if (payload.provider) return; // don't override if already set
    return { ...payload, provider: routing };
  });

  pi.registerProvider("bothub", {
    baseUrl: "https://bothub.chat/api/v2/openai/v1",
    apiKey: "$BOTHUB_KEY", // resolve the API key from the environment
    api: "openai-completions", // which streaming API to use
    models: [
      {
        id: "gemini-3-flash-preview",
        name: "Gemini 3 Flash",
        reasoning: true, // supports extended thinking
        input: ["text", "image"],
        cost: {
          input: 0.5, // $/million tokens
          output: 3.0,
          cacheRead: 0.05,
          cacheWrite: 0.0833,
        },
        contextWindow: 1048576,
        maxTokens: 65536,
      },
      {
        id: "minimax-m2.7",
        name: "Minimax M2.7",
        reasoning: true,
        input: ["text"],
        cost: {
          input: 0.3,
          output: 1.2,
          cacheRead: 0.059,
          cacheWrite: 0,
        },
        contextWindow: 196608,
        maxTokens: 128000, // Normalized to standard power-of-2 context where applicable
      },
      {
        id: "gpt-6-luna",
        name: "GPT-6 Luna",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0.75,
          output: 4.5,
          cacheRead: 0.075,
          cacheWrite: 0,
        },
        contextWindow: 400000,
        maxTokens: 128000,
      },
      {
        id: "glm-5.1",
        name: "GLM 5.1",
        reasoning: true,
        input: ["text"],
        cost: {
          input: 1.05,
          output: 3.5,
          cacheRead: 0.525,
          cacheWrite: 0,
        },
        contextWindow: 202752,
        maxTokens: 65535,
      },
      {
        id: "qwen3.6-plus",
        name: "Qwen 3.6 Plus",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0.325,
          output: 1.95,
          cacheRead: 0,
          cacheWrite: 0.40625,
        },
        contextWindow: 1000000,
        maxTokens: 65536,
      },
      {
        id: "kimi-k2.6",
        name: "Kimi K2.6",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0.95,
          output: 4.0,
          cacheRead: 0.16,
          cacheWrite: 0,
        },
        contextWindow: 262144,
        maxTokens: 65536,
      },
      {
        id: "deepseek-v4-flash",
        name: "DeepSeek V4 Flash",
        reasoning: true,
        input: ["text"],
        cost: {
          input: 0.112,
          output: 0.224,
          cacheRead: 0.022,
          cacheWrite: 0,
        },
        contextWindow: 1048576,
        maxTokens: 384000,
        // compat: {
        //   openRouterRouting: {
        //     only: ["deepseek"],
        //   },
        // },
      },
      {
        id: "deepseek-v4-pro",
        name: "DeepSeek V4 Pro",
        reasoning: true,
        input: ["text"],
        cost: {
          input: 0.435,
          output: 0.87,
          cacheRead: 0.003625,
          cacheWrite: 0,
        },
        contextWindow: 1048576,
        maxTokens: 384000,
        // compat: {
        //   openRouterRouting: {
        //     only: ["deepseek"],
        //   },
        // },
      },
      {
        id: "elephant-alpha",
        name: "Elephant",
        reasoning: false,
        input: ["text"],
        cost: {
          input: 0,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
        },
        contextWindow: 262144,
        maxTokens: 32768,
      },
    ],
  });
}
