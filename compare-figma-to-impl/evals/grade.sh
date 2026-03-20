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
