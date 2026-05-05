#!/usr/bin/env node

import { execSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { createInterface } from "node:readline";

const ROOT = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const PLUGIN_JSON = join(ROOT, ".claude-plugin", "plugin.json");
const CHANGELOG = join(ROOT, "CHANGELOG.md");
const REPO_URL = "https://github.com/dmose/compare-figma-to-impl";

function run(cmd, opts) {
  return execSync(cmd, { cwd: ROOT, encoding: "utf8", ...opts }).trim();
}

function ask(question) {
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) =>
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    })
  );
}

function die(msg) {
  console.error(`Error: ${msg}`);
  process.exit(1);
}

function bumpVersion(current, part) {
  const [major, minor, patch] = current.split(".").map(Number);
  if (part === "major") return `${major + 1}.0.0`;
  if (part === "minor") return `${major}.${minor + 1}.0`;
  return `${major}.${minor}.${patch + 1}`;
}

function today() {
  const d = new Date();
  return [
    d.getFullYear(),
    String(d.getMonth() + 1).padStart(2, "0"),
    String(d.getDate()).padStart(2, "0"),
  ].join("-");
}

// --- Preflight checks ---

const branch = run("git rev-parse --abbrev-ref HEAD");
if (branch !== "develop") {
  die(`Must be on the develop branch (currently on ${branch})`);
}

const status = run("git status --porcelain");
if (status) {
  die("Working tree is not clean. Commit or stash changes first.");
}

run("git fetch origin");
const behind = run("git rev-list HEAD..origin/develop --count");
if (behind !== "0") {
  die("Local develop is behind origin/develop. Pull first.");
}

const mainAhead = run("git rev-list develop..origin/main --count");
if (mainAhead !== "0") {
  die("origin/main has commits not on develop. Rebase develop onto main first.");
}

const newOnDevelop = run("git log --oneline origin/main..develop");
if (!newOnDevelop) {
  die("No new commits on develop since last release. Nothing to release.");
}

// --- Determine version ---

const pluginJson = JSON.parse(readFileSync(PLUGIN_JSON, "utf8"));
const currentVersion = pluginJson.version;

console.log(`\nCurrent version: ${currentVersion}`);
console.log(`\nCommits to release:\n${newOnDevelop}\n`);

const bumpType =
  process.argv[2] ||
  (await ask("Bump type (major / minor / patch) [patch]: ")) ||
  "patch";

if (!["major", "minor", "patch"].includes(bumpType)) {
  die(`Invalid bump type: ${bumpType}`);
}

const newVersion = bumpVersion(currentVersion, bumpType);
const confirm = await ask(`Release v${newVersion}? (y/n) [y]: `);
if (confirm && confirm.toLowerCase() !== "y") {
  console.log("Aborted.");
  process.exit(0);
}

// --- Update plugin.json ---

pluginJson.version = newVersion;
writeFileSync(PLUGIN_JSON, JSON.stringify(pluginJson, null, 2) + "\n");
console.log(`Updated ${PLUGIN_JSON} to ${newVersion}`);

// --- Update CHANGELOG.md ---

let changelog = readFileSync(CHANGELOG, "utf8");

const unreleasedRe = /(## \[Unreleased\])([\s\S]*?)(?=\n## \[)/;
const match = changelog.match(unreleasedRe);
if (!match) {
  die("Could not find ## [Unreleased] section in CHANGELOG.md");
}

const unreleasedContent = match[2];
changelog = changelog.replace(
  unreleasedRe,
  `## [Unreleased]\n\n## [${newVersion}] - ${today()}${unreleasedContent}`
);

const unreleasedLink = `[Unreleased]: ${REPO_URL}/compare/v${currentVersion}...HEAD`;
const newUnreleasedLink = `[Unreleased]: ${REPO_URL}/compare/v${newVersion}...HEAD`;
const newVersionLink = `[${newVersion}]: ${REPO_URL}/compare/v${currentVersion}...v${newVersion}`;

const before = changelog;
changelog = changelog.replace(unreleasedLink, `${newUnreleasedLink}\n${newVersionLink}`);
if (changelog === before) {
  die(`Could not find Unreleased comparison link in CHANGELOG.md.\nExpected: ${unreleasedLink}`);
}

writeFileSync(CHANGELOG, changelog);
console.log(`Updated CHANGELOG.md for ${newVersion}`);

// --- Commit, merge, tag ---

const developHead = run("git rev-parse HEAD");

try {
  run(`git add "${PLUGIN_JSON}" "${CHANGELOG}"`);
  run(`git commit -m "Release v${newVersion}"`);
  console.log(`Committed release on develop`);

  run("git checkout main");
  run("git merge develop --ff-only");
  console.log("Merged develop into main");

  run(`git tag v${newVersion}`);
  console.log(`Tagged v${newVersion}`);

  run("git checkout develop");
  run("git merge main --ff-only");
  console.log("Fast-forwarded develop to main");
} catch (err) {
  console.error(`\nRelease failed: ${err.message}`);
  console.error("\nTo recover:");
  console.error(`  git checkout develop`);
  console.error(`  git reset --hard ${developHead}`);
  console.error(`  git tag -d v${newVersion} 2>/dev/null || true`);
  console.error(`  git checkout main && git reset --hard origin/main`);
  process.exit(1);
}

// --- Push ---

const pushConfirm = await ask("\nPush main, develop, and tags to origin? (y/n) [y]: ");
if (pushConfirm && pushConfirm.toLowerCase() !== "y") {
  console.log("Skipped push. Run manually:\n  git push origin main develop --tags");
  process.exit(0);
}

run("git push origin main develop --tags");
console.log(`\nReleased v${newVersion}`);
