#!/usr/bin/env bash
set -euo pipefail

echo "Running shellcheck on shell scripts..."
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck is not installed. On Debian/Ubuntu: sudo apt-get install -y shellcheck" >&2
  exit 2
fi

find . -type f -name '*.sh' -not -path './.git/*' -print0 | xargs -0 shellcheck --severity=info || true

echo "Done."
