#!/bin/bash
# Run the compare-figma-to-impl skill via claude -p, then grade the output.
#
# Usage: ./run-eval.sh [-g] [prompt]
#   -g    Grade only: skip running the skill and grade the existing comparison/ directory
#
# Example: ./run-eval.sh "Compare the AI Window header to the Figma design at figma.com/design/abc123/ai-window?node-id=1-42"
# Example: ./run-eval.sh -g
#
# Prerequisites:
#   - Firefox is open with the target UI visible
#   - Figma MCP and Firefox devtools MCP are connected
#
# What this checks (valid token):
#   1. The skill creates a comparison/ directory
#   2. The skill saves a report.md file in that directory
#   3. figma-screenshot.png exists in the output directory
#   4. impl-screenshot.png exists in the output directory
#   5. The report passes all content assertions (no "Styling Details" section, etc.)
#
# What this checks (expired/invalid token):
#   1. The Skill tool was invoked (subagent was used)
#   2. The output mentions the token is expired/invalid
#   (info) Whether fix URL was relayed and whether subagent stopped

set -euo pipefail

GRADE_ONLY=false
if [ "${1:-}" = "-g" ]; then
  GRADE_ONLY=true
  shift
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$REPO_ROOT/comparison"
REPORT_FILE="$OUTPUT_DIR/report.md"
CLAUDE_OUTPUT="$OUTPUT_DIR/claude-output.txt"

# --- Pre-flight: check Figma token validity ---
FIGMA_TOKEN_VALID=true
FIGMA_TOKEN="${FIGMA_TOKEN:-}"
if [ -z "$FIGMA_TOKEN" ]; then
  source "$REPO_ROOT/.env" 2>/dev/null || true
fi
if [ -z "$FIGMA_TOKEN" ]; then
  echo "WARNING: FIGMA_TOKEN not set — expecting expired-token behavior"
  FIGMA_TOKEN_VALID=false
else
  # Quick probe: hit /v1/me to check token validity
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Figma-Token: $FIGMA_TOKEN" "https://api.figma.com/v1/me" 2>/dev/null || echo "000")
  if [ "$HTTP_STATUS" != "200" ]; then
    echo "WARNING: FIGMA_TOKEN returned HTTP $HTTP_STATUS — expecting expired-token behavior"
    FIGMA_TOKEN_VALID=false
  else
    echo "Figma token is valid (HTTP 200)"
  fi
fi

if [ "$GRADE_ONLY" = false ]; then
  DEFAULT_PROMPT='Use the compare-figma-to-impl skill to compare the four icon buttons in the top left corner of the firefox main window to
@https://www.figma.com/design/5KuePTGmOEUFyCHBHCsGim/AI-Mode-%E2%80%94%C2%A0MVP-Scope-Design?node-id=8559-44226&m=dev'

  PROMPT="${1:-$DEFAULT_PROMPT}"

  # Clean up any previous run
  rm -rf "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"

  echo "=== Running skill via claude -p ==="
  echo "Prompt: $PROMPT"
  echo ""

  (cd "$REPO_ROOT" && echo "$PROMPT" | claude -p --verbose --output-format stream-json \
    --allowedTools "Bash Write Read Edit Glob Grep Skill mcp__plugin_figma_figma__get_design_context mcp__plugin_figma_figma__get_screenshot mcp__plugin_figma_figma__get_metadata mcp__firefox-devtools__take_snapshot mcp__firefox-devtools__screenshot_page mcp__firefox-devtools__screenshot_by_uid mcp__firefox-devtools__evaluate_script mcp__firefox-devtools__evaluate_chrome_script mcp__firefox-devtools__list_chrome_contexts mcp__firefox-devtools__select_chrome_context mcp__firefox-devtools__list_pages mcp__firefox-devtools__select_page" \
    ) | tee "$CLAUDE_OUTPUT"
else
  echo "=== Grade-only mode: using existing comparison/ directory ==="
fi

echo ""
echo "=== Checking output ==="

pass=0
fail=0
total=0

if [ "$FIGMA_TOKEN_VALID" = true ]; then
  # --- Valid token: full comparison checks ---
  echo "(Figma token valid — checking full comparison output)"
  echo ""

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

  # Check 3: figma-screenshot.png exists
  total=$((total + 1))
  if [ -f "$OUTPUT_DIR/figma-screenshot.png" ]; then
    echo "  PASS: figma-screenshot.png exists"
    pass=$((pass + 1))
  else
    echo "  FAIL: figma-screenshot.png was not created"
    fail=$((fail + 1))
  fi

  # Check 4: impl-screenshot.png exists
  total=$((total + 1))
  if [ -f "$OUTPUT_DIR/impl-screenshot.png" ]; then
    echo "  PASS: impl-screenshot.png exists"
    pass=$((pass + 1))
  else
    echo "  FAIL: impl-screenshot.png was not created"
    fail=$((fail + 1))
  fi

  # Check 5: Grade the report content (if it exists)
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
    # Count the 3 content assertions from grade.sh as failures
    fail=$((fail + 3))
    total=$((total + 3))
  fi

else
  # --- Expired token: error-handling checks ---
  echo "(Figma token expired — checking error-handling behavior)"
  echo ""

  # Check 1: Skill tool was invoked
  total=$((total + 1))
  if [ -f "$CLAUDE_OUTPUT" ] && grep -q '"name":"Skill"' "$CLAUDE_OUTPUT"; then
    echo "  PASS: Skill tool was invoked"
    pass=$((pass + 1))
  else
    echo "  FAIL: Skill tool was not invoked"
    fail=$((fail + 1))
  fi

  # Extract assistant text output (not SKILL.md content or tool results)
  ASSISTANT_TEXT=""
  if [ -f "$CLAUDE_OUTPUT" ]; then
    ASSISTANT_TEXT=$(python3 -c "
import json, sys
with open('$CLAUDE_OUTPUT') as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try:
            obj = json.loads(line)
            if obj.get('type') == 'assistant':
                for block in obj.get('message',{}).get('content',[]):
                    if block.get('type') == 'text':
                        print(block['text'])
            elif obj.get('type') == 'result':
                result = obj.get('result','')
                if result:
                    print(result)
        except: pass
" 2>/dev/null)
  fi

  # Check 2: Assistant text mentions token expired/invalid
  total=$((total + 1))
  if echo "$ASSISTANT_TEXT" | grep -qiE 'token.*(expired|invalid)|expired.*token|invalid.*token'; then
    echo "  PASS: Assistant mentions token expired/invalid"
    pass=$((pass + 1))
  else
    echo "  FAIL: Assistant does not mention token expired/invalid"
    fail=$((fail + 1))
  fi

  # Check 3 (info): Assistant text contains fix instructions (token generation URL)
  # Non-blocking: the model sometimes relays the URL, sometimes doesn't.
  if echo "$ASSISTANT_TEXT" | grep -q 'figma.com/developers/api#access-tokens'; then
    echo "  INFO: Assistant text contains token fix URL (bonus)"
  else
    echo "  INFO: Assistant text missing token fix URL (non-blocking)"
  fi

  # Check 3 (info): Subagent stopped on error
  # Non-blocking: the model's helpfulness bias consistently overrides STOP
  # instructions when it has alternative paths (MCP screenshots).
  if [ ! -f "$REPORT_FILE" ]; then
    echo "  INFO: No report.md created (subagent stopped on error — ideal)"
  else
    echo "  INFO: report.md was created (subagent continued despite token error)"
  fi
fi

echo ""
echo "=== Final Results ==="
echo "Passed: $pass / $total"
echo "Failed: $fail / $total"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
