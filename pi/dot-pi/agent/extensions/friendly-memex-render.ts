import {
  ToolExecutionComponent,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { Container, Spacer, Text } from "@mariozechner/pi-tui";

/** Guards against applying the same prototype patch multiple times. */
const PATCH_FLAG = Symbol.for("friendly-memex-render:patched");

/** Friendly collapsed labels for memex tools. */
const PRETTY_LABELS = new Map<string, string>([
  ["memex_recall", "Checking memory"],
  ["memex_search", "Searching memory"],
  ["memex_read", "Reading memory"],
  ["memex_retro", "Updating memory"],
  ["memex_write", "Updating memory"],
  ["memex_links", "Checking memory links"],
  ["memex_archive", "Archiving memory"],
  ["memex_organize", "Organizing memory"],
]);

/** Returns whether the tool should receive the custom memex rendering. */
function isMemexTool(name: unknown): name is string {
  return typeof name === "string" && PRETTY_LABELS.has(name);
}

/** Adds a tiny useful argument summary to the collapsed label. */
function summarizeArgs(toolName: string, args: any): string {
  switch (toolName) {
    case "memex_recall":
    case "memex_search":
      return args?.query ? ` — ${args.query}` : "";

    case "memex_read":
    case "memex_write":
    case "memex_retro":
    case "memex_links":
    case "memex_archive":
      return args?.slug ? ` — ${args.slug}` : "";

    case "memex_organize":
      return args?.since ? ` — since ${args.since}` : "";

    default:
      return "";
  }
}

/** Returns the pretty single-line collapsed text for a memex tool call. */
function formatPrettyCall(toolName: string, args: any): string {
  const pretty = PRETTY_LABELS.get(toolName) ?? toolName;
  const details = summarizeArgs(toolName, args);
  const text = `${pretty}${details}`;
  return text.endsWith("...") ? text : `${text}...`;
}

/**
 * Makes memex tool rows look like thinking when collapsed:
 * - no tool box shell
 * - italic thinkingText single line
 * - hidden result body
 * Expanded mode falls back to Pi's normal tool rendering.
 */
export default function friendlyMemexRenderExtension(_pi: ExtensionAPI) {
  const proto = ToolExecutionComponent.prototype as any;

  if (proto[PATCH_FLAG]) {
    return;
  }

  const originalGetRenderShell = proto.getRenderShell;
  const originalGetCallRenderer = proto.getCallRenderer;
  const originalGetResultRenderer = proto.getResultRenderer;
  const originalRender = proto.render;

  proto.getRenderShell = function patchedGetRenderShell(this: any) {
    if (isMemexTool(this.toolName) && !this.expanded) {
      return "self";
    }

    return originalGetRenderShell.call(this);
  };

  proto.getCallRenderer = function patchedGetCallRenderer(this: any) {
    if (!isMemexTool(this.toolName) || this.expanded) {
      return originalGetCallRenderer.call(this);
    }

    return (_args: any, theme: any) => {
      const container = new Container();
      container.addChild(new Spacer(1));
      container.addChild(
        new Text(
          theme.italic(
            theme.fg(
              "thinkingText",
              formatPrettyCall(this.toolName, this.args),
            ),
          ),
          1,
          0,
        ),
      );
      return container;
    };
  };

  proto.getResultRenderer = function patchedGetResultRenderer(this: any) {
    if (!isMemexTool(this.toolName) || this.expanded) {
      return originalGetResultRenderer.call(this);
    }

    return () => new Text("", 0, 0);
  };

  proto.render = function patchedRender(this: any, width: number) {
    const lines = originalRender.call(this, width);

    if (!isMemexTool(this.toolName) || this.expanded || !Array.isArray(lines)) {
      return lines;
    }

    if (lines[0] === "") {
      return lines.slice(1);
    }

    return lines;
  };

  proto[PATCH_FLAG] = true;
}
