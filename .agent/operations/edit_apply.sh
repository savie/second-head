#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE="${TARGET_FILE:-}"
OLD_TEXT="${OLD_TEXT:-}"
NEW_TEXT="${NEW_TEXT:-}"

fail() {
  echo "ERROR: $1"
  exit 1
}

[[ -n "$TARGET_FILE" ]] || fail "TARGET_FILE is required"
[[ -f "$TARGET_FILE" ]] || fail "target file does not exist: $TARGET_FILE"
[[ -n "$OLD_TEXT" ]] || fail "OLD_TEXT is required"

COUNT=$(grep -F -o "$OLD_TEXT" "$TARGET_FILE" | wc -l | tr -d ' ')

if [[ "$COUNT" != "1" ]]; then
  fail "expected exactly one match, found $COUNT"
fi

python3 - <<PY
from pathlib import Path
p = Path("$TARGET_FILE")
s = p.read_text()
old = """$OLD_TEXT"""
new = """$NEW_TEXT"""
p.write_text(s.replace(old, new, 1))
PY

echo "Edit applied: $TARGET_FILE"
git diff -- "$TARGET_FILE"
