# compare-figma-to-impl

> **Alpha** — This skill works but setup and configuration docs are incomplete. If you're interested in trying it, expect some rough edges getting the MCP servers connected and configured. Better install/usage instructions are coming.

A Claude Code skill that systematically compares a Figma design to a live browser implementation, producing a structured report with side-by-side screenshots and classified discrepancies.

Give it a Figma URL and a running UI in Firefox, and it extracts layout, typography, colors, icons, and effects from both sides, then reports what matches, what's close, and what's wrong. See example reports for a [toolbar button](evals/samples/simple-toolbar-button/report.md) and a [smartbar dropdown](evals/samples/aiwindow-smartbar-dropdown/report.md).

## Why this exists

Design-to-implementation fidelity is tedious to verify by hand and easy to get wrong. Engineers squint at screenshots, designers file redline bugs after the fact, and mismatches accumulate. This skill automates the comparison end-to-end: it reads the Figma source of truth, inspects live computed styles via browser devtools, and classifies every difference by severity.

## Use cases

### As spec/acceptance criteria for engineers

Run the comparison *before* you start coding to generate a structured property table (layout, typography, colors, spacing, effects) directly from the Figma source. The output serves as a concrete checklist of what the implementation needs to match — no ambiguity about intended padding, font weight, or gradient stops. Feed the report to an LLM coding agent as acceptance criteria, or use it yourself as a reference while building the component.

### As automated QA after implementation

Run the comparison *after* implementation to catch mismatches before review. The skill classifies each discrepancy as Critical (visually broken), Minor (measurable difference), or Non-issue (numerically different but visually identical). This replaces manual pixel-diffing and catches problems that are easy to miss: wrong icon sources, CSS variables that don't resolve through shadow DOM, border techniques that look similar but use different approaches.

### As a redline tool for designers

Share the generated `comparison/report.md` with designers for review. Each discrepancy includes side-by-side Figma and implementation screenshots cropped to the relevant area, plus exact property values from both sides. Designers can quickly confirm which differences are acceptable and which need fixes — without needing to set up devtools or inspect elements themselves.

## Example output

The report is saved to `comparison/report.md` and includes:

- **Context**: what's being compared (Figma node, live UI element, URLs)
- **Summary of Discrepancies**: classified as Critical / Minor / Non-issue, each with a side-by-side screenshot table
- **Layout & Styling**: full property comparison table (flex properties, box model, typography, colors, effects)

See example reports for a [toolbar button](evals/samples/simple-toolbar-button/report.md) and a [smartbar dropdown](evals/samples/aiwindow-smartbar-dropdown/report.md).

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with this plugin installed
- [Figma MCP server](https://github.com/nichochar/figma-mcp) connected, with `FIGMA_TOKEN` set
- [Firefox DevTools MCP server](https://github.com/nichochar/firefox-devtools-mcp) connected
- The target UI visible in a Firefox tab

## Usage

With the prerequisites running, invoke the skill from Claude Code:

```
/compare-figma-to-impl https://www.figma.com/design/FILE_KEY/File-Name?node-id=1-42 to the AI window header 
```
