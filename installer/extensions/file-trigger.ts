/**
 * File Trigger Extension
 *
 * Watches a trigger file and injects its contents into the conversation.
 * Useful for external systems to send messages to the agent.
 *
 * Usage:
 *   echo "Run the tests" > ~/.pi/agent/trigger.txt
 */

import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		// Use permanent location in ~/.pi/agent/ instead of /tmp/
		const triggerFile = path.join(os.homedir(), ".pi", "agent", "trigger.txt");

		// Create the file if it doesn't exist
		try {
			if (!fs.existsSync(triggerFile)) {
				fs.writeFileSync(triggerFile, "", "utf-8");
			}
		} catch (err) {
			console.error("[file-trigger] Error creating trigger file:", err);
			return;
		}

		// Watch the file for changes
		try {
			fs.watch(triggerFile, () => {
				try {
					const content = fs.readFileSync(triggerFile, "utf-8").trim();
					if (content) {
						pi.sendMessage(
							{
								customType: "file-trigger",
								content: `External trigger: ${content}`,
								display: true,
							},
							{ deliverAs: "steer", triggerTurn: true },
						);
						fs.writeFileSync(triggerFile, ""); // Clear after reading
					}
				} catch {
					// File might not exist yet or be locked
				}
			});

			if (ctx.hasUI) {
				ctx.ui.notify(`Watching ${triggerFile}`, "info");
			}
		} catch (err) {
			console.error("[file-trigger] Error watching file:", err);
		}
	});
}
