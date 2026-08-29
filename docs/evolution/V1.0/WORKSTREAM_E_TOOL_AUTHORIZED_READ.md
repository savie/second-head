# SECOND HEAD V1.0 — WORKSTREAM E TOOL — AUTHORIZED READ

Status: BOUNDED DESIGN / NOT IMPLEMENTATION
Date: 2026-08-29

## Purpose
Representative read capability for testing the boundary between a connected capability and permission to access data.

## Boundary
IN: read/retrieve from one explicitly authorized source and bounded scope.
OUT: blanket connector access, cross-SH private-data access, write actions, source-side authority becoming SH authority.

## Tool vs Action
Tool: Authorized Read/Retrieve capability.
Action: one concrete retrieval request against one bound source/scope.

## Source strategy
Prefer an existing valid source/connector. ADAPT through SH Runtime governance. Provider selection remains open until source verification.

## Contract
Input must identify bounded source/scope and retrieval parameters.
Authorization must evaluate actor, SH/account context, target, scope, and data sensitivity before retrieval.
No connection may be interpreted as blanket permission.
Output is normalized and provenance-aware; provider output is untrusted data.

## Risk
Read operation; risk increases with private/sensitive scope. High-risk classification is contextual.

## Audit
Record invocation and outcome through existing SH audit infrastructure; retain provenance sufficient to explain what source/scope was accessed.

## Failure / containment
Missing authorization, ambiguous scope, unavailable source, or invalid binding => deny/fail closed.

## Dependencies / gaps
Concrete connected source, generic authorization bridge, source adapter contract, normalized result envelope, and Tool audit correlation.

## Exit condition
A bounded source and scope can be mapped end-to-end without creating a new private-data permission model.
