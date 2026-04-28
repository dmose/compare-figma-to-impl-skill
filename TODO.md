# Prioritized list of issues:

blocker issues:
- [x] as a demo viewer/dev, i can see all the images, to understand basic value prop (remove incorrect "comparison/" path component)
- [x] Move layout / style section to bottom (stop burying the lede!)
- [x] draft README.md with value prop, include uses as spec/acceptance criteria for input into coding (possibly by LLM!) & as QA tool
- [x] simplify elevator pitch
    * MUCH SHORTER
    * USERS PAIN POINTS

Installation / configuration
- [x] how-to-configure documentation work
    - [x] figma-mcp (see overholt's doc)
    - [x] firefox-devtools-mcp
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
    - [x] clean up disk space
    - [x] install linux
    - [x] build firefox
- [x] review xxx comments

Reach out to testers
- [ ] announce in #ai4dev

Usability
- [ ] as a developer, I am not incorrectly told that there is a solid blue border issue, so i don't waste time researching the wrong thing.  Likely issue: Figma UI affordance shouldn't part of design
- [ ] as a developer, I want it to work on Linux, for sandboxing options and platform coverage.
- [ ] as a developer, i see image pairs at the same scale/zoom, so i get a faster, clearer understanding of differences
- [ ] as a developer, I see both images in a pair covering the same visual area, so I get a faster, clearer understanding of the differences

Funnel refinement
- [ ] refine elevator pitch
    * SHOW PROCESS WITH & WITHOUT (end-to-end impl?)
    * VISUAL?
- [ ] Maybe use plugin .mcp.json with env vars?
    * ./mach python -c "import buildconfig; print(buildconfig.topobjdir)"
- [ ] ease-of-installation: clean up Figma dependencies
    - [x] Use a marketplace.json with `allowCrossMarketplaceDependenciesOn` and a dependency in `plugin.json`
    - [x] see if we can switch to figma `remote mcp` and ditch the REST and desktop deps
    - [ ] see if we can get rid of REST API usage
- [ ] ease-of-installation: land better m-c .mcp.json defaults (bug in progress)

general quality
- [ ] commmit plan to incrementally switch to mini-workflow with schemas
- [ ] review discrepancies against screenshots and fix issues
- [ ] look at claude devtools failures
- [ ] make firefox-devtools-mcp shutdown browser on signal (for evals, maybe more?)

