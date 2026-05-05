# Contributing

Thanks for your interest in contributing to compare-figma-to-impl!

## Getting Started

1. Fork the repo and clone your fork.
2. Create a branch off `develop` for your work:
   ```bash
   git checkout develop
   git checkout -b my-feature
   ```
3. Follow the [Prerequisites](README.md#prerequisites) section in the README to set up your environment.
4. Make sure `FIGMA_TOKEN` is set in your environment (see `.env.sample` for reference).

## Branching Model

- **`main`** — release-ready code. Don't push directly to main.
- **`develop`** — integration branch. All feature work targets develop.
- Create feature branches off `develop` and open PRs back into `develop`.

## Making Changes

- Keep PRs focused on a single change.
- Test your changes against a real Figma-to-implementation comparison before submitting.
- If you add or modify a skill, make sure the plugin still loads cleanly in Claude Code (`/mcp` should show connected status).

## Reporting Issues

Bug reports are appreciated — this is alpha software with known rough edges. When filing an issue, include:

- What you were comparing (Figma URL structure is fine, no need to share actual designs)
- The generated report (or lack of one)
- Any error output from Claude Code

## Code Style

- Follow existing conventions in the codebase.
- Commit messages use imperative mood ("Add feature" not "Added feature").
- Keep commits atomic and well-described.

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.
