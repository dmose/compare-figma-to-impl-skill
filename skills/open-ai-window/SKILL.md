---
name: open-ai-window
description: >
  Open Firefox's AI sidebar window and select its chrome context.
  Trigger phrases: "open ai window", "open the ai window",
  "switch to ai window".
---

# Open AI Window Skill
1. Use mcp__firefox-devtools__list_chrome_contexts to see available contexts
2. Use mcp__firefox-devtools__select_chrome_context to select the main browser context
3. Use mcp__firefox-devtools__evaluate_chrome_script to run: `OpenBrowserWindow({ aiWindow: true })`
4. Wait 3 seconds, then list_chrome_contexts again
5. Select the ai-window-browser context from the updated list
6. If context not found after 2 attempts, STOP and report to user
