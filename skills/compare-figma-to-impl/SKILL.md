---
name: compare-figma-to-impl
description: >
  Compare a Figma design to a live implementation. Produces a structured
  comparison report with screenshots saved to disk. Trigger phrases:
  "compare to Figma", "compare to the design", "compare to the mock",
  "visual comparison", "check against Figma", "match the mock",
  "design diff", or a Figma URL with a request to inspect or match a
  UI element.
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
- `FIGMA_TOKEN` must be set in the environment (see `.env.sample`)
- The target UI must be visible in Firefox (run prerequisite skills like
  `/open-ai-window` or `/open-smartbar-dropdown` first if needed)
- The correct chrome context must be selected

## Workflow

### Phase 1: Gather Figma Spec

1. Call `mcp__plugin_figma_figma__get_screenshot` to capture the
   design visually. Always do this — it's the ground truth for your
   own visual analysis.
2. Download the Figma screenshot to disk using the **Figma REST API**
   so it can be embedded in the report. Parse `fileKey` and `nodeId`
   from the Figma URL, then run:
   ```bash
   source .env 2>/dev/null
   mkdir -p comparison
   IMG_URL=$(curl -sH "X-Figma-Token: $FIGMA_TOKEN" \
     "https://api.figma.com/v1/images/${FILE_KEY}?ids=${NODE_ID}&format=png&scale=2&contents_only=false" \
     | python3 -c "import sys,json; print(list(json.load(sys.stdin)['images'].values())[0])")
   if [ -z "$IMG_URL" ] || ! echo "$IMG_URL" | grep -q '^http'; then
     echo "FATAL: Figma API returned an invalid response. The FIGMA_TOKEN is likely expired or invalid." >&2
     echo "Fix: (1) Generate a new token at https://www.figma.com/developers/api#access-tokens" >&2
     echo "     (2) Set it in your environment or .env file" >&2
     echo "     (3) Re-run the comparison" >&2
     exit 1
   fi
   curl -sL -o comparison/figma-screenshot.png "$IMG_URL"
   ```
   Note: convert `node-id` URL param format (`1-42`) to API format
   (`1:42`) by replacing `-` with `:`.

   **Run this script exactly as written — do not rewrite or simplify it.**
   The error guard must execute so the user sees actionable fix steps.

   **If this command exits non-zero, STOP.** Do not proceed to Phase 2.
   Do not continue without `comparison/figma-screenshot.png` on disk.
   Report the following to the user and end the comparison:

   > The FIGMA_TOKEN is expired or invalid.
   > Fix: (1) Generate a new token at https://www.figma.com/developers/api#access-tokens
   >      (2) Set it in your environment or .env file
   >      (3) Re-run the comparison
3. Call `mcp__plugin_figma_figma__get_design_context` with
   `forceCode: true` to get the generated code and style tokens.
4. Extract from the Figma output:
   - Layout: flex direction, alignment, gap, padding
   - Dimensions: widths, heights, border-radius
   - Typography: font-family, size, weight, line-height, color
   - Colors: backgrounds, gradients, borders, shadows
   - Icons: type, size, position
   - The style token annotations (e.g. `NEW/Font/Size/Large/bold`)
5. **Record sub-node IDs**: From the `get_design_context` response, note
   the Figma node ID for each distinct child element (icon, title text,
   button, separator, description text, etc.). These IDs are needed in
   Phase 5 to capture focused per-discrepancy Figma screenshots. Store
   them as a mapping of element label → node ID (e.g. `icon → 1:234`,
   `title → 1:235`).

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
`mcp__firefox-devtools__screenshot_by_uid` in Phase 2), save the
implementation screenshot to `comparison/impl-screenshot.png`, then
**compare them visually before proceeding to numerical comparison**.

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

#### Section: Layout & Styling
Compare ALL visual properties in a single section. Cover:
- Overall container type and flex properties
- Element hierarchy and nesting
- Icon position and rendering technique
- Separator/divider approach
- Interactive elements (buttons, dropdowns)
- Background (gradient angle, stops, colors)
- Border (technique, color, width, radius)
- Padding and spacing (map to design tokens where possible)
- Typography (family, size, weight, line-height, color, overflow)
- Icons and images (source, dimensions, fill color)
- Shadows and effects

Do NOT create a separate "Styling Details" section — merge all styling
comparisons into this Layout & Styling section.

### Phase 4: Classify Discrepancies

Categorize each difference into one of three buckets:

1. **Critical** — Visually broken or functionally wrong (e.g. icon not
   rendering, element missing, layout completely different)
2. **Minor** — Measurable difference from the design that a careful eye
   would notice (e.g. 4px vs 8px padding, wrong font weight)
3. **Non-issue** — Numerically different but visually identical (e.g.
   `border-radius: 9999px` vs `24px` when both produce a pill at that
   height; `box-shadow` vs `border` producing the same visual)

### Phase 5: Capture Per-Discrepancy Screenshots

For each discrepancy identified in Phase 4, capture a focused screenshot
of the relevant area from both Figma and the implementation.

#### Figma side

- If the discrepancy maps to a distinct child node (e.g. icon, title
  text), use `mcp__plugin_figma_figma__get_screenshot` targeting that
  node's ID (recorded in Phase 1 step 5).
- If the discrepancy is a property of the container (border, shadow,
  padding) with no distinct sub-node, screenshot the container node at
  higher scale (e.g. `scale=4`) for a zoomed view that better shows
  the detail.
- Download each screenshot via the Figma REST API using the node's ID,
  same pattern as Phase 1 step 2 (replace `NODE_ID` with the specific
  node, keep the same `FILE_KEY`).
- Save as `comparison/figma-{slug}.png` where `{slug}` is a short
  kebab-case label derived from the discrepancy (e.g. `border-color`,
  `icon-size`, `title-font`).

#### Implementation side

- Take a fresh `mcp__firefox-devtools__take_snapshot` — the Phase 2
  snapshot may no longer be in scope and `screenshot_by_uid` requires
  current UIDs.
- Use `mcp__firefox-devtools__screenshot_by_uid` with the `saveTo`
  parameter targeting the specific DOM element involved in the
  discrepancy.
- Save as `comparison/impl-{slug}.png` using the same slug as the
  Figma side.
- For discrepancies about CSS properties without a clear element
  boundary (border, shadow, gradient), use `screenshot_by_uid` on the
  nearest parent element that visually shows the effect.

#### Filename convention

- Each discrepancy must have a unique slug.
- Use descriptive slugs derived from the discrepancy description
  (e.g. `border-color`, `icon-size`, `title-font-weight`).
- The full overview screenshots (`figma-screenshot.png` /
  `impl-screenshot.png`) remain unchanged — they are still used in
  Phase 2.5.

### Phase 6: Self-Check

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

**CRITICAL**: You MUST save the report to a file — do not just print it
to the conversation. After completing the analysis, use the Write tool to
save the full report to `comparison/report.md` (create the `comparison/`
directory first with `mkdir -p comparison` if needed). Then briefly
summarize the findings in the conversation and tell the user the report
was saved.

The report must be a structured markdown document using these exact
section headers (as markdown ## headings):

## Context
What's being compared — the Figma node, the live UI element, and any
relevant URLs or selectors.


## Summary of Discrepancies
Categorize each finding as Critical, Minor, or Non-issue under
`### Critical`, `### Minor`, and `### Non-issue` sub-headings.

Each individual discrepancy must have its own screenshot table showing
the relevant area, with the Figma crop on the left and implementation
crop on the right. Use unique filenames per discrepancy:

```
1. **Border color mismatch**: Description of the issue...

| Figma | Implementation |
|:---:|:---:|
| ![Figma border comparison](figma-border-color.png) | ![Implementation border comparison](impl-border-color.png) |
```

Every severity level (Critical, Minor, Non-issue) gets screenshot
tables. Sections with no discrepancies should contain only "None.".

If the user asks for a plan to fix, add a Changes section with specific
file paths, line numbers, and code snippets using design tokens where
available.

## Layout & Styling
Table(s) comparing all visual properties — layout (dimensions, spacing,
positioning, flex/grid), styling (colors, borders, typography, shadows,
opacity) — between Figma and implementation.

## Additional Resources

- **`references/comparison-checklist.md`** — Full property checklist and
  reusable chrome script patterns for extracting computed styles
