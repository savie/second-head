#!/usr/bin/env bash
set -euo pipefail

TASK="${TASK:-inspect repository}"
SCOPE="${SCOPE:-.}"
OPERATION="${OPERATION:-INSPECT}"

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
    STATUS="Verification placeholder completed"
    ;;
  EDIT)
    STATUS="Edit operation requires explicit handler"
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
