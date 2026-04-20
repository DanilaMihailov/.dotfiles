/**
 * Deprecated standalone input styling extension.
 *
 * The input styling now lives in:
 *   ~/.pi/agent/extensions/pi-vim-styled/index.ts
 *
 * This file remains as a no-op to avoid competing editor registrations.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function deprecatedInputUserMessageBg(_pi: ExtensionAPI) {}
