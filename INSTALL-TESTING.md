Parallels VM on MacOS Apple Silicon

1. Configure
   - HD: 256G (prob serious overkill for -at least artifact- builds)
   - CPU: 4 proc
   - Memory: 12G (on a 32G MacOS host machine)
   - Set it not to share Mac volumes with the GuestOS(XXXcheck in UI) for security reasons
2. Install MacOS.  Most settings should be pretty obvious or default-y, however, a few notes:
    1. "From download" seems like it could work; I installed it from a local file I downloade from Apple.
    2. Choose "Set up as new" on the "Transfer Your Data to This Mac" screen.
    3. On "Create an account" screen, de-select "Allow computer account password to be reset with Apple Account"
    4. On the "Sign in to your Apple Account" page, select the "Other Sign-in Options" dropdown and choose "Sign-in Later in Settings" for improved security.
    5. Install Parallels Tools in your account
3. Set up and build Firefox
    6. Following the [Building Firefox on MacOS](https://firefox-source-docs.mozilla.org/setup/macos_build.html) instructions.
      1. Ignore the "Install XCode" section of those docs, and instead do this:
      ```
      sudo xcode-select --switch /Library/Developer/CommandLineTools`
      ```
   7. Will you be submitting commits to Mozilla - Yes for now, though maybe better not to
   8. ??? Abort Phabricator API key request
   9. ??? Ignore Rust error
   10. ??? Use `brew install rust`
4. Set up Claude Code
   1. Open a browser and log into https://sso.mozilla.com/
   2. Do a Native Claude Code install
      https://code.claude.com/docs/en/quickstart/
   3. ```curl -fsSL https://claude.ai/install.sh | bash```
   4. Start Claude: ```claude```
   5. Once you get to the account choice, choose "Anthropic Console Account"
   6. Enter your email address into the Claude Code page
   7. Click the "Authorize" button to set up Claude Code with you Mozilla account
   8. You should see a page that looks something like this:
   ```
   You’re all set up for Claude Code.
   You can now close this window.
   ```
   9. Close the browser tab
   10. In your terminal window, Claude should now be displaying something like this:
   ```
   Logged in as example@mozilla.com
   Login successful. Press Enter to continue…
   ```
   11. Trust the Firefox source folder
   12. Accept the MCP servers from .mcp.json
5. You now have a development ready-ish) VM
6. Take a snapshot of the VM so you can always roll basck to it
   1. From the Host MacOS Parallels Menubar, select Actions > Take a Snapshot
   