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
- [ ] write marketplace / plugin installation
- [ ] test marketplace / plugin installation
- [ ] add security notes

Reach out to testers
- [ ] put in tooling doc
- [ ] announce in #ai4dev

Usability
- [ ] as a developer, I am not incorrectly told that there is a solid blue border issue, so i don't waste time researching the wrong thing.  Likely issue: Figma UI affordance shouldn't part of design
- [ ] as a developer, i see image pairs at the same scale/zoom, so i get a faster, clearer understanding of differences
- [ ] as a developer, I see both images in a pair covering the same visual area, so I get a faster, clearer understanding of the differences

Funnel refinement
- [ ] refine elevator pitch
    * SHOW PROCESS WITH & WITHOUT (end-to-end impl?)
    * VISUAL?
- [ ] Maybe use plugin .mcp.json with env vars?
    * ./mach python -c "import buildconfig; print(buildconfig.topobjdir)"
- [ ] ease-of-installation: clean up Figma dependencies
    - [ ] Use a marketplace.json with `allowCrossMarketplaceDependenciesOn` and a dependency in `plugin.json`
    - [ ] see if we can switch to figma `remote mcp` and ditch the REST and desktop deps
- [ ] ease-of-installation: land better m-c .mcp.json defaults (bug in progress)

general quality
- [ ] review discrepancies against screenshots and fix issues
- [ ] look at claude devtools failures
- [ ] make firefox-devtools-mcp shutdown browser on signal (for evals, maybe more?)
- [ ] schemas?

