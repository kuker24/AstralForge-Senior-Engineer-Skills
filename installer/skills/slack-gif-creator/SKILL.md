---
name: slack-gif-creator
description: Create Slack-optimized animated GIFs with controlled dimensions, loop timing, file size, and validation checks.
---

# Slack GIF Creator

Use this skill when a user asks for an animated GIF intended for Slack, including emoji-like loops, reaction animations, lightweight status graphics, or short playful visuals. Slack GIFs work best when they are readable at small sizes, loop cleanly, and stay within practical file-size limits.

Do not use this skill for long video editing, high-resolution marketing animation, copyrighted character replication, or sensitive workplace imagery. If a static image is better, recommend a PNG or SVG instead.

## Workflow

1. Clarify message, audience, dimensions, duration, loop count, background, and Slack usage context.
2. Design a simple animation concept with strong silhouette and minimal text.
3. Generate frames using deterministic code or approved image tools.
4. Optimize palette, frame count, delay, and dimensions to reduce size.
5. Validate the output by checking playback, loop seam, readability, and file size.
6. Provide the final file path and notes for Slack upload.

## Output Expectations

Return the GIF path, dimensions, duration, frame count, approximate size, and validation result. If the animation includes text, verify it remains legible at Slack display sizes.

## Quality Notes

Avoid flashing patterns that could be unsafe. Do not include real people or brands without permission. Keep intermediate frames out of commits unless requested.
