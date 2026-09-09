#!/usr/bin/env bash
set -euo pipefail

TASK="${TASK:-inspect repository}"
SCOPE="${SCOPE:-.}"

REPORT_FILE=".agent/execution-report.md"

fail() {
  echo "ERROR: $1"
  exit 1
}

echo "SH Agent Executor"
echo "Task: $TASK"
echo "Scope: $SCOPE"

if [[ "$SCOPE" == "" ]]; then
  fail "scope is required"
fi

if [[ ! -e "$SCOPE" ]]; then
  fail "scope does not exist: $SCOPE"
fi

cat > "$REPORT_FILE" <<EOF
# SH Agent Execution Report

## Task
$TASK

## Scope
$SCOPE

## Status
Executor initialized successfully.
EOF

echo "Workspace status:"
git status --short

echo "Diff preview:"
git diff --stat

echo "Executor contract complete"
