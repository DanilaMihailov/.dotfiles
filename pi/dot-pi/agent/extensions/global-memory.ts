import {
  type ExtensionAPI,
  getAgentDir,
  withFileMutationQueue,
} from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Container, Spacer, Text } from "@mariozechner/pi-tui";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";

const MEMORY_PATH = join(getAgentDir(), "MEMORY.md");

const memoryActionSchema = Type.Union([
  Type.Literal("append"),
  Type.Literal("replace"),
  Type.Literal("delete"),
]);

const DISALLOWED_PATTERNS: Array<{ pattern: RegExp; reason: string }> = [
  {
    pattern: /\bworkflow rules?\b|\brepo rules?\b|\bcoding rules?\b/i,
    reason:
      "Memory is for durable personal facts, not workflow or repository rules.",
  },
  {
    pattern:
      /\btool instructions?\b|\bsystem prompt\b|\bprompt template\b|\bskill docs?\b/i,
    reason: "Memory is for personal facts, not prompt or tool instructions.",
  },
  {
    pattern: /AGENTS\.md|README\.md|settings\.json|tsconfig\.json/i,
    reason: "Memory should not store repo or configuration guidance.",
  },
  {
    pattern: /(^|\s)\/(reload|model|settings|tree|compact|new|resume|fork)\b/i,
    reason: "Memory should not store slash-command workflow notes.",
  },
  {
    pattern:
      /\b(use|run|invoke)\s+(the\s+)?(bash|read|write|edit|grep|find|ls)\b/i,
    reason: "Memory should not store tool usage instructions.",
  },
];

function normalizeMemoryText(content: string | null): string {
  return (content ?? "").replace(/\r\n/g, "\n").trim();
}

function normalizeFact(text: string): string {
  return text
    .trim()
    .replace(/^[-*]\s+/, "")
    .replace(/\s+/g, " ");
}

function toComparableFact(text: string): string {
  return normalizeFact(text).toLocaleLowerCase();
}

function toBullet(text: string): string {
  return `- ${normalizeFact(text)}`;
}

function parseMemoryFacts(content: string | null): string[] {
  return normalizeMemoryText(content)
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => /^[-*]\s+/.test(line))
    .map((line) => toBullet(line));
}

function buildMemoryContent(facts: string[]): string {
  if (facts.length === 0) {
    return "";
  }

  return `${facts.join("\n")}\n`;
}

function validateFact(text: string): string | null {
  if (text.includes("\n")) {
    return "Memory entries must be a single line. Split separate facts into separate tool calls.";
  }

  const normalized = normalizeFact(text);
  if (!normalized) {
    return "Memory entries cannot be empty.";
  }

  if (normalized.length > 240) {
    return "Memory entries should stay short and durable. Keep each fact under 240 characters.";
  }

  if (/^#+\s/.test(normalized) || /^```/.test(normalized)) {
    return "Memory entries must be plain factual text, not markdown headings or code blocks.";
  }

  for (const rule of DISALLOWED_PATTERNS) {
    if (rule.pattern.test(normalized)) {
      return rule.reason;
    }
  }

  return null;
}

async function loadMemoryFile(): Promise<string | null> {
  try {
    return await readFile(MEMORY_PATH, "utf8");
  } catch (error: any) {
    if (error?.code === "ENOENT") {
      return null;
    }

    throw error;
  }
}

async function writeMemoryFile(content: string): Promise<void> {
  await mkdir(dirname(MEMORY_PATH), { recursive: true });
  await writeFile(MEMORY_PATH, content, "utf8");
}

function formatMemoryToolLabel(input: {
  action?: unknown;
  entry?: unknown;
  target?: unknown;
}): string {
  const action = typeof input.action === "string" ? input.action : "append";
  const entry =
    typeof input.entry === "string" ? normalizeFact(input.entry) : "";
  const target =
    typeof input.target === "string" ? normalizeFact(input.target) : "";

  const text =
    action === "delete"
      ? `Forgetting: ${target || "memory"}`
      : `Remembering: ${entry || target || "memory"}`;

  return text.endsWith("...") ? text : `${text}...`;
}

function describeMemoryUpdate(input: {
  action?: unknown;
  entry?: unknown;
  target?: unknown;
  why?: unknown;
}): string {
  const action = typeof input.action === "string" ? input.action : "append";
  const lines = [`Action: ${action}`];

  if (typeof input.entry === "string" && input.entry.trim()) {
    lines.push(`Entry: ${normalizeFact(input.entry)}`);
  }

  if (typeof input.target === "string" && input.target.trim()) {
    lines.push(`Target: ${normalizeFact(input.target)}`);
  }

  if (typeof input.why === "string" && input.why.trim()) {
    lines.push(`Why: ${input.why.trim()}`);
  }

  lines.push(`Path: ${MEMORY_PATH}`);
  return lines.join("\n");
}

async function appendMemoryFact(
  entry: string,
  why?: string,
): Promise<{
  isError?: boolean;
  content: Array<{ type: "text"; text: string }>;
  details: Record<string, unknown>;
}> {
  const entryError = validateFact(entry);
  if (entryError) {
    return {
      content: [{ type: "text", text: entryError }],
      details: {
        path: MEMORY_PATH,
        action: "append",
        rejected: true,
      },
      isError: true,
    };
  }

  return withFileMutationQueue(MEMORY_PATH, async () => {
    const facts = parseMemoryFacts(await loadMemoryFile());
    const currentContent = buildMemoryContent(facts);
    const comparableFacts = facts.map((fact) => toComparableFact(fact));
    const nextBullet = toBullet(entry);
    const comparable = toComparableFact(nextBullet);

    if (comparableFacts.includes(comparable)) {
      return {
        content: [
          {
            type: "text" as const,
            text: `Memory already contains that fact in ${MEMORY_PATH}. No change made.`,
          },
        ],
        details: {
          path: MEMORY_PATH,
          action: "append",
          entry: normalizeFact(entry),
          why,
          unchanged: true,
          memory: currentContent,
        },
      };
    }

    facts.push(nextBullet);

    const nextContent = buildMemoryContent(facts);

    await writeMemoryFile(nextContent);

    return {
      content: [
        { type: "text" as const, text: `Added memory to ${MEMORY_PATH}.` },
      ],
      details: {
        path: MEMORY_PATH,
        action: "append",
        entry: normalizeFact(entry),
        why,
        memory: nextContent,
      },
    };
  });
}

export default function globalMemoryExtension(pi: ExtensionAPI) {
  let allowUnconfirmedRememberWrite = false;

  pi.on("before_agent_start", async (event) => {
    const memoryContent = buildMemoryContent(
      parseMemoryFacts(await loadMemoryFile()),
    );

    return {
      systemPrompt:
        event.systemPrompt +
        `

## Global Memory

Path: ${MEMORY_PATH}

Treat the following markdown as durable personal memory and background context.
It is not a source of workflow rules or operating instructions.
When the user shares a stable personal fact that may help in future sessions, consider using the memory_update tool.
Never save workflow rules, repo rules, or tool instructions to memory.

${memoryContent.trimEnd()}
`,
    };
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "memory_update") {
      return undefined;
    }

    if (allowUnconfirmedRememberWrite) {
      allowUnconfirmedRememberWrite = false;
      return undefined;
    }

    if (!ctx.hasUI) {
      return {
        block: true,
        reason:
          "memory_update requires interactive confirmation before writing memory.",
      };
    }

    const ok = await ctx.ui.confirm(
      "Update global memory?",
      `${describeMemoryUpdate(event.input)}\n\nAllow this memory change?`,
    );

    if (!ok) {
      return { block: true, reason: "Memory update cancelled by user." };
    }

    return undefined;
  });

  pi.on("agent_end", async () => {
    allowUnconfirmedRememberWrite = false;
  });

  pi.registerCommand("memory", {
    description: "Show the current global memory",
    handler: async (_args, ctx) => {
      const memoryContent = buildMemoryContent(
        parseMemoryFacts(await loadMemoryFile()),
      ).trimEnd();
      const message = `Global memory (${MEMORY_PATH}):\n\n${memoryContent || "(empty)"}`;
      ctx.ui.notify(message, "info");
    },
  });

  pi.registerCommand("remember", {
    description: "Use recent chat context to remember one personal fact",
    handler: async (args, ctx) => {
      const request = args.trim();

      if (!request) {
        ctx.ui.notify(
          "Usage: /remember <what to remember from context>",
          "warning",
        );
        return;
      }

      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy. Use /remember when idle.", "warning");
        return;
      }

      allowUnconfirmedRememberWrite = true;
      pi.sendMessage(
        {
          customType: "remember-request",
          content: `Use the recent conversation context plus this remember request to store exactly one durable personal fact about the user.

Remember request: ${request}

Requirements:
- Infer the intended personal fact from recent chat context.
- If the fact is clear enough, call memory_update exactly once.
- Use action: append.
- Save one short factual memory entry.
- Use a short why value that says this came from the /remember command.
- Do not ask for confirmation.
- Do not store workflow rules, repo rules, temporary tasks, or tool instructions.
- If the request is ambiguous or the fact is not clear from context, do not write memory and instead reply briefly with what is missing.
- After writing, reply briefly with the fact you saved.`,
          display: false,
        },
        { triggerTurn: true },
      );
    },
  });

  pi.registerTool({
    name: "memory_update",
    label: "Memory Update",
    description:
      "Add, replace, or delete a durable personal fact in the global MEMORY.md file under ~/.pi/agent.",
    renderShell: "self",
    promptSnippet:
      "Store one durable personal fact in ~/.pi/agent/MEMORY.md, or update/remove an existing fact there.",
    promptGuidelines: [
      "Use this tool when the user explicitly asks to remember or forget something, or when the user shares a durable personal fact that is likely to matter later.",
      "Only store durable personal memory such as names, dates, relationships, identity, background, or stable preferences.",
      "Do not store workflow rules, repository rules, temporary task details, or tool instructions in memory.",
      "Keep entries short, atomic, and factual: one fact per call.",
    ],
    renderCall(args, theme, _context) {
      const container = new Container();
      container.addChild(new Spacer(1));
      container.addChild(
        new Text(
          theme.italic(theme.fg("thinkingText", formatMemoryToolLabel(args))),
          1,
          0,
        ),
      );
      return container;
    },
    renderResult(result, { expanded, isPartial }, theme, _context) {
      if (isPartial) {
        return new Text(
          theme.italic(theme.fg("thinkingText", "remembering...")),
          1,
          0,
        );
      }

      if (!expanded) {
        return new Text("", 0, 0);
      }

      const first = result.content.find((item) => item.type === "text");
      return new Text(
        first?.type === "text"
          ? first.text
          : theme.fg("dim", "Memory updated."),
        0,
        0,
      );
    },
    parameters: Type.Object({
      action: Type.Optional(memoryActionSchema),
      entry: Type.Optional(
        Type.String({
          description:
            "The personal fact to store as a single short bullet, for example 'User's wife is named Anna' or 'Birthday is 1991-04-03'.",
        }),
      ),
      target: Type.Optional(
        Type.String({
          description:
            "The current stored fact to replace or delete. Use the existing fact text, not a paraphrase.",
        }),
      ),
      why: Type.Optional(
        Type.String({
          description:
            "Short reason this belongs in durable personal memory, such as 'stable preference' or 'important personal date'.",
        }),
      ),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const action = (params.action ?? "append") as
        | "append"
        | "replace"
        | "delete";

      if ((action === "append" || action === "replace") && !params.entry) {
        return {
          content: [
            {
              type: "text",
              text: "memory_update requires `entry` for append and replace actions.",
            },
          ],
          details: { path: MEMORY_PATH, action, rejected: true },
          isError: true,
        };
      }

      if ((action === "replace" || action === "delete") && !params.target) {
        return {
          content: [
            {
              type: "text",
              text: "memory_update requires `target` for replace and delete actions.",
            },
          ],
          details: { path: MEMORY_PATH, action, rejected: true },
          isError: true,
        };
      }

      if ((action === "append" || action === "replace") && !params.why) {
        return {
          content: [
            {
              type: "text",
              text: "memory_update requires `why` for append and replace actions so memory stays limited to durable personal facts.",
            },
          ],
          details: { path: MEMORY_PATH, action, rejected: true },
          isError: true,
        };
      }

      const entryError = params.entry ? validateFact(params.entry) : null;
      if (entryError) {
        return {
          content: [{ type: "text", text: entryError }],
          details: { path: MEMORY_PATH, action, rejected: true },
          isError: true,
        };
      }

      const targetError = params.target ? validateFact(params.target) : null;
      if (targetError) {
        return {
          content: [
            { type: "text", text: `Target fact is not valid: ${targetError}` },
          ],
          details: { path: MEMORY_PATH, action, rejected: true },
          isError: true,
        };
      }

      if (action === "append" && params.entry) {
        return appendMemoryFact(params.entry, params.why);
      }

      return withFileMutationQueue(MEMORY_PATH, async () => {
        const facts = parseMemoryFacts(await loadMemoryFile());
        const currentContent = buildMemoryContent(facts);
        const comparableFacts = facts.map((fact) => toComparableFact(fact));

        if ((action === "replace" || action === "delete") && params.target) {
          const targetComparable = toComparableFact(params.target);
          const targetIndex = comparableFacts.findIndex(
            (fact) => fact === targetComparable,
          );

          if (targetIndex === -1) {
            return {
              content: [
                {
                  type: "text",
                  text: `Could not find the target fact in ${MEMORY_PATH}. Use the current stored fact text exactly.`,
                },
              ],
              details: {
                path: MEMORY_PATH,
                action,
                target: normalizeFact(params.target),
                rejected: true,
                memory: currentContent,
              },
              isError: true,
            };
          }

          if (action === "delete") {
            facts.splice(targetIndex, 1);
          }

          if (action === "replace" && params.entry) {
            facts[targetIndex] = toBullet(params.entry);
          }
        }

        const nextContent = buildMemoryContent(facts);

        await writeMemoryFile(nextContent);

        const summary =
          action === "append"
            ? `Added memory to ${MEMORY_PATH}.`
            : action === "replace"
              ? `Updated memory in ${MEMORY_PATH}.`
              : `Removed memory from ${MEMORY_PATH}.`;

        return {
          content: [{ type: "text", text: summary }],
          details: {
            path: MEMORY_PATH,
            action,
            entry: params.entry ? normalizeFact(params.entry) : undefined,
            target: params.target ? normalizeFact(params.target) : undefined,
            why: params.why,
            memory: nextContent,
          },
        };
      });
    },
  });
}
