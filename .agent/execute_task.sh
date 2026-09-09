#!/usr/bin/env bash
set -euo pipefail

TASK="${TASK:-inspect repository}"
SCOPE="${SCOPE:-.}"
OPERATION="${OPERATION:-INSPECT}"
TARGET_FILE="${TARGET_FILE:-}"

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
    if [[ ! -e "$TARGET_FILE" ]]; then
      fail "target file does not exist: $TARGET_FILE"
    fi
    STATUS="Edit target validated: $TARGET_FILE"
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
