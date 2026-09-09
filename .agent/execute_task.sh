#!/usr/bin/env bash
set -euo pipefail

TASK="${TASK:-inspect repository}"
SCOPE="${SCOPE:-.}"

echo "SH Agent Executor"
echo "Task: $TASK"
echo "Scope: $SCOPE"

git status --short

echo "Executor scaffold ready"
