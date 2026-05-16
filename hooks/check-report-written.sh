#!/bin/bash
# SubagentStop hook for compare-figma-to-impl: blocks the subagent from
# stopping until comparison/report.md exists and is non-empty.
#
# Scoping (so this hook only fires for OUR skill, not unrelated subagents):
#   1. agent_type must be "general-purpose" (matches the skill's frontmatter)
#   2. agent transcript must mention compare-figma-to-impl (skill was loaded)
#
# Retry cap: we block at most once per subagent stop. The second time the
# hook fires (with stop_hook_active=true), we let the subagent give up to
# avoid pathological loops.

set -euo pipefail

INPUT=$(cat)

AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null || echo "")
AGENT_TRANSCRIPT=$(echo "$INPUT" | jq -r '.agent_transcript_path // ""' 2>/dev/null || echo "")
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")

# Filter 1: skill spawns a general-purpose subagent.
[ "$AGENT_TYPE" = "general-purpose" ] || exit 0

# Filter 2: this subagent actually loaded our skill.
[ -n "$AGENT_TRANSCRIPT" ] && [ -f "$AGENT_TRANSCRIPT" ] || exit 0
grep -q 'compare-figma-to-impl' "$AGENT_TRANSCRIPT" || exit 0

# Already good: report exists and is non-empty.
REPORT="${CLAUDE_PROJECT_DIR:-$PWD}/comparison/report.md"
[ -s "$REPORT" ] && exit 0

# Cap at one retry: if we already blocked once, let the subagent give up.
[ "$STOP_ACTIVE" = "true" ] && exit 0

cat <<'JSON'
{
  "decision": "block",
  "reason": "comparison/report.md was not written. Before stopping, save the full markdown report to comparison/report.md using Bash with a single-quoted heredoc (cat > comparison/report.md <<'REPORT_EOF' ... REPORT_EOF), using the section headers from the Report Schema in SKILL.md. Then run `ls -la comparison/report.md` to verify. Do NOT use the Write tool — Claude Code blocks subagent Writes to report files; Bash + heredoc is the working path."
}
JSON
exit 0
