# Prioritized list of issues:

blocker issues:
- [x] as a demo viewer/dev, i can see all the images, to understand basic value prop (remove incorrect "comparison/" path component)
- [x] Move layout / style section to bottom (stop burying the lede!)
- [x] draft README.md with value prop, include uses as spec/acceptance criteria for input into coding (possibly by LLM!) & as QA tool

configuration info
- [ ] document setting --profilePath & --firefoxPath in README.md (how?)
- [ ] update .mcp.json to use 
    - [ ] --env MOZ_REMOTE_ALLOW_SYSTEM_ACCESS=1
    - [ ] --pref remote.prefs.recommended=false
    - [ ] --pref browser.smartwindow.enabled=true
- [ ] how-to-configure spike
- [ ] figma-mcp (see overholt's doc)
- [ ] firefox-devtools-mcp
- [ ] test marketplace / plugin installation
- [ ] write install/usage docs
- [ ] try install/usage

Reach out to testers
- [ ] simplify elevator pitch
    * MUCH SHORTER
    * USERS PAIN POINTS
    * SHOW PROCESS WITH & WITHOUT (end-to-end impl?)
    * VISUAL?
- [ ] test marketplace / plugin installation

important usability fixes
- [ ] as a developer, I am not incorrectly told that there is a solid blue border issue, so i don't waste time researching the wrong thing.  Likely issue: Figma UI affordance shouldn't part of design
- [ ] as a developer, i see image pairs at the same scale/zoom, so i get a faster, clearer understanding of differences
- [ ] as a developer, I see both images in a pair covering the same visual area, so I get a faster, clearer understanding of the differences

general quality
- [ ] review discrepancies against screenshots and fix issues
- [ ] look at claude devtools failures
- [ ] make firefox-devtools-mcp shutdown browser on signal (for evals, maybe more?)

