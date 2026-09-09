#!/usr/bin/env bash
set -euo pipefail

TASK="${TASK:-inspect repository}"
SCOPE="${SCOPE:-.}"
OPERATION="${OPERATION:-INSPECT}"
TARGET_FILE="${TARGET_FILE:-}"
OLD_TEXT="${OLD_TEXT:-}"
NEW_TEXT="${NEW_TEXT:-}"

REPORT_FILE=".agent/execution-report.md"

fail() {
  echo "ERROR: $1"
  exit 1
}

echo "SH Agent Executor"
echo "Task: $TASK"
echo "Scope: $SCOPE"
echo "Operation: $OPERATION"

if [[ -z "$SCOPE" ]]; then
  fail "scope is required"
fi

if [[ ! -e "$SCOPE" ]]; then
  fail "scope does not exist: $SCOPE"
fi

case "$OPERATION" in
  INSPECT)
    STATUS="Inspection completed"
    ;;
  VERIFY)
    STATUS="Verification completed"
    ;;
  EDIT)
    if [[ -z "$TARGET_FILE" ]]; then
      fail "EDIT requires TARGET_FILE"
    fi
    if [[ -z "$OLD_TEXT" ]]; then
      fail "EDIT requires OLD_TEXT"
    fi
    if [[ ! -e "$TARGET_FILE" ]]; then
      fail "target file does not exist: $TARGET_FILE"
    fi

    export TARGET_FILE OLD_TEXT NEW_TEXT
    bash .agent/operations/edit_apply.sh
    STATUS="Edit applied: $TARGET_FILE"
    ;;
  *)
    fail "unsupported operation: $OPERATION"
    ;;
esac

cat > "$REPORT_FILE" <<EOF
# SH Agent Execution Report

## Task
$TASK

## Scope
$SCOPE

## Operation
$OPERATION

## Status
$STATUS
EOF

echo "Workspace status:"
git status --short

echo "Diff preview:"
git diff --stat

echo "Executor operation handler complete"
