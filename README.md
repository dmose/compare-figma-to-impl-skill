# compare-figma-to-impl

**Stop squinting at Figma and your browser. Diff it.**

Figma says "Semibold." Is that `font-weight: 500`? `590`? `600`? Now multiply that question by every padding, color, gradient stop, and shadow on the component. This skill answers all of them at once.

Give it a Figma URL and a running UI in Firefox, and you get a structured comparison like this:

| Property | Figma | Implementation | Match? |
|---|---|---|---|
| Bold highlight weight | **590** (Semibold) | **700** (Bold) | Different |
| Action text color | `rgba(21,20,26,0.69)` | `rgb(0,0,0)` | Different |
| Button gradient | `linear-gradient(201deg, ...)` | `linear-gradient(235deg, ...)` | Different angle |
| Container border | `1px solid #321bfd` | Gradient border via `::after` | Different |
| Row inner padding | 10px | 7.5px | Different |
| Selected row background | `#efe9ff` | `oklch(0.9 0.13 290)` | Close |
| Border radius | 16px | 16px | Match |

*Excerpt from a [real report](evals/samples/aiwindow-smartbar-dropdown/report.md) — the full comparison found 2 critical, 12 minor, and 8 non-issue discrepancies in a single dropdown component.*

| Figma | Implementation |
|:---:|:---:|
| ![Figma design](evals/samples/aiwindow-smartbar-dropdown/figma-screenshot.png) | ![Live implementation](evals/samples/aiwindow-smartbar-dropdown/impl-screenshot.png) |

### Run it before you write a single line of CSS

The killer use case isn't QA — it's **spec generation**. Run the comparison before you start coding and the output becomes your implementation checklist. Feed it to an LLM coding agent as acceptance criteria, or use it yourself while building the component. No ambiguity about what the design actually specifies.

```
/compare-figma-to-impl https://www.figma.com/design/FILE_KEY/File-Name?node-id=1-42 to the smartbar dropdown
```

Run it after coding and it becomes automated QA — every discrepancy classified as Critical (visually broken), Minor (measurable difference), or Non-issue (numerically different but visually identical). Share the report with designers as a redline — each discrepancy includes side-by-side screenshots and exact values from both sides.

See example reports: [toolbar button](evals/samples/simple-toolbar-button/report.md) | [smartbar dropdown](evals/samples/aiwindow-smartbar-dropdown/report.md)

---

> **Alpha** — This skill works but setup and configuration docs are incomplete. Expect some rough edges getting the MCP servers connected and configured. Better install/usage instructions are coming.

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
