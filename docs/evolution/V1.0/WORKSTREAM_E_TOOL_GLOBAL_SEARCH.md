# SECOND HEAD V1.0 — WORKSTREAM E TOOL — GLOBAL SEARCH

Status: BOUNDED DESIGN / NOT IMPLEMENTATION
Date: 2026-08-29

## Purpose
Reference Tool for proving the governed read-oriented Tool lifecycle using the existing bounded Global Search capability.

## Boundary
IN: bounded search invocation, SH/account context, authorized query execution, normalized results, audit.
OUT: arbitrary browsing automation, unrestricted crawling, private-data access by implication, external write actions, Tool registry/marketplace.

## Tool vs Action
Tool: Global Search capability.
Action: one concrete search invocation.

## Source strategy
REUSE existing SH capability; ADAPT only where needed to satisfy the generic E contract. Do not rebuild a search engine.

## Contract
Input: bounded query + explicit runtime context.
Authorization: server/runtime side; App/UI is not authority.
Execution: only after eligibility/authorization passes.
Output: normalized result envelope; external result remains untrusted data.
Audit: correlate invocation, outcome, SH context, and source/tool identity using existing audit infrastructure.

## Risk
Read-oriented / low side-effect by default. Risk does not imply permission.

## Failure / containment
Invalid context, unauthorized access, malformed input, provider failure, or timeout must fail closed and must not mutate SH state.

## Dependencies / gaps
Generic invocation envelope, generic authorization bridge, common result/error envelope, and common Tool audit correlation remain E design gaps.

## Exit condition
Design is complete when the concrete existing implementation is mapped to the generic E lifecycle without introducing parallel authority or permission systems.
