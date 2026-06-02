/**
 * Extensions Menu Extension
 *
 * /extensions       - Open main menu
 * /extensions clean - Clean all disabled extensions
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { readdir, rename, stat, unlink, rm, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";

interface ExtensionEntry {
  name: string;
  path: string;
  isDirectory: boolean;
  isEnabled: boolean;
  source: string;
}

export default function extensionsMenuExtension(pi: ExtensionAPI) {
  const HOME = process.env.HOME || "~";
  const EXTENSION_DIRS = [
    { path: resolve(HOME, ".pi/agent/extensions"), label: "Global" },
    { path: resolve(".pi/extensions"), label: "Project" },
  ];

  async function discoverExtensions(): Promise<ExtensionEntry[]> {
    const entries: ExtensionEntry[] = [];
    for (const { path: dir, label } of EXTENSION_DIRS) {
      try {
        const dirStat = await stat(dir);
        if (!dirStat.isDirectory()) continue;
        const files = await readdir(dir, { withFileTypes: true });
        for (const file of files) {
          if (file.name.startsWith(".")) continue;
          const fullPath = join(dir, file.name);
          if (file.isDirectory()) {
            try {
              await stat(join(fullPath, "index.ts"));
              let isEnabled = true;
              try { await stat(join(fullPath, ".disabled")); isEnabled = false; } catch {}
              entries.push({ name: file.name, path: fullPath, isDirectory: true, isEnabled, source: label });
            } catch {}
          } else if (file.name.endsWith(".ts") && !file.name.endsWith(".disabled.ts")) {
            entries.push({ name: file.name.replace(/\.ts$/, ""), path: fullPath, isDirectory: false, isEnabled: true, source: label });
          } else if (file.name.endsWith(".ts.disabled")) {
            entries.push({ name: file.name.replace(/\.ts\.disabled$/, ""), path: fullPath, isDirectory: false, isEnabled: false, source: label });
          }
        }
      } catch {}
    }
    entries.sort((a, b) => {
      if (a.isEnabled !== b.isEnabled) return a.isEnabled ? -1 : 1;
      return a.name.localeCompare(b.name);
    });
    return entries;
  }

  async function toggleExtension(entry: ExtensionEntry): Promise<boolean> {
    try {
      if (entry.isDirectory) {
        const markerPath = join(entry.path, ".disabled");
        if (entry.isEnabled) await writeFile(markerPath, "");
        else { try { await unlink(markerPath); } catch {} }
      } else {
        if (entry.isEnabled) await rename(entry.path, entry.path + ".disabled");
        else await rename(entry.path, entry.path.replace(/\.disabled$/, ""));
      }
      return true;
    } catch {
      return false;
    }
  }

  async function deleteExtension(entry: ExtensionEntry): Promise<boolean> {
    try {
      if (entry.isDirectory) {
        await rm(entry.path, { recursive: true, force: true });
      } else {
        await unlink(entry.path).catch(() => {});
        if (entry.isEnabled) await unlink(entry.path + ".disabled").catch(() => {});
        else await unlink(entry.path.replace(/\.disabled$/, "")).catch(() => {});
      }
      return true;
    } catch {
      return false;
    }
  }

  // ===== MANAGE MODE =====
  async function manageLoop(ctx: ExtensionContext) {
    while (true) {
      const extensions = await discoverExtensions();
      if (extensions.length === 0) {
        ctx.ui.notify("No extensions found", "warning");
        return;
      }

      // Build string array for select()
      const options: string[] = ["🔙 Back"];
      for (const ext of extensions) {
        const icon = ext.isDirectory ? "📁 " : "";
        const status = ext.isEnabled ? "✅ ON " : "⬜ OFF";
        options.push(`${status} ${icon}${ext.name} [${ext.source}]`);
      }

      const choice = await ctx.ui.select("🔧 Manage Extensions:", options);
      if (!choice || choice === "🔙 Back") return;

      // Find the selected extension by matching the label
      const idx = options.indexOf(choice);
      if (idx < 1) continue;
      const ext = extensions[idx - 1]; // -1 because "Back" is at index 0

      if (ext) {
        const success = await toggleExtension(ext);
        if (success) {
          ctx.ui.notify(`${ext.name} ${ext.isEnabled ? "disabled" : "enabled"}`, "info");
        }
      }
    }
  }

  // ===== DELETE MODE =====
  async function deleteLoop(ctx: ExtensionContext) {
    while (true) {
      const extensions = await discoverExtensions();
      if (extensions.length === 0) {
        ctx.ui.notify("No extensions found", "warning");
        return;
      }

      // Build string array for select()
      const options: string[] = ["🔙 Back"];
      for (const ext of extensions) {
        const icon = ext.isDirectory ? "📁 " : "";
        const status = ext.isEnabled ? "✅" : "⬜";
        options.push(`${status} ${icon}${ext.name} [${ext.source}]`);
      }

      const choice = await ctx.ui.select("🗑️ Delete Extension:", options);
      if (!choice || choice === "🔙 Back") return;

      // Find the selected extension
      const idx = options.indexOf(choice);
      if (idx < 1) continue;
      const ext = extensions[idx - 1];

      if (ext) {
        const confirmed = await ctx.ui.confirm(
          "Confirm Delete",
          `Permanently delete "${ext.name}"?\n\nThis cannot be undone!`,
        );
        if (confirmed) {
          const success = await deleteExtension(ext);
          if (success) {
            ctx.ui.notify(`Deleted: ${ext.name}`, "info");
          } else {
            ctx.ui.notify(`Failed to delete: ${ext.name}`, "error");
          }
        }
      }
    }
  }

  // ===== CLEAN MODE =====
  async function cleanMode(ctx: ExtensionContext) {
    const extensions = await discoverExtensions();
    const disabled = extensions.filter(e => !e.isEnabled);

    if (disabled.length === 0) {
      ctx.ui.notify("No disabled extensions to clean", "info");
      return;
    }

    const names = disabled.map(e => `  • ${e.name}`).join("\n");
    const confirmed = await ctx.ui.confirm(
      "🧹 Clean Disabled Extensions",
      `Remove ${disabled.length} disabled extension(s)?\n${names}\n\nThis cannot be undone!`,
    );

    if (confirmed) {
      let deleted = 0;
      for (const ext of disabled) {
        if (await deleteExtension(ext)) deleted++;
      }
      ctx.ui.notify(`Cleaned ${deleted} extension(s)`, "info");
      setTimeout(() => ctx.reload(), 300);
    }
  }

  // ===== MAIN MENU =====
  async function showMainMenu(ctx: ExtensionContext) {
    while (true) {
      const extensions = await discoverExtensions();
      const enabledCount = extensions.filter(e => e.isEnabled).length;
      const disabledCount = extensions.filter(e => !e.isEnabled).length;

      const choice = await ctx.ui.select(
        `📦 Extensions (${extensions.length} total, ${enabledCount} on, ${disabledCount} off):`,
        [
          "🔧 Manage — Enable/Disable extensions",
          "🗑️  Delete — Remove extensions permanently",
          "🧹 Clean — Remove all disabled extensions",
          "🔄 Reload — Apply changes now",
          "❌ Quit",
        ],
      );

      if (!choice || choice.includes("Quit")) return;

      if (choice.includes("Manage")) await manageLoop(ctx);
      else if (choice.includes("Delete")) await deleteLoop(ctx);
      else if (choice.includes("Clean")) await cleanMode(ctx);
      else if (choice.includes("Reload")) {
        ctx.ui.notify("Reloading...", "info");
        setTimeout(() => ctx.reload(), 200);
        return;
      }
    }
  }

  // Register command
  pi.registerCommand("extensions", {
    description: "Manage extensions (enable/disable/delete/clean)",
    getArgumentCompletions: (prefix: string) => {
      const modes = [
        { value: "manage", label: "Enable/Disable extensions" },
        { value: "delete", label: "Delete extensions permanently" },
        { value: "clean", label: "Remove all disabled extensions" },
      ];
      return modes.filter(m => m.value.startsWith(prefix));
    },
    handler: async (args, ctx) => {
      const mode = args?.trim().toLowerCase();
      if (mode === "manage") return manageLoop(ctx);
      if (mode === "delete") return deleteLoop(ctx);
      if (mode === "clean") return cleanMode(ctx);
      await showMainMenu(ctx);
    },
  });
}
