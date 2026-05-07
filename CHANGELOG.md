# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/dmose/compare-figma-to-impl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/dmose/compare-figma-to-impl/commits/v0.1.1
