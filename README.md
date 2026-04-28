# compare-figma-to-impl

**Prototype Claude Code plugin for automated UI work breakdown and verification**

_Cutting down the manual squinting & comparing between Firefox and Figma while working on UI code with visual diff reports._

A single dropdown has lots of visual properties. Manually checking each one against Figma is slow, painful and error prone — font weight 700 instead of 590, gradient angle off by 34 degrees, padding short by 2.5px. Claude

Point it at a Figma URL and a running UI in Firefox:

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

### Use it before you code

Run the comparison before you start implementing and the output is your checklist — every property the implementation needs to match, with exact values. Feed it to an LLM coding agent as acceptance criteria, or use it as a reference yourself.

```
/compare-figma-to-impl https://www.figma.com/design/FILE_KEY/File-Name?node-id=1-42 to the smartbar dropdown
```

Run it after implementation to catch mismatches before review. Each discrepancy is classified as Critical (visually broken), Minor (measurable difference), or Non-issue (numerically different but visually identical). The report includes side-by-side screenshots for each finding.

See example reports: [toolbar button](evals/samples/simple-toolbar-button/report.md) | [smartbar dropdown](evals/samples/aiwindow-smartbar-dropdown/report.md)

---

> **Alpha** — This plugin has sharp edges and is still very much under construction. Expect rough edges and issues. Issue reports are appreciated.

## Prerequisites

- Supported OS
  - MacOS
  - Linux? (Not yet working on Apple Silicon. Might be better on x86. Expect issues either way.)

- **Sandboxed Firefox development environment** (e.g. virtual machine with [an HTTP network proxy](https://github.com/anthropic-experimental/sandbox-runtime/blob/main/src/sandbox/http-proxy.ts)). For folks at Mozilla who have access, see also the "Guidelines" section of the "AI Coding and Development" doc on mozilla-hub.

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (tested with terminal version)

- This plugin installed into Claude Code: 
  ```bash
  claude plugin marketplace add dmose/compare-figma-to-impl-skill
  claude plugin install compare-figma-to-impl@dmose-compare-figma-to-impl-skill
  ```

- Firefox DevTools MCP server configured to use the binary and profile in the current Firefox tree/worktree

  1. Node v20+ installed outside the tree with `npx` in your `${PATH}`.
  2. Configure this Firefox directory to override the firefox-devtools MCP server arguments so that it starts Firefox from an objdir in this directory and uses the default profile in that objdir  
     - You may need to edit both OBJDIR_SLUG and FX_REL_PATH in the shell command below to match your platform 
     - From a shell in the top-level of your firefox directory:
       ``` 
       (export OBJDIR_SLUG=aarch64-apple-darwin25.4.0 \
       FX_REL_PATH=Nightly.app/Contents/MacOS && \
       claude mcp add --scope local firefox-devtools -- \
          ./mach npx @padenot/firefox-devtools-mcp \
          --firefoxPath \
          ${PWD}/obj-${OBJDIR_SLUG}/dist/${FX_REL_PATH}/firefox \
          --profilePath \
          ${PWD}/obj-${OBJDIR_SLUG}/tmp/profile-default \
          --enable-script \
          --enable-privileged-context \
          --env MOZ_REMOTE_ALLOW_SYSTEM_ACCESS=1 \
          --pref remote.prefs.recommended=false \
          --pref browser.smartwindow.enabled=true)
       ```
  3. Test it. In the toplevel of your firefox dir, start claude, and then:
     1. Type `/mcp`  
     2. Ignore the `multiple scopes` warning
     3. Wait to make sure that firefox-devtools in the `Local MCP` section makes it to the `connected` state
     4. Tell it `use firefox-devtools mcp to open a firefox window`
     6. You should see a Firefox window!

- Configure Figma
  - Install the official Claude Figma plugin:
  ```claude plugin install figma@claude-plugins-official```
  - Get a Figma API token, and set it as `FIGMA_TOKEN` in the environment that you will be starting claude from.
  - Authenticate to Figma
    - start claude
    - type `/mcp`
    - look for `plugin:figma:figma`, it will likely (eventually) say `needs authentication`
    - Select that server.
    - Follow the prompts to authenticate using your browser.

## Usage

With the prerequisites running, invoke the skill from Claude Code:

1. Start claude code
2. Find Figma node corresponding to the specific element you want to compare, and copy it so you can paste it into the command.
3. Invoke the skill by command:
```
/compare-figma-to-impl https://www.figma.com/design/FILE_KEY/File-Name?node-id=1-42 to the AI window header 
```
4. This often takes 5-10 minutes on my machine, sometimes more.
5. The report, with inline screenshots, should be written to `comparison/report.md` at the top of the Firefox source tree.

## Known Major Issues
1. A non-existent "Critical" blue border issue may be claimed in the report.
2. 

