# UI/UX Quality Checklist

Use this checklist before delivering frontend UI work.

## Accessibility
- Normal text contrast meets WCAG AA target of 4.5:1; large text and UI boundaries remain legible in both light and dark modes.
- Every interactive element is keyboard reachable and has a visible focus state.
- Icon-only buttons have accessible names; meaningful images have alt text; decorative images are hidden from assistive tech.
- Forms use labels, inline error text, clear validation states, and do not rely on color alone.
- Motion respects `prefers-reduced-motion`; essential information is not conveyed only through animation.

## Interaction and Touch
- Primary tap/click targets are at least 44x44 CSS px or have equivalent spacing.
- Buttons show loading/disabled states during async actions.
- Hover states do not cause layout shift; cursor and affordance clearly indicate clickability.
- Destructive or high-impact actions have confirmation, undo, or clear recovery where appropriate.

## Layout and Responsive Behavior
- Verify at common widths: 375px, 768px, 1024px, and 1440px.
- No unexpected horizontal scroll on mobile.
- Fixed/floating navigation does not cover content and has safe-area/edge spacing.
- Text line length is comfortable, generally 45-75 characters for body content.
- Empty, loading, error, and long-content states are intentionally designed.

## Visual System
- Use a clear hierarchy: display, heading, body, metadata, action labels.
- Use consistent icon family, stroke width, corner radius, spacing scale, shadow style, and z-index scale.
- Avoid emoji as production UI icons; prefer SVG icon systems such as Lucide, Heroicons, or verified brand SVGs.
- Use CSS variables or tokens for colors, typography, spacing, radii, shadows, and motion timings.

## Performance
- Prefer transform/opacity animations over layout-affecting properties.
- Reserve space for images and async content to avoid layout shift.
- Use modern image formats, responsive sizes, lazy loading where appropriate, and avoid shipping unused decorative assets.
- Keep third-party scripts, heavy animation libraries, and custom fonts intentional and measured.

## Pre-delivery Checks
- [ ] Works with keyboard only
- [ ] Light/dark contrast checked if both modes exist
- [ ] Responsive at mobile/tablet/desktop sizes
- [ ] Loading/error/empty states covered
- [ ] No generic placeholder content, broken icons, or layout-shifting hover effects
- [ ] Implementation matches the chosen aesthetic direction, not a generic template
