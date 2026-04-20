/**
 * Module summary: globally hides task-management tool calls in the chat UI by
 * patching the tool execution renderer so task tools produce no rendered rows.
 */
import {
  ToolExecutionComponent,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";

/** Tool names from `@tintinweb/pi-tasks` that should render no chat row. */
const TASK_TOOL_NAMES = new Set([
  "TaskCreate",
  "TaskList",
  "TaskGet",
  "TaskUpdate",
  "TaskOutput",
  "TaskStop",
  "TaskExecute",
]);

/** Guards against patching the interactive tool component more than once. */
const PATCH_FLAG = Symbol.for("hide-task-tools:tool-execution-patched");

/**
 * Patches the interactive tool execution component so task tools return zero
 * rendered lines, including removing the blank spacer line.
 */
export default function hideTaskToolsExtension(_pi: ExtensionAPI) {
  const proto = ToolExecutionComponent.prototype as any;

  if (proto[PATCH_FLAG]) {
    return;
  }

  const originalRender = proto.render;

  proto.render = function patchedRender(this: any, width: number) {
    if (this.toolName && TASK_TOOL_NAMES.has(this.toolName)) {
      return [];
    }
    return originalRender.call(this, width);
  };

  proto[PATCH_FLAG] = true;
}
