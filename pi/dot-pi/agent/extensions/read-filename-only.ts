/**
 * Module summary: currently a no-op placeholder extension. The commented-out
 * example below shows an intended `read` tool UI override that would display
 * only the filename/path by default and hide read output unless expanded.
 */
// import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
// import { createReadToolDefinition } from "@mariozechner/pi-coding-agent";
// import { Text } from "@mariozechner/pi-tui";
// import { relative, resolve } from "node:path";
//
// /**
//  * Example read override that shows only the filename unless expanded.
//  */
// export default function readFilenameOnlyExtension(pi: ExtensionAPI) {
//   const cwd = process.cwd();
//   const originalRead = createReadToolDefinition(cwd);
//
//   pi.registerTool({
//     name: "read",
//     label: originalRead.label,
//     description: originalRead.description,
//     promptSnippet: originalRead.promptSnippet,
//     promptGuidelines: originalRead.promptGuidelines,
//     parameters: originalRead.parameters,
//
//     /** Delegates execution to the built-in read tool. */
//     async execute(toolCallId, params, signal, onUpdate, ctx) {
//       return originalRead.execute(toolCallId, params, signal, onUpdate, ctx);
//     },
//
//     /** Shows a relative path summary for the read call. */
//     renderCall(args, theme) {
//       const relPath = args.path
//         ? relative(cwd, resolve(cwd, args.path)) || "."
//         : "...";
//       return new Text(
//         `${theme.fg("toolTitle", theme.bold("read"))} ${theme.fg("accent", relPath)}`,
//         0,
//         0,
//       );
//     },
//
//     /** Hides read output unless the tool row is expanded. */
//     renderResult(result, options, theme, context) {
//       if (options.expanded) {
//         return (
//           originalRead.renderResult?.(result, options, theme, context) ??
//           new Text("", 0, 0)
//         );
//       }
//       return new Text("", 0, 0);
//     },
//   });
// }

/**
 * Placeholder extension. The real read override is kept commented out for now.
 */
export default function readFilenameOnlyExtension(_args: unknown) {}
