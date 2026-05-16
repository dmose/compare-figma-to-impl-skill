# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.9] - 2026-05-15

### Fixed
- **Successful comparison runs are faster (~1 min) and more
  reliable.** The skill should now save `comparison/report.md` on
  the first attempt. Previously every run tripped a Claude Code
  subagent guardrail on its way to writing the report and relied
  on the subagent improvising a fallback to recover — slower, and
  not guaranteed to succeed if a given subagent didn't think to
  try a different write mechanism.
- **The `SubagentStop` safety net can now actually rescue runs that
  would otherwise finish without a report.** Its retry nudge points
  at a write path Claude Code allows for subagents; previously it
  pointed at the same blocked path it was meant to recover from.

## [0.1.8] - 2026-05-14

### Fixed
- Skill now reliably writes `comparison/report.md` before finishing;
  previously it could silently skip the write under some conditions.
- Phase 1's Figma screenshot download now surfaces the actual Figma
  API error (file inaccessible, wrong node_id format, etc.) instead
  of always blaming the token.

## [0.1.7] - 2026-05-14

### Added
- INSTALL-TESTING.md with Parallels VM setup notes for testing the plugin
- `claude plugin marketplace remove` command in UNINSTALL.md

### Changed
- Strengthen report-to-disk enforcement in compare-figma-to-impl skill:
  make the Write tool call the mandatory final action, suppress full-report
  conversation output, and cap the inline summary at 5 lines
- Clarify README setup: add Dev Mode / Share / Copy link instructions for
  Figma and note that users can specify what to compare and how

## [0.1.6] - 2026-05-08

## [0.1.5] - 2026-05-08

### Added
- Document known issue: `/open-ai-window` can loop when a Firefox instance
  already holds the profile directory

### Fixed
- Fix marketplace install command: `claude marketplace add` →
  `claude plugin marketplace add`

## [0.1.4] - 2026-05-07

### Added
- UNINSTALL.md with instructions for removing the plugin and MCP server

### Changed
- Bump Node.js prerequisite from v20+ to v22+
- Add explicit prerequisite that Firefox tree must have been built and run at least once
- Expand auto-update instructions in README with step-by-step guide
  and link to Claude Code docs (thanks to @flozia for the suggestion)
- Fix MCP setup command: use `npx` directly instead of `./mach npx`
  (thanks to @flozia for the suggestion)
- Fix MCP setup command: use `get_binary_path()` for `FX_PATH` instead
  of `topobjdir` to point at the actual Firefox binary
- Fix Figma plugin install instructions: add missing `marketplace add`
  command for the official Claude plugins marketplace

### Fixed
- Fix MCP setup shell command: `export` swallowed `claude mcp add` as
  a variable assignment so the server was never configured
- Remove invalid `permissions` key from plugin.json that caused
  installation failures (thanks to @flozia for reporting this)
- Fix `dependencies` format: use string identifier instead of object
  with unsupported `marketplace` key (thanks to @flozia for reporting this)

## [0.1.3] - 2026-05-06

### Changed
- Clarify README setup instructions: simplify sandboxed environment description,
  remove unnecessary note about editing build variables, and add troubleshooting
  contact info for MCP setup

## [0.1.2] - 2026-05-05

### Added
- CONTRIBUTING.md with branching model and contribution guidelines

### Changed
- Simplify MCP install instructions to auto-detect objdir and Firefox path
  via `mach python`

## [0.1.1] - 2026-05-03

### Changed
- Drop "-skill" suffix from marketplace package name
- Note in README that marketplace installs auto-update

## [0.1.0] - 2026-04-28

### Added
- Core compare-figma-to-impl skill: structured comparison report with
  side-by-side screenshots and discrepancy analysis
- Figma screenshot download via REST API
- Per-discrepancy screenshot capture phase with before/after tables
- Token validation for explicit skill invocation
- open-ai-window skill for opening Firefox's AI sidebar
- open-smartbar-dropdown skill for triggering the smartbar search dropdown
- Claude Code plugin structure with marketplace manifest and MCP permissions
- Eval harness with grade-only mode, screenshot assertions, and
  filename-only image reference checks
- README with example report links and install instructions
- TODO.md issue tracker
- Sandbox requirement documentation
- .env.sample for Figma token configuration
- Firefox Nightly config and firefox-devtools-mcp integration

[Unreleased]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.9...HEAD
[0.1.9]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.8...v0.1.9
[0.1.8]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/dmose/compare-figma-to-impl/commits/v0.1.1
