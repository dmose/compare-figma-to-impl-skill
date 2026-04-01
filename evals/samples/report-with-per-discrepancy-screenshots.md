# Figma vs Implementation Comparison: AI Window Header

## Context
Comparing the AI Window header bar in Figma design (file `abc123`, node `1:42`)
against the live Firefox implementation at `browser.xhtml > ai-window`.

## Summary of Discrepancies

### Critical
None.

### Minor
1. **Border color mismatch**: Figma uses `#E0E0E6` (solid hex), implementation uses
   `rgba(0,0,0,0.1)`. Visually very similar on white background but technically different
   approaches.

| Figma | Implementation |
|:---:|:---:|
| ![Figma border comparison](figma-border-color.png) | ![Implementation border comparison](impl-border-color.png) |

### Non-issue
1. **Font family**: Figma shows `system-ui`, implementation uses `-apple-system, BlinkMacSystemFont`
   — these resolve to the same font on macOS.

| Figma | Implementation |
|:---:|:---:|
| ![Figma font comparison](figma-font-family.png) | ![Implementation font comparison](impl-font-family.png) |

2. **Title color**: `#15141A` vs `rgb(21, 20, 26)` — identical values, different notation.

| Figma | Implementation |
|:---:|:---:|
| ![Figma title color](figma-title-color.png) | ![Implementation title color](impl-title-color.png) |

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
| Title font-size | 15px | 15px | Yes |
| Title font-weight | 600 | 600 | Yes |
| Title color | #15141A | rgb(21, 20, 26) | Yes |
