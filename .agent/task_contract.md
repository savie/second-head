# SH Agent Task Contract

## Purpose
Define the minimum contract between task input and executor behavior.

## Task Fields

- TASK: requested operation
- SCOPE: allowed repository scope

## Allowed Initial Operations

### INSPECT
Read state and report findings.

### VERIFY
Run checks and report results.

### EDIT (future)
Requires explicit file target and change specification.

## Safety Rules

- Only operate inside declared scope.
- Do not modify files outside scope.
- Produce diff before commit.
- Commit only verified changes.
- Keep execution report.
