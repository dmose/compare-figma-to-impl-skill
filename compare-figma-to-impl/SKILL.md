---
name: compare-figma-to-impl
description: >
  This skill should be used when the user asks to "compare to Figma",
  "compare to the design", "compare to the mock", "visual comparison",
  "check against Figma", "match the mock", "design diff", or wants to
  systematically compare a live Firefox UI element against a Figma design.
  Also trigger when given a Figma URL alongside a request to inspect or
  match a specific UI element.
context: fork
agent: general-purpose
---

# Compare Figma Design to Live Implementation

Systematically compare a Figma design to a live Firefox implementation
using the Figma MCP and Firefox devtools MCP. Produce a structured
comparison covering layout, structure, and styling.

## Prerequisites

- The Firefox devtools MCP must be connected
- The Figma desktop MCP must be connected
- The target UI must be visible in Firefox (run prerequisite skills like
  `/open-ai-window` or `/open-smartbar-dropdown` first if needed)
- The correct chrome context must be selected

## Workflow

### Phase 1: Gather Figma Spec

1. Call `mcp__plugin_figma_figma-desktop__get_screenshot` to capture the
   design visually. Always do this — it's the ground truth.
2. Call `mcp__plugin_figma_figma-desktop__get_design_context` with
   `forceCode: true` to get the generated code and style tokens.
3. Extract from the Figma output:
   - Layout: flex direction, alignment, gap, padding
   - Dimensions: widths, heights, border-radius
   - Typography: font-family, size, weight, line-height, color
   - Colors: backgrounds, gradients, borders, shadows
   - Icons: type, size, position
   - The style token annotations (e.g. `NEW/Font/Size/Large/bold`)

### Phase 2: Inspect Live Implementation

Use `mcp__firefox-devtools__evaluate_chrome_script` to extract live data.
All scripts must be wrapped in an IIFE: `(function() { ... })()`.

#### Step 2a: Identify the DOM structure

Navigate the DOM to find the target element. For AI window components,
the typical path is:
```
gBrowser.selectedBrowser.contentDocument
  → querySelector('ai-window')
  → .shadowRoot
  → target element (may have its own shadowRoot)
```

Collect: tag names, class names, shadow DOM boundaries, child hierarchy.

**Before extracting computed styles, dump `outerHTML` (truncated) of
each key element** — especially icons, images, and interactive controls.
This reveals the actual element type (is it an `<img src="...">`, a
`<div>` with `background-image`, an inline SVG, etc.) and determines
what to extract in subsequent steps. Without this, scripts that assume
one structure (e.g. `el.querySelector('img')`) will silently fail when
the element IS the `<img>` tag. Example:
```js
el.outerHTML.substring(0, 400)
```

#### Step 2b: Extract computed styles

Use `contentDoc.defaultView.getComputedStyle(el)` to read live values.
Do NOT read source CSS files — use live computed styles only.

Extract these properties for each relevant element (see
`references/comparison-checklist.md` for the full list):
- **Layout**: display, flex-direction, align-items, justify-content, gap
- **Box model**: width, height, padding, margin, border, border-radius
- **Background**: background-image, background-color, background-position/size
- **Typography**: font-size, font-weight, font-family, line-height, color
- **Effects**: box-shadow, opacity, overflow, text-overflow
- **Custom properties**: any `--var` values relevant to the component

Also call `getBoundingClientRect()` on each element for actual pixel
dimensions and positions.

#### Step 2c: Check pseudo-elements

Inspect `::before` and `::after` pseudo-elements — they often implement
separators, icons, or decorative elements:
```js
contentDoc.defaultView.getComputedStyle(el, '::before')
```

#### Step 2d: Check CSS custom property inheritance

When a property uses `var(--foo)`, verify the variable resolves at the
element where it's consumed, not just where it's defined. CSS custom
properties inherit through shadow DOM, but the resolved value may differ
from expectations. Check with:
```js
getComputedStyle(el).getPropertyValue('--foo')
```

#### Step 2e: Extract image and icon attributes

For every element that renders an icon or image, extract HTML attributes
in addition to computed styles. CSS properties alone cannot identify
what image is being displayed when the element is an `<img>` tag.

For each icon/image element, collect:
- `tagName` (is it `img`, `div`, `svg`, etc.?)
- `src` attribute (for `<img>` elements)
- `alt` attribute
- `outerHTML` (truncated to 400 chars)
- `backgroundImage` computed style (for CSS-based icons)
- `-moz-context-properties` and `fill` (for SVG icons styled via CSS)
- `opacity`

See `references/comparison-checklist.md` for a reusable script.

### Phase 2.5: Visual Comparison

After capturing both screenshots (Figma in Phase 1, live page via
`mcp__firefox-devtools__screenshot_page` or
`mcp__firefox-devtools__screenshot_by_uid` in Phase 2), **compare them
visually before proceeding to numerical comparison**.

Look for obvious differences that CSS property extraction might miss:
- Wrong or missing icons (different icon shape, generic fallback)
- Missing or extra UI elements
- Significantly different colors or layout
- Text rendering differences (bold vs normal, truncation)

Note any visual discrepancies found here. They guide where to focus
the detailed numerical comparison in Phase 3, and serve as a safety
net for extraction bugs that silently drop data.

If the full-page screenshot is too large, capture element-level
screenshots using `screenshot_by_uid` for the specific component.

### Phase 3: Systematic Comparison

Produce two comparison sections. Use tables for clarity.

#### Section 1: Layout & Structure
Compare element positions, flow direction, hierarchy, alignment. Cover:
- Overall container type and flex properties
- Element hierarchy and nesting
- Icon position and rendering technique
- Separator/divider approach
- Interactive elements (buttons, dropdowns)

#### Section 2: Styling Details
Compare visual properties. Cover:
- Background (gradient angle, stops, colors)
- Border (technique, color, width, radius)
- Padding and spacing (map to design tokens where possible)
- Typography (family, size, weight, line-height, color, overflow)
- Icons and images (source, dimensions, fill color)
- Shadows and effects

### Phase 4: Classify Discrepancies

Categorize each difference into one of three buckets:

1. **Critical** — Visually broken or functionally wrong (e.g. icon not
   rendering, element missing, layout completely different)
2. **Minor** — Measurable difference from the design that a careful eye
   would notice (e.g. 4px vs 8px padding, wrong font weight)
3. **Non-issue** — Numerically different but visually identical (e.g.
   `border-radius: 9999px` vs `24px` when both produce a pill at that
   height; `box-shadow` vs `border` producing the same visual)

### Phase 5: Self-Check

Before presenting results, review the analysis for common errors:

- **Bare URL values**: If `background-image` is `none` but position/size
  are set, check whether the CSS variable value is missing `url()` wrapping.
  A bare URL string (without `url()`) is NEVER valid for `background-image`.
- **Shadow DOM variable resolution**: Verify that `var(--foo)` actually
  resolves at the consumption site, not just at the definition site.
- **Border-radius equivalence**: At a given height, any radius >= half the
  height produces an identical pill shape. Don't flag these as different.
- **Gradient visual equivalence**: When color stops are far outside 0-100%,
  the visible gradient is a narrow slice — large numerical differences may
  produce imperceptible visual differences.
- **Figma specifics vs implementation generics**: Figma mocks often show a
  specific instance (e.g. "Google" icon) while implementation is generic
  (e.g. dynamically loads the current search engine's icon). Don't flag
  these as mismatches IF the implementation dynamically loads the correct
  contextual icon. DO flag it if the implementation uses a hardcoded
  fallback/generic icon (e.g. `search-glass.svg`) instead of the
  context-appropriate icon (e.g. the configured search engine's favicon).
  Always verify the actual icon `src` — don't assume it's correct just
  because a 16x16 placeholder is rendering.
- **Design tokens**: When flagging a value difference, check whether the
  implementation uses a design token that maps to the correct semantic value,
  even if the pixel value differs slightly from the Figma spec.

## Output Format

Write the comparison as a structured markdown document with:
1. Context section (what's being compared)
2. Layout & Structure table(s)
3. Styling Details table(s)
4. Summary of Discrepancies (Critical / Minor / Non-issue)

If the user asks for a plan to fix, add a Changes section with specific
file paths, line numbers, and code snippets using design tokens where
available.

## Additional Resources

- **`references/comparison-checklist.md`** — Full property checklist and
  reusable chrome script patterns for extracting computed styles
