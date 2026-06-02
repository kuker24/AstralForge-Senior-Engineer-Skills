/**
 * Custom Footer Extension - Auto-enabled
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					let input = 0,
						output = 0,
						cost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							input += m.usage.input;
							output += m.usage.output;
							cost += m.usage.cost.total;
						}
					}

					const branch = footerData.getGitBranch();
					const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);

					const left = theme.fg("dim", `↑${fmt(input)} ↓${fmt(output)} $${cost.toFixed(3)}`);
					const branchStr = branch ? ` (${branch})` : "";
					const right = theme.fg("dim", `${ctx.model?.id || "no-model"}${branchStr}`);

					const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					return [truncateToWidth(left + pad + right, width)];
				},
			};
		});
	});
}
