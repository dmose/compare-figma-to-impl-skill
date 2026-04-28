---
name: open-smartbar-dropdown
description: >
  Open the smartbar dropdown in Firefox's AI window by focusing the
  smartbar and triggering a search. Requires the AI window to be open
  first (run /open-ai-window if needed). Trigger phrases: "open smartbar",
  "open the smartbar dropdown", "show smartbar results".
---

# Open Smartbar Dropdown Skill

Prerequisites: The AI window must already be open and its chrome context selected. If not, run /open-ai-window first.

1. Use mcp__firefox-devtools__evaluate_chrome_script to verify the AI window is ready:
   ```js
   (function() {
     const browser = gBrowser.selectedBrowser;
     const contentDoc = browser.contentDocument;
     const aiWindow = contentDoc.querySelector('ai-window');
     if (!aiWindow || !aiWindow.shadowRoot) return 'NOT_READY';
     return 'READY';
   })()
   ```
   If NOT_READY, STOP and tell the user to run /open-ai-window first.

2. Use mcp__firefox-devtools__evaluate_chrome_script to focus the smartbar and search to trigger the dropdown:
   ```js
   (function() {
     const browser = gBrowser.selectedBrowser;
     const contentDoc = browser.contentDocument;
     const aiWindow = contentDoc.querySelector('ai-window');
     const shadow = aiWindow.shadowRoot;
     const smartbar = shadow.querySelector('moz-smartbar');
     smartbar.focus();
     smartbar.value = 'amaz';
     smartbar.search('amaz');
     return 'done';
   })()
   ```
   NOTE: Do NOT use gURLBar — that is the regular urlbar, not the smartbar. The smartbar is accessed via the ai-window shadow DOM.

3. Wait 1 second, then verify the dropdown opened using mcp__firefox-devtools__evaluate_chrome_script:
   ```js
   (function() {
     const browser = gBrowser.selectedBrowser;
     const contentDoc = browser.contentDocument;
     const aiWindow = contentDoc.querySelector('ai-window');
     const shadow = aiWindow.shadowRoot;
     const urlbar = shadow.querySelector('.urlbar');
     const urlbarView = shadow.querySelector('.urlbarView');
     return {
       urlbarOpen: urlbar.getAttribute('open') !== null,
       urlbarViewHasResults: urlbarView.getAttribute('noresults') === null,
       rowCount: shadow.querySelectorAll('.urlbarView-row').length
     };
   })()
   ```

4. If urlbarOpen is false, retry step 2 once. If still not open after 2 attempts, STOP and report to user.

## Notes
- The smartbar is `<moz-smartbar>` inside the `<ai-window>` shadow DOM — NOT gURLBar
- The smartbar DOM path: `gBrowser.selectedBrowser.contentDocument` -> `<ai-window>` -> `.shadowRoot` -> `moz-smartbar` / `.urlbarView`
- The smartbar has its own `focus()`, `search()`, and `value` properties
- The dropdown rows use classes like `.urlbarView-row`, `.urlbarView-title`, `.urlbarView-url`, `.urlbarView-action`
- The suggestions-panel-list is a separate component from the urlbarView dropdown
