/**
 * Module summary: registers the custom `codex-lb` provider and implements its
 * streaming bridge to a Codex load-balancer backend, converting Pi context,
 * tools, reasoning, and transport options into Responses-style SSE/WebSocket
 * requests for the `gpt-5.4` model family.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
  createAssistantMessageEventStream,
  getEnvApiKey,
  supportsXhigh,
  type AssistantMessage,
  type Context,
  type Model,
  type ProviderResponse,
  type SimpleStreamOptions,
} from "@mariozechner/pi-ai";
import {
  convertResponsesMessages,
  convertResponsesTools,
  processResponsesStream,
} from "../node_modules/@mariozechner/pi-ai/dist/providers/openai-responses-shared.js";

const API_ID = "codex-lb-codex";
const BASE_URL = "http://192.168.5.18:2455/backend-api";
const OPENAI_BETA_RESPONSES_WEBSOCKETS = "responses_websockets=2026-02-06";
const OPENAI_BETA_RESPONSES_SSE = "responses=experimental";
const CODEX_TOOL_CALL_PROVIDERS = new Set([
  "openai",
  "openai-codex",
  "opencode",
]);
const CODEX_RESPONSE_STATUSES = new Set([
  "completed",
  "incomplete",
  "failed",
  "cancelled",
  "queued",
  "in_progress",
]);

/**
 * Normalizes pi reasoning levels to what the target model supports.
 */
function normalizeReasoningEffort(
  model: Model<any>,
  reasoning: SimpleStreamOptions["reasoning"],
) {
  if (!reasoning) {
    return undefined;
  }
  return supportsXhigh(model)
    ? reasoning
    : reasoning === "xhigh"
      ? "high"
      : reasoning;
}

/**
 * Applies model-specific reasoning caps expected by the Codex backend.
 */
function clampReasoningEffort(modelId: string, effort: string) {
  const id = modelId.includes("/")
    ? (modelId.split("/").pop() ?? modelId)
    : modelId;
  if (
    (id.startsWith("gpt-5.2") ||
      id.startsWith("gpt-5.3") ||
      id.startsWith("gpt-5.4")) &&
    effort === "minimal"
  ) {
    return "low";
  }
  if (id === "gpt-5.1" && effort === "xhigh") {
    return "high";
  }
  if (id === "gpt-5.1-codex-mini") {
    return effort === "high" || effort === "xhigh" ? "high" : "medium";
  }
  return effort;
}

/**
 * Converts response headers into the plain record shape expected by pi hooks.
 */
function headersToRecord(headers: Headers): Record<string, string> {
  const record: Record<string, string> = {};
  for (const [key, value] of headers.entries()) {
    record[key] = value;
  }
  return record;
}

/**
 * Generates a stable request id for websocket sessions.
 */
function createRequestId() {
  if (typeof globalThis.crypto?.randomUUID === "function") {
    return globalThis.crypto.randomUUID();
  }
  return `codex_lb_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
}

/**
 * Resolves the HTTP responses endpoint from a provider base URL.
 */
function resolveCodexUrl(baseUrl: string) {
  const normalized = baseUrl.replace(/\/+$/, "");
  if (normalized.endsWith("/codex/responses")) {
    return normalized;
  }
  if (normalized.endsWith("/codex")) {
    return `${normalized}/responses`;
  }
  return `${normalized}/codex/responses`;
}

/**
 * Resolves the websocket transport URL from the configured base URL.
 */
function resolveCodexWebSocketUrl(baseUrl: string) {
  const url = new URL(resolveCodexUrl(baseUrl));
  if (url.protocol === "https:") {
    url.protocol = "wss:";
  }
  if (url.protocol === "http:") {
    url.protocol = "ws:";
  }
  return url.toString();
}

/**
 * Builds the shared request headers used by both SSE and websocket transports.
 */
function buildBaseHeaders(
  model: Model<any>,
  apiKey: string,
  options: SimpleStreamOptions | undefined,
) {
  const headers = new Headers({
    ...((model.headers as Record<string, string> | undefined) ?? {}),
    ...(options?.headers ?? {}),
  });

  headers.set("Authorization", `Bearer ${apiKey}`);
  headers.set("originator", "pi");
  headers.set("User-Agent", "pi");
  return headers;
}

/**
 * Adds SSE-specific headers for the experimental responses endpoint.
 */
function buildSseHeaders(
  model: Model<any>,
  apiKey: string,
  options: SimpleStreamOptions | undefined,
) {
  const headers = buildBaseHeaders(model, apiKey, options);
  headers.set("OpenAI-Beta", OPENAI_BETA_RESPONSES_SSE);
  headers.set("accept", "text/event-stream");
  headers.set("content-type", "application/json");
  if (options?.sessionId) {
    headers.set("session_id", options.sessionId);
    headers.set("x-client-request-id", options.sessionId);
  }
  return headers;
}

/**
 * Adds websocket-specific headers required by the Codex backend.
 */
function buildWebSocketHeaders(
  model: Model<any>,
  apiKey: string,
  options: SimpleStreamOptions | undefined,
  requestId: string,
) {
  const headers = buildBaseHeaders(model, apiKey, options);
  headers.delete("accept");
  headers.delete("content-type");
  headers.delete("OpenAI-Beta");
  headers.delete("openai-beta");
  headers.set("OpenAI-Beta", OPENAI_BETA_RESPONSES_WEBSOCKETS);
  headers.set("x-client-request-id", requestId);
  headers.set("session_id", requestId);
  return headers;
}

/**
 * Converts pi context, tools, and reasoning options into a Codex request body.
 */
function buildRequestBody(
  model: Model<any>,
  context: Context,
  options?: SimpleStreamOptions,
) {
  const reasoningEffort = normalizeReasoningEffort(model, options?.reasoning);
  const body: Record<string, unknown> = {
    model: model.id,
    store: false,
    stream: true,
    instructions: context.systemPrompt,
    input: convertResponsesMessages(model, context, CODEX_TOOL_CALL_PROVIDERS, {
      includeSystemPrompt: false,
    }),
    text: { verbosity: "medium" },
    include: ["reasoning.encrypted_content"],
    prompt_cache_key: options?.sessionId,
    tool_choice: "auto",
    parallel_tool_calls: true,
  };

  if (options?.temperature !== undefined) {
    body.temperature = options.temperature;
  }
  if (context.tools) {
    body.tools = convertResponsesTools(context.tools, { strict: null });
  }
  if (reasoningEffort !== undefined) {
    body.reasoning = {
      effort: clampReasoningEffort(model.id, reasoningEffort),
      summary: "auto",
    };
  }

  return body;
}

/**
 * Returns the runtime websocket constructor or throws if unavailable.
 */
function getWebSocketConstructor() {
  const ctor = globalThis.WebSocket;
  if (typeof ctor !== "function") {
    throw new Error("WebSocket transport is not available in this runtime");
  }
  return ctor as any;
}

/**
 * Maps assistant stop reasons to the stream completion reasons pi expects.
 */
function getDoneReason(stopReason: AssistantMessage["stopReason"]) {
  if (
    stopReason === "stop" ||
    stopReason === "length" ||
    stopReason === "toolUse"
  ) {
    return stopReason;
  }
  return "stop";
}

/**
 * Extracts the most useful error message from a websocket error event.
 */
function extractWebSocketError(event: unknown) {
  if (event && typeof event === "object" && "message" in event) {
    const message = (event as { message?: unknown }).message;
    if (typeof message === "string" && message.length > 0) {
      return new Error(message);
    }
  }
  return new Error("WebSocket error");
}

/**
 * Builds an error from an unexpected websocket close event.
 */
function extractWebSocketCloseError(event: unknown) {
  if (event && typeof event === "object") {
    const code =
      "code" in event ? (event as { code?: unknown }).code : undefined;
    const reason =
      "reason" in event ? (event as { reason?: unknown }).reason : undefined;
    const codeText = typeof code === "number" ? ` ${code}` : "";
    const reasonText =
      typeof reason === "string" && reason.length > 0 ? ` ${reason}` : "";
    return new Error(`WebSocket closed${codeText}${reasonText}`.trim());
  }
  return new Error("WebSocket closed");
}

/**
 * Decodes websocket payloads from string, ArrayBuffer, or Blob-like values.
 */
async function decodeWebSocketData(data: unknown) {
  if (typeof data === "string") {
    return data;
  }
  if (data instanceof ArrayBuffer) {
    return new TextDecoder().decode(new Uint8Array(data));
  }
  if (ArrayBuffer.isView(data)) {
    return new TextDecoder().decode(
      new Uint8Array(data.buffer, data.byteOffset, data.byteLength),
    );
  }
  if (data && typeof data === "object" && "arrayBuffer" in data) {
    const arrayBuffer = await (
      data as { arrayBuffer: () => Promise<ArrayBuffer> }
    ).arrayBuffer();
    return new TextDecoder().decode(new Uint8Array(arrayBuffer));
  }
  return null;
}

/**
 * Opens a websocket and resolves once the connection is ready.
 */
async function connectWebSocket(
  url: string,
  headers: Headers,
  signal: AbortSignal | undefined,
) {
  const WebSocketCtor = getWebSocketConstructor();
  const wsHeaders = headersToRecord(headers);

  return await new Promise<WebSocket>((resolve, reject) => {
    let settled = false;
    let socket: WebSocket;

    try {
      socket = new WebSocketCtor(url, { headers: wsHeaders });
    } catch (error) {
      reject(error instanceof Error ? error : new Error(String(error)));
      return;
    }

    const cleanup = () => {
      socket.removeEventListener("open", onOpen);
      socket.removeEventListener("error", onError);
      socket.removeEventListener("close", onClose);
      signal?.removeEventListener("abort", onAbort);
    };

    const onOpen = () => {
      if (settled) {
        return;
      }
      settled = true;
      cleanup();
      resolve(socket);
    };
    const onError = (event: unknown) => {
      if (settled) {
        return;
      }
      settled = true;
      cleanup();
      reject(extractWebSocketError(event));
    };
    const onClose = (event: unknown) => {
      if (settled) {
        return;
      }
      settled = true;
      cleanup();
      reject(extractWebSocketCloseError(event));
    };
    const onAbort = () => {
      if (settled) {
        return;
      }
      settled = true;
      cleanup();
      try {
        socket.close(1000, "aborted");
      } catch {}
      reject(new Error("Request was aborted"));
    };

    socket.addEventListener("open", onOpen);
    socket.addEventListener("error", onError);
    socket.addEventListener("close", onClose);
    signal?.addEventListener("abort", onAbort);
  });
}

/**
 * Parses Codex websocket events into a JSON event stream.
 */
async function* parseWebSocket(socket: WebSocket, signal?: AbortSignal) {
  const queue: any[] = [];
  let pending: (() => void) | null = null;
  let done = false;
  let failed: Error | null = null;
  let sawCompletion = false;

  const wake = () => {
    if (!pending) {
      return;
    }
    const resolve = pending;
    pending = null;
    resolve();
  };

  const onMessage = (event: unknown) => {
    void (async () => {
      if (!event || typeof event !== "object" || !("data" in event)) {
        return;
      }
      const text = await decodeWebSocketData((event as { data: unknown }).data);
      if (!text) {
        return;
      }

      try {
        const parsed = JSON.parse(text);
        const type = typeof parsed?.type === "string" ? parsed.type : "";
        if (
          type === "response.completed" ||
          type === "response.done" ||
          type === "response.incomplete"
        ) {
          sawCompletion = true;
          done = true;
        }
        queue.push(parsed);
        wake();
      } catch {}
    })();
  };

  const onError = (event: unknown) => {
    failed = extractWebSocketError(event);
    done = true;
    wake();
  };
  const onClose = (event: unknown) => {
    if (sawCompletion) {
      done = true;
      wake();
      return;
    }
    if (!failed) {
      failed = extractWebSocketCloseError(event);
    }
    done = true;
    wake();
  };
  const onAbort = () => {
    failed = new Error("Request was aborted");
    done = true;
    wake();
  };

  socket.addEventListener("message", onMessage);
  socket.addEventListener("error", onError);
  socket.addEventListener("close", onClose);
  signal?.addEventListener("abort", onAbort);

  try {
    while (true) {
      if (signal?.aborted) {
        throw new Error("Request was aborted");
      }
      if (queue.length > 0) {
        yield queue.shift();
        continue;
      }
      if (done) {
        break;
      }
      await new Promise<void>((resolve) => {
        pending = resolve;
      });
    }

    if (failed) {
      throw failed;
    }
    if (!sawCompletion) {
      throw new Error("WebSocket stream closed before response.completed");
    }
  } finally {
    socket.removeEventListener("message", onMessage);
    socket.removeEventListener("error", onError);
    socket.removeEventListener("close", onClose);
    signal?.removeEventListener("abort", onAbort);
  }
}

/**
 * Parses server-sent events from the Codex HTTP transport.
 */
async function* parseSse(response: Response) {
  if (!response.body) {
    return;
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        break;
      }

      buffer += decoder.decode(value, { stream: true });
      let idx = buffer.indexOf("\n\n");
      while (idx !== -1) {
        const chunk = buffer.slice(0, idx);
        buffer = buffer.slice(idx + 2);

        const dataLines = chunk
          .split("\n")
          .filter((line) => line.startsWith("data:"))
          .map((line) => line.slice(5).trim());

        if (dataLines.length > 0) {
          const data = dataLines.join("\n").trim();
          if (data && data !== "[DONE]") {
            try {
              yield JSON.parse(data);
            } catch {}
          }
        }

        idx = buffer.indexOf("\n\n");
      }
    }
  } finally {
    try {
      await reader.cancel();
    } catch {}
    try {
      reader.releaseLock();
    } catch {}
  }
}

/**
 * Normalizes Codex transport events into the shape consumed by the shared
 * OpenAI responses stream processor.
 */
async function* mapCodexEvents(events: AsyncIterable<any>) {
  for await (const event of events) {
    const type = typeof event?.type === "string" ? event.type : undefined;
    if (!type) {
      continue;
    }
    if (type === "error") {
      const code = event.code || "";
      const message = event.message || "";
      throw new Error(
        `Codex error: ${message || code || JSON.stringify(event)}`,
      );
    }
    if (type === "response.failed") {
      throw new Error(
        event.response?.error?.message || "Codex response failed",
      );
    }
    if (
      type === "response.done" ||
      type === "response.completed" ||
      type === "response.incomplete"
    ) {
      const response = event.response;
      const normalizedResponse = response
        ? { ...response, status: normalizeCodexStatus(response.status) }
        : response;
      yield {
        ...event,
        type: "response.completed",
        response: normalizedResponse,
      };
      return;
    }
    yield event;
  }
}

/**
 * Filters backend statuses down to the subset recognized by pi-ai types.
 */
function normalizeCodexStatus(status: unknown) {
  if (typeof status !== "string") {
    return undefined;
  }
  return CODEX_RESPONSE_STATUSES.has(status) ? status : undefined;
}

/**
 * Streams one response over websocket transport.
 */
async function processWebSocketStream(
  model: Model<any>,
  body: Record<string, unknown>,
  apiKey: string,
  output: AssistantMessage,
  stream: ReturnType<typeof createAssistantMessageEventStream>,
  options?: SimpleStreamOptions,
) {
  const requestId = options?.sessionId || createRequestId();
  const socket = await connectWebSocket(
    resolveCodexWebSocketUrl(model.baseUrl),
    buildWebSocketHeaders(model, apiKey, options, requestId),
    options?.signal,
  );

  try {
    socket.send(JSON.stringify({ type: "response.create", ...body }));
    stream.push({ type: "start", partial: output });
    await processResponsesStream(
      mapCodexEvents(parseWebSocket(socket, options?.signal)),
      output,
      stream,
      model,
      {},
    );
  } finally {
    try {
      socket.close(1000, "done");
    } catch {}
  }
}

/**
 * Streams one response over SSE transport.
 */
async function processSseStream(
  model: Model<any>,
  body: Record<string, unknown>,
  apiKey: string,
  output: AssistantMessage,
  stream: ReturnType<typeof createAssistantMessageEventStream>,
  options?: SimpleStreamOptions,
) {
  const response = await fetch(resolveCodexUrl(model.baseUrl), {
    method: "POST",
    headers: buildSseHeaders(model, apiKey, options),
    body: JSON.stringify(body),
    signal: options?.signal,
  });

  await options?.onResponse?.(
    {
      status: response.status,
      headers: headersToRecord(response.headers),
    } satisfies ProviderResponse,
    model,
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `HTTP ${response.status}: ${errorText || response.statusText}`,
    );
  }
  if (!response.body) {
    throw new Error("No response body");
  }

  stream.push({ type: "start", partial: output });
  await processResponsesStream(
    mapCodexEvents(parseSse(response)),
    output,
    stream,
    model,
    {},
  );
}

/**
 * Implements pi's `streamSimple` provider API for the Codex load balancer.
 */
function streamCodexLb(
  model: Model<any>,
  context: Context,
  options?: SimpleStreamOptions,
) {
  const stream = createAssistantMessageEventStream();

  (async () => {
    const output: AssistantMessage = {
      role: "assistant",
      content: [],
      api: model.api,
      provider: model.provider,
      model: model.id,
      usage: {
        input: 0,
        output: 0,
        cacheRead: 0,
        cacheWrite: 0,
        totalTokens: 0,
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
      },
      stopReason: "stop",
      timestamp: Date.now(),
    };

    try {
      const apiKey = options?.apiKey || getEnvApiKey(model.provider) || "";
      if (!apiKey) {
        throw new Error(`No API key for provider: ${model.provider}`);
      }

      let body = buildRequestBody(model, context, options);
      const nextBody = await options?.onPayload?.(body, model);
      if (nextBody !== undefined) {
        body = nextBody as Record<string, unknown>;
      }

      const transport = options?.transport || "sse";
      if (transport !== "sse") {
        try {
          await processWebSocketStream(
            model,
            body,
            apiKey,
            output,
            stream,
            options,
          );
        } catch (error) {
          if (transport === "websocket") {
            throw error;
          }
          await processSseStream(model, body, apiKey, output, stream, options);
        }
      } else {
        await processSseStream(model, body, apiKey, output, stream, options);
      }

      if (options?.signal?.aborted) {
        throw new Error("Request was aborted");
      }

      stream.push({
        type: "done",
        reason: getDoneReason(output.stopReason),
        message: output,
      });
      stream.end();
    } catch (error) {
      for (const block of output.content) {
        delete (block as { index?: number }).index;
        delete (block as { partialJson?: string }).partialJson;
      }
      output.stopReason = options?.signal?.aborted ? "aborted" : "error";
      output.errorMessage =
        error instanceof Error ? error.message : JSON.stringify(error);
      stream.push({ type: "error", reason: output.stopReason, error: output });
      stream.end();
    }
  })();

  return stream;
}

/**
 * Registers the Codex load-balancer provider and its supported models.
 */
export default function codexLbExtension(pi: ExtensionAPI) {
  pi.registerProvider("codex-lb", {
    baseUrl: BASE_URL,
    apiKey: "CODEX_LB_API_KEY",
    api: API_ID,
    streamSimple: streamCodexLb,
    models: [
      {
        id: "gpt-5.5",
        name: "GPT-5.5",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 250000,
        maxTokens: 128000,
        compat: {
          supportsReasoningEffort: true,
          reasoningEffortMap: {
            minimal: "low",
            low: "low",
            medium: "medium",
            high: "high",
            xhigh: "xhigh",
          },
        },
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 250000,
        maxTokens: 128000,
        compat: {
          supportsReasoningEffort: true,
          reasoningEffortMap: {
            minimal: "low",
            low: "low",
            medium: "medium",
            high: "high",
            xhigh: "xhigh",
          },
        },
      },
      {
        id: "gpt-5.4-mini",
        name: "GPT-5.4 mini",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 250000,
        maxTokens: 128000,
        compat: {
          supportsReasoningEffort: true,
          reasoningEffortMap: {
            minimal: "low",
            low: "low",
            medium: "medium",
            high: "high",
            xhigh: "xhigh",
          },
        },
      },
    ],
  });
}
