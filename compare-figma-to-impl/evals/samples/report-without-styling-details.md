# Figma vs Implementation Comparison: AI Window Header

## Context
Comparing the AI Window header bar in Figma design (file `abc123`, node `1:42`)
against the live Firefox implementation at `browser.xhtml > ai-window`.

## Layout & Styling

| Property | Figma | Implementation | Match? |
|----------|-------|----------------|--------|
| Container display | flex | flex | Yes |
| Flex direction | row | row | Yes |
| Align items | center | center | Yes |
| Gap | 8px | 8px | Yes |
| Padding | 12px 16px | 12px 16px | Yes |
| Background | linear-gradient(180deg, #F8F8FA 0%, #F0F0F4 100%) | linear-gradient(180deg, #F8F8FA 0%, #F0F0F4 100%) | Yes |
| Border bottom | 1px solid #E0E0E6 | 1px solid rgba(0,0,0,0.1) | Minor diff |
| Border radius | 8px 8px 0 0 | 8px 8px 0 0 | Yes |
| Child count | 3 (icon, title, close btn) | 3 (icon, title, close btn) | Yes |

### Icon
- Figma: 16x16 SVG, Google logo
- Impl: 16x16 `<img src="chrome://browser/content/search-engine.svg">` (dynamically loaded)
- Opacity: 1.0 / 1.0

### Title
- Font: 15px / 600 / system-ui (Figma) vs -apple-system (impl) — same on macOS
- Color: #15141A (Figma) vs rgb(21, 20, 26) (impl) — identical values
- Line height: 20px / 20px

### Close Button
- Figma: 24x24 circle with X icon
- Impl: `<button class="close-btn">` 24x24 with `::before` pseudo-element for X
- Background: transparent, hover rgba(0,0,0,0.1) — matches

## Summary of Discrepancies

### Critical
None.

### Minor
1. **Border color mismatch**: Figma uses `#E0E0E6` (solid hex), implementation uses
   `rgba(0,0,0,0.1)`. Visually very similar on white background but technically different
   approaches. Implementation uses the design token `--border-color-default`.

### Non-issue
1. **Font family**: Figma shows `system-ui`, implementation uses `-apple-system, BlinkMacSystemFont`
   — these resolve to the same font on macOS.
2. **Title color**: `#15141A` vs `rgb(21, 20, 26)` — identical values, different notation.
