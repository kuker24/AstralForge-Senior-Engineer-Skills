---
name: imagegen
description: Generate or edit raster image assets with safe prompts, constraints, review steps, and repository-friendly outputs.
---

# Image Generation

Use this skill when the user needs a new bitmap asset, image variant, edited raster graphic, texture, mockup, transparent-background cutout, or prompt plan for an image generation API. It is best for visual assets where a raster output is more appropriate than SVG, HTML/CSS, canvas code, or a native design-system component.

Do not use this skill for copying living artists, reproducing protected logos without permission, editing private or sensitive images without consent, or tasks better solved by vector or code-native assets. If the repository already has an icon or illustration system, extend that system rather than introducing inconsistent art.

## Workflow

1. Clarify target dimensions, file type, background, style constraints, brand rules, and intended use.
2. Convert the request into a safe prompt that describes composition, lighting, materials, mood, and negative constraints.
3. Generate or edit assets only through approved local or configured tools.
4. Inspect the result for artifacts, text rendering errors, unsafe content, and mismatch with requirements.
5. Save outputs under an appropriate assets path with descriptive names.
6. Document generation settings when useful for future variants.

## Output Expectations

Return file paths, dimensions, format, and a short visual QA summary. If a requested style or subject is unsafe, offer an original alternative.

## Quality Notes

Keep prompts specific but not overfit. Avoid hidden API keys in scripts. Do not commit huge binary experiments unless the user asks and the repository accepts such assets.
