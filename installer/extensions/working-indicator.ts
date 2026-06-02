/**
 * Working Indicator Extension - Neon Tetris Style
 *
 * Shows a colorful Tetris block animation while the agent is working.
 * Uses ANSI escape codes for full HEX color support.
 */

import type { ExtensionAPI, WorkingIndicatorOptions } from "@earendil-works/pi-coding-agent";

// Neon Tetris frames
const TETRIS_FRAMES = [
	'▣□□□□',
	'□▣□□□',
	'□□▣□□',
	'□□□▣□',
	'□□□□▣',
	'▣▣▣▣▣',
	'▰▱▱▱▱',
	'▱▰▱▱▱',
	'▱▱▰▱▱',
	'▱▱▱▰▱',
	'▱▱▱▱▰',
	'▰▰▱▱▱',
	'▱▰▰▱▱',
	'▱▱▰▰▱',
	'▱▱▱▰▰',
	'▰▰▰▰▰',
];

// Neon colors (hex to ANSI)
const NEON_COLORS = [
	'\x1b[38;2;0;212;255m',   // #00D4FF cyan
	'\x1b[38;2;168;85;247m',  // #A855F7 purple
	'\x1b[38;2;255;45;149m',  // #FF2D95 pink
	'\x1b[38;2;0;255;136m',   // #00FF88 green
	'\x1b[38;2;255;209;102m', // #FFD166 yellow
	'\x1b[38;2;255;95;31m',   // #FF5F1F orange
];

const RESET = '\x1b[0m';

function colorize(text: string, color: string): string {
	return `${color}${text}${RESET}`;
}

// Create colored frames - each frame gets a different neon color
const COLORED_FRAMES: string[] = [];
for (let i = 0; i < TETRIS_FRAMES.length; i++) {
	const color = NEON_COLORS[i % NEON_COLORS.length];
	COLORED_FRAMES.push(colorize(TETRIS_FRAMES[i], color));
}

const NEON_TETRIS_INDICATOR: WorkingIndicatorOptions = {
	frames: COLORED_FRAMES,
	intervalMs: 80,
};

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setWorkingIndicator(NEON_TETRIS_INDICATOR);
	});
}
