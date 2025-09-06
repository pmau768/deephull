#!/bin/bash
set -euo pipefail

# Expect check-domain.sh to fail for a non-existent domain
log=$(mktemp)
if printf 'nonexistent.example\n' | ./check-domain.sh >"$log" 2>&1; then
  echo "Expected failure for non-existent domain" >&2
  cat "$log" >&2
  exit 1
else
  if grep -q 'Domain does not resolve' "$log"; then
    echo "PASS: Non-existent domain correctly reported"
  else
    echo "FAIL: Missing domain resolution error" >&2
    cat "$log" >&2
    exit 1
  fi
fi

rm -f "$log"

