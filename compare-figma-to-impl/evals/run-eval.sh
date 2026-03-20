#!/bin/bash
# Run the compare-figma-to-impl skill via claude -p, then grade the output.
#
# Usage: ./run-eval.sh [prompt]
# Example: ./run-eval.sh "Compare the AI Window header to the Figma design at figma.com/design/abc123/ai-window?node-id=1-42"
#
# Prerequisites:
#   - Firefox is open with the target UI visible
#   - Figma MCP and Firefox devtools MCP are connected
#
# What this checks:
#   1. The skill creates a comparison/ directory
#   2. The skill saves a report.md file in that directory
#   3. The report passes all content assertions (no "Styling Details" section, etc.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$REPO_ROOT/comparison"
REPORT_FILE="$OUTPUT_DIR/report.md"

DEFAULT_PROMPT='Compare the four icon buttons in the top left corner of the firefox main window to
@https://www.figma.com/design/5KuePTGmOEUFyCHBHCsGim/AI-Mode-%E2%80%94%C2%A0MVP-Scope-Design?node-id=8559-44226&m=dev'

PROMPT="${1:-$DEFAULT_PROMPT}"

# Clean up any previous run
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "=== Running skill via claude -p ==="
echo "Prompt: $PROMPT"
echo ""

(cd "$REPO_ROOT" && echo "$PROMPT" | claude -p --verbose --output-format stream-json \
  --allowedTools "Bash Write Read Edit Glob Grep Skill mcp__plugin_figma_figma__get_design_context mcp__plugin_figma_figma__get_screenshot mcp__plugin_figma_figma__get_metadata mcp__firefox-devtools__take_snapshot mcp__firefox-devtools__screenshot_page mcp__firefox-devtools__screenshot_by_uid mcp__firefox-devtools__evaluate_script mcp__firefox-devtools__list_pages mcp__firefox-devtools__select_page" \
  ) | tee "$OUTPUT_DIR/claude-output.txt"

echo ""
echo "=== Checking output ==="

pass=0
fail=0
total=0

# Check 1: Directory exists
total=$((total + 1))
if [ -d "$OUTPUT_DIR" ]; then
  echo "  PASS: $OUTPUT_DIR/ directory exists"
  pass=$((pass + 1))
else
  echo "  FAIL: $OUTPUT_DIR/ directory was not created"
  fail=$((fail + 1))
fi

# Check 2: report.md exists
total=$((total + 1))
if [ -f "$REPORT_FILE" ]; then
  echo "  PASS: $REPORT_FILE exists"
  pass=$((pass + 1))
else
  echo "  FAIL: $REPORT_FILE was not created"
  fail=$((fail + 1))
fi

# Check 3: Grade the report content (if it exists)
if [ -f "$REPORT_FILE" ]; then
  echo ""
  echo "=== Grading report content ==="
  "$SCRIPT_DIR/grade.sh" "$REPORT_FILE"
  grade_exit=$?
  if [ "$grade_exit" -ne 0 ]; then
    fail=$((fail + 1))
  fi
else
  echo ""
  echo "  Skipping content checks — no report file to grade"
  # Count the 3 content assertions as failures
  fail=$((fail + 3))
  total=$((total + 3))
fi

echo ""
echo "=== Final Results ==="
echo "Passed: $pass / $total"
echo "Failed: $fail / $total"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
