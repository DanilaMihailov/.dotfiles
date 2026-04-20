/**
 * Module summary: replaces Pi's footer with a multi-line status footer that
 * shows cwd, git/session metadata, token and cost usage, context window usage,
 * current model information, extension statuses, and extra footer spacing.
 */
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

/**
 * Flattens extension status text into a single safe footer line.
 */
function sanitizeStatusText(text: string): string {
  return text
    .replace(/[\r\n\t]/g, " ")
    .replace(/ +/g, " ")
    .trim();
}

/**
 * Formats token counts into short human-readable units.
 */
function formatTokens(count: number): string {
  if (count < 1_000) return count.toString();
  if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
  if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
  return `${Math.round(count / 1_000_000)}M`;
}

/**
 * Reads whether auto-compaction is enabled from the global pi settings file.
 */
function isAutoCompactionEnabled(): boolean {
  try {
    const settingsPath = join(homedir(), ".pi", "agent", "settings.json");
    const settings = JSON.parse(readFileSync(settingsPath, "utf8")) as {
      compaction?: { enabled?: boolean };
    };
    return settings.compaction?.enabled ?? true;
  } catch {
    return true;
  }
}

/**
 * Mirrors Pi's editor border color logic for use in the footer.
 */
function getFooterBorderVisual(
  ctx: ExtensionContext,
  theme: Theme,
  pi: ExtensionAPI,
): {
  colorize: (text: string) => string;
  indicator: string;
  isBashMode: boolean;
} {
  const isBashMode = ctx.ui.getEditorText().trimStart().startsWith("!");
  if (isBashMode) {
    return {
      colorize: theme.getBashModeBorderColor(),
      indicator: "bash",
      isBashMode: true,
    };
  }

  const thinkingLevel = pi.getThinkingLevel() || "off";
  return {
    colorize: theme.getThinkingBorderColor(thinkingLevel),
    indicator: thinkingLevel === "off" ? "thinking off" : thinkingLevel,
    isBashMode: false,
  };
}

/**
 * Installs a compact multi-line footer with cwd, model, usage, and context stats.
 */
export default function footerSpacingExtension(pi: ExtensionAPI) {
  let installedSessionId: string | undefined;
  let currentModel: ExtensionContext["model"];

  /**
   * Registers the footer once per session and keeps the current model cached.
   */
  const installFooter = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;

    const sessionId = ctx.sessionManager.getSessionId();
    currentModel = ctx.model;
    if (installedSessionId === sessionId) return;
    installedSessionId = sessionId;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const model = currentModel ?? ctx.model;
          const footerBorderVisual = getFooterBorderVisual(ctx, theme, pi);
          let totalInput = 0;
          let totalOutput = 0;
          let totalCacheRead = 0;
          let totalCacheWrite = 0;
          let totalCost = 0;

          for (const entry of ctx.sessionManager.getEntries()) {
            if (
              entry.type === "message" &&
              entry.message.role === "assistant"
            ) {
              totalInput += entry.message.usage.input;
              totalOutput += entry.message.usage.output;
              totalCacheRead += entry.message.usage.cacheRead;
              totalCacheWrite += entry.message.usage.cacheWrite;
              totalCost += entry.message.usage.cost.total;
            }
          }

          const contextUsage = ctx.getContextUsage();
          const contextWindow =
            contextUsage?.contextWindow ?? model?.contextWindow ?? 0;
          const contextPercentValue = contextUsage?.percent ?? 0;
          const contextPercent =
            contextUsage?.percent !== null
              ? contextPercentValue.toFixed(1)
              : "?";

          let pwd = ctx.sessionManager.getCwd();
          const home = process.env.HOME || process.env.USERPROFILE;
          if (home && pwd.startsWith(home)) {
            pwd = `~${pwd.slice(home.length)}`;
          }

          const branch = footerData.getGitBranch();
          if (branch) {
            pwd = `${pwd} (${branch})`;
          }

          const sessionName = ctx.sessionManager.getSessionName();
          if (sessionName) {
            pwd = `${pwd} • ${sessionName}`;
          }

          const statsParts: string[] = [];
          if (totalInput) statsParts.push(`↑${formatTokens(totalInput)}`);
          if (totalOutput) statsParts.push(`↓${formatTokens(totalOutput)}`);
          if (totalCacheRead)
            statsParts.push(`R${formatTokens(totalCacheRead)}`);
          if (totalCacheWrite)
            statsParts.push(`W${formatTokens(totalCacheWrite)}`);

          const usingSubscription = model
            ? ctx.modelRegistry.isUsingOAuth(model)
            : false;
          if (totalCost || usingSubscription) {
            statsParts.push(
              `$${totalCost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`,
            );
          }

          const autoIndicator = isAutoCompactionEnabled() ? " (auto)" : "";
          const contextPercentDisplay =
            contextPercent === "?"
              ? `?/${formatTokens(contextWindow)}${autoIndicator}`
              : `${contextPercent}%/${formatTokens(contextWindow)}${autoIndicator}`;

          let contextPercentStr: string;
          if (contextPercentValue > 90) {
            contextPercentStr = theme.fg("error", contextPercentDisplay);
          } else if (contextPercentValue > 70) {
            contextPercentStr = theme.fg("warning", contextPercentDisplay);
          } else {
            contextPercentStr = contextPercentDisplay;
          }
          statsParts.push(contextPercentStr);

          let statsLeft = statsParts.join(" ");
          let statsLeftWidth = visibleWidth(statsLeft);
          if (statsLeftWidth > width) {
            statsLeft = truncateToWidth(statsLeft, width, "...");
            statsLeftWidth = visibleWidth(statsLeft);
          }

          const minPadding = 2;
          const modelName = model?.id || "no-model";
          const dimSeparator = theme.fg("dim", " • ");
          const dimModelName = theme.fg("dim", modelName);

          let rightSideWithoutProvider = dimModelName;
          if (footerBorderVisual.isBashMode) {
            rightSideWithoutProvider = `${dimModelName}${dimSeparator}${footerBorderVisual.colorize("bash")}`;
          } else if (model?.reasoning) {
            rightSideWithoutProvider = `${dimModelName}${dimSeparator}${footerBorderVisual.colorize(footerBorderVisual.indicator)}`;
          }

          let rightSide = rightSideWithoutProvider;
          if (footerData.getAvailableProviderCount() > 1 && model) {
            const providerPrefix = theme.fg("dim", `(${model.provider}) `);
            const withProvider = `${providerPrefix}${rightSideWithoutProvider}`;
            if (
              statsLeftWidth + minPadding + visibleWidth(withProvider) <=
              width
            ) {
              rightSide = withProvider;
            }
          }

          const rightSideWidth = visibleWidth(rightSide);
          const totalNeeded = statsLeftWidth + minPadding + rightSideWidth;
          const dimStatsLeft = theme.fg("dim", statsLeft);
          let statsLine: string;

          if (totalNeeded <= width) {
            const padding = " ".repeat(width - statsLeftWidth - rightSideWidth);
            statsLine = dimStatsLeft + padding + rightSide;
          } else {
            const availableForRight = width - statsLeftWidth - minPadding;
            if (availableForRight > 0) {
              const truncatedRight = truncateToWidth(
                rightSide,
                availableForRight,
                "",
              );
              const truncatedRightWidth = visibleWidth(truncatedRight);
              const padding = " ".repeat(
                Math.max(0, width - statsLeftWidth - truncatedRightWidth),
              );
              statsLine = dimStatsLeft + padding + truncatedRight;
            } else {
              statsLine = dimStatsLeft;
            }
          }

          const separatorLine = footerBorderVisual.colorize("─".repeat(width));
          const pwdLine = truncateToWidth(
            theme.fg("dim", pwd),
            width,
            theme.fg("dim", "..."),
          );
          const lines = [pwdLine, statsLine];

          const extensionStatuses = footerData.getExtensionStatuses();
          if (extensionStatuses.size > 0) {
            const statusLine = Array.from(extensionStatuses.entries())
              .sort(([a], [b]) => a.localeCompare(b))
              .map(([, text]) => sanitizeStatusText(text))
              .join(" ");
            lines.push(
              truncateToWidth(statusLine, width, theme.fg("dim", "...")),
            );
          }

          lines.push("");
          return lines;
        },
      };
    });
  };

  pi.on("session_start", async (_event, ctx) => {
    installFooter(ctx);
  });

  pi.on("input", async (_event, ctx) => {
    installFooter(ctx);
  });

  pi.on("turn_start", async (_event, ctx) => {
    installFooter(ctx);
    currentModel = ctx.model;
  });

  pi.on("turn_end", async (_event, ctx) => {
    currentModel = ctx.model;
  });

  pi.on("model_select", async (_event, ctx) => {
    installFooter(ctx);
    currentModel = ctx.model;
  });
}
