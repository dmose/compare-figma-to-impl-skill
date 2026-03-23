#!/bin/bash
# Grade captured sample outputs against expectations.
# Usage: ./grade.sh [sample_file]
# If no file given, grades all samples in evals/samples/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SAMPLES_DIR="$SCRIPT_DIR/samples"

pass=0
fail=0
total=0

grade_file() {
  local file="$1"
  local basename
  basename="$(basename "$file")"

  echo "--- Grading: $basename ---"

  # Expectation 1: Has "Layout & Styling" section
  total=$((total + 1))
  if grep -qiE '^#{1,4}\s+.*Layout.*Styling' "$file"; then
    echo "  PASS: Contains 'Layout & Styling' section"
    pass=$((pass + 1))
  else
    echo "  FAIL: Missing 'Layout & Styling' section"
    fail=$((fail + 1))
  fi

  # Expectation 2: Has "Summary of Discrepancies" section
  total=$((total + 1))
  if grep -qiE '^#{1,4}\s+.*Summary.*Discrepancies' "$file"; then
    echo "  PASS: Contains 'Summary of Discrepancies' section"
    pass=$((pass + 1))
  else
    echo "  FAIL: Missing 'Summary of Discrepancies' section"
    fail=$((fail + 1))
  fi

  # Expectation 3: Per-discrepancy screenshot tables
  total=$((total + 1))
  local discrepancy_section
  # Extract from "## Summary of Discrepancies" to the next ## heading or EOF
  discrepancy_section=$(awk '/^## Summary of Discrepancies/{found=1; next} found && /^## [^#]/{exit} found' "$file")

  if [ -z "$discrepancy_section" ]; then
    echo "  FAIL: Could not extract Summary of Discrepancies section"
    fail=$((fail + 1))
  else
    # Count discrepancies: top-level numbered items (no leading whitespace)
    local discrepancy_count
    discrepancy_count=$(echo "$discrepancy_section" | grep -cE '^[0-9]+\.' || true)

    # Count screenshot tables
    local screenshot_table_count
    screenshot_table_count=$(echo "$discrepancy_section" | grep -cE '\|.*!\[Figma.*\|.*!\[Implementation.*\|' || true)

    if [ "$discrepancy_count" -eq 0 ] && [ "$screenshot_table_count" -eq 0 ]; then
      echo "  PASS: No discrepancies and no screenshot tables (consistent)"
      pass=$((pass + 1))
    elif [ "$screenshot_table_count" -eq "$discrepancy_count" ]; then
      echo "  PASS: Found $discrepancy_count discrepancies with $screenshot_table_count screenshot tables (1:1)"
      pass=$((pass + 1))
    else
      echo "  FAIL: Found $discrepancy_count discrepancies but $screenshot_table_count screenshot tables (expected 1 per discrepancy)"
      fail=$((fail + 1))
    fi

    # Check file existence for referenced screenshots (skip for samples)
    if [[ "$file" != *evals/samples/* ]]; then
      local report_dir
      report_dir="$(dirname "$file")"
      while IFS= read -r img_path; do
        [ -z "$img_path" ] && continue
        total=$((total + 1))
        # Resolve relative paths against the report's directory
        local resolved_path="$img_path"
        if [[ "$img_path" != /* ]]; then
          resolved_path="$report_dir/$img_path"
        fi
        if [ -f "$resolved_path" ]; then
          echo "  PASS: Referenced screenshot $img_path exists"
          pass=$((pass + 1))
        else
          echo "  FAIL: Referenced screenshot $img_path does not exist"
          fail=$((fail + 1))
        fi
      done < <(echo "$discrepancy_section" | grep -oE '!\[[^]]*\]\([^)]+\)' | grep -oE '\([^)]+\)' | tr -d '()')
    fi
  fi

  # Expectation 4: Image references have no path components (same-directory only)
  total=$((total + 1))
  local bad_paths
  bad_paths=$(grep -oE '!\[[^]]*\]\([^)]+\)' "$file" | grep -oE '\([^)]+\)' | tr -d '()' | grep '/' || true)
  if [ -z "$bad_paths" ]; then
    echo "  PASS: All image references are filename-only (no path components)"
    pass=$((pass + 1))
  else
    echo "  FAIL: Image references contain path components (should be filename-only):"
    echo "$bad_paths" | sed 's/^/    /'
    fail=$((fail + 1))
  fi

  echo ""
}

if [ $# -gt 0 ]; then
  grade_file "$1"
else
  for sample in "$SAMPLES_DIR"/*.md; do
    grade_file "$sample"
  done
fi

echo "=== Results ==="
echo "Passed: $pass / $total"
echo "Failed: $fail / $total"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
