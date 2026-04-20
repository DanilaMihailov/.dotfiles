/**
 * Module summary: disables Pi's soft cursor rendering by stripping reverse-
 * video cursor markers from editor output and forcing the TUI to use the
 * terminal's hardware cursor, including for custom editor instances.
 */
import { Editor } from "@mariozechner/pi-tui";
import { InteractiveMode } from "@mariozechner/pi-coding-agent";

const REVERSE_ON = "\x1b[7m";
const REVERSE_OFF = "\x1b[0m";

/** Guards against duplicate prototype patches. */
const RENDER_PATCHED = Symbol.for("pi-no-soft-cursor-local.render-patched");
const FACTORY_PATCHED = Symbol.for("pi-no-soft-cursor-local.factory-patched");
const INTERACTIVE_MODE_PATCHED = Symbol.for(
  "pi-no-soft-cursor-local.interactive-mode-patched",
);

/** Shared patch lifecycle so startup and session hooks reuse the same work. */
let patchPromise: Promise<void> | null = null;

/**
 * Removes the soft reverse-video cursor marker from a rendered line.
 */
function stripSoftCursor(line: string): string {
  const revEnd = line.lastIndexOf(REVERSE_OFF);
  if (revEnd === -1) return line;

  const revStart = line.lastIndexOf(REVERSE_ON, revEnd);
  if (revStart === -1) return line;

  const contentStart = revStart + REVERSE_ON.length;
  if (contentStart > revEnd) return line;

  const before = line.slice(0, revStart);
  const content = line.slice(contentStart, revEnd);
  const after = line.slice(revEnd + REVERSE_OFF.length);
  return before + content + after;
}

/**
 * Forces the TUI to prefer the terminal's hardware cursor.
 */
function forceHardwareCursor(editor: any): void {
  editor?.tui?.setShowHardwareCursor?.(true);
}

/**
 * Wraps a renderable so every render strips the soft cursor styling.
 */
function patchRenderable(renderable: any): any {
  if (!renderable?.render || renderable[RENDER_PATCHED]) return renderable;

  const originalRender = renderable.render;
  renderable.render = function patchedRender(this: any, width: number) {
    forceHardwareCursor(this);
    const lines = originalRender.call(this, width);
    return Array.isArray(lines) ? lines.map(stripSoftCursor) : lines;
  };

  renderable[RENDER_PATCHED] = true;
  return renderable;
}

/**
 * Wraps custom editor factories so dynamically created editors are patched too.
 */
function wrapFactory(factory: any): any {
  if (!factory || factory[FACTORY_PATCHED]) return factory;

  const wrappedFactory = (tui: any, theme: any, keybindings: any) => {
    const editor = factory(tui, theme, keybindings);
    return patchRenderable(editor);
  };

  wrappedFactory[FACTORY_PATCHED] = true;
  return wrappedFactory;
}

/**
 * Applies the editor and interactive-mode patches once.
 */
async function ensurePatched(): Promise<void> {
  if (patchPromise) return patchPromise;

  patchPromise = (async () => {
    patchRenderable(Editor.prototype);

    const interactiveModePrototype = InteractiveMode.prototype as any;
    if (!interactiveModePrototype[INTERACTIVE_MODE_PATCHED]) {
      const originalSetCustomEditorComponent =
        interactiveModePrototype.setCustomEditorComponent;

      interactiveModePrototype.setCustomEditorComponent =
        function patchedSetCustomEditorComponent(this: any, factory: any) {
          return originalSetCustomEditorComponent.call(
            this,
            factory ? wrapFactory(factory) : undefined,
          );
        };

      interactiveModePrototype[INTERACTIVE_MODE_PATCHED] = true;
    }
  })().catch((error) => {
    patchPromise = null;
    console.error("[pi-no-soft-cursor-local] failed to patch:", error);
    throw error;
  });

  return patchPromise;
}

void ensurePatched();

/**
 * Keeps the no-soft-cursor patch active for the lifetime of the session.
 */
export default function noSoftCursorLocalExtension(pi: any) {
  void ensurePatched();

  pi.on("session_start", () => {
    void ensurePatched();
  });
}
