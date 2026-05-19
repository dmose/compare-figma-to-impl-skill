# Prioritized list of issues:

blocker issues: (DONE)
- [x] as a demo viewer/dev, i can see all the images, to understand basic value prop (remove incorrect "comparison/" path component)
- [x] Move layout / style section to bottom (stop burying the lede!)
- [x] draft README.md with value prop, include uses as spec/acceptance criteria for input into coding (possibly by LLM!) & as QA tool
- [x] simplify elevator pitch

Installation / configuration (DONE)
- [x] how-to-configure documentation work
    - [x] figma mcp
    - [x] firefox-devtools mcp
- [x] finish .plugin impl
- [x] merge branch
- [x] add marketplace.json
- [x] install & doc this plugin on test machine
- [x] install figma deps on test machine
- [x] test run (eval example?)
- [x] add security notes
    - [x] Add sandbox verbiage.
- [x] document unreliability
- [x] test in VM
- [x] review xxx comments

Usability
- [ ] **(SmartWindow) fix /open-ai-window & /compare-figma-to-impl issues with failing to reliably recognize the AI Window context (at least when it's already selected)**
- [ ] **prevent existing running browser instances from confusing plugin (mcp server upgrade?)**
- [ ] **make comparison handle Shadow DOM more reliably**
- [ ] **(SmartWindow) make /compare-figma-to-impl find & handle aichatwindow: content more reliably**
- [ ] make overview screenshots a requirement
- [ ] as a developer, I am not incorrectly told that there is a solid blue border issue, so i don't waste time researching the wrong thing.  Likely issue: Figma UI affordance shouldn't part of design
- [ ] as a developer, I want it to work on Linux, for sandboxing options and platform coverage.
- [ ] as a developer, i see image pairs at the same scale/zoom, so i get a faster, clearer understanding of differences
- [ ] as a developer, I see both images in a pair covering the same visual area, so I get a faster, clearer understanding of the differences

Out-Of-Box experience
- [ ] Maybe use plugin .mcp.json with env vars?
    - ./mach python -c "import buildconfig; print(buildconfig.topobjdir)"
- [ ] ease-of-installation: clean up Figma dependencies
    - [x] see if we can switch to figma `remote mcp` and ditch the desktop app dependency
    - [ ] Fix need to manually install the figma dependency.  The existing 
    `allowCrossMarketplaceDependenciesOn` on `claude-plugins-official` and a dependency on figma in `plugin.json` should in theory already make this unnecessary.
    - [ ] land better m-c .mcp.json defaults (bug in progress)
    - [ ] see if we can get rid of REST API usage
- [ ] clarify value prop:
    - show process with and without (visually?)

General Quality
- [ ] commmit plan to incrementally switch to mini-workflow with schemas
- [ ] review specific discrepancies against screenshots and fix issues
- [ ] look at claude devtools failures
