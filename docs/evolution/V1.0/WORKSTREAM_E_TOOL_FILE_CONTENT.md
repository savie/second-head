# SECOND HEAD V1.0 — WORKSTREAM E TOOL — FILE CONTENT

Status: BOUNDED DESIGN / NOT IMPLEMENTATION
Date: 2026-08-29

## Purpose
Representative artifact capability covering file reading, extraction, and bounded transformation without turning E into a generic file platform.

## Boundary
IN: explicitly supplied/authorized file content; text extraction; bounded transformation of that content.
OUT: arbitrary filesystem access, silent export, unrestricted file creation, external sharing, private-data permission bypass.

## Tool vs Action
Tool: File Content capability.
Actions: READ/EXTRACT/TRANSFORM on one explicitly bound artifact.

## Source strategy
REUSE existing attachment/file handling where possible. ADAPT an existing parser/converter rather than building generic document infrastructure unless SH-specific behavior requires BUILD.

## Contract
Input binds the artifact and requested operation.
Authorization is evaluated before content access or transformation.
Transformation does not automatically grant permission to export/share the result.
Output is a bounded artifact/text/result envelope with provenance.

## Risk
READ/EXTRACT generally low side effect; TRANSFORM is bounded state-local processing. Export/share/create operations are separate Actions and are not implicitly included.

## Audit
Record artifact reference, operation, outcome, and provenance using existing audit infrastructure without storing unnecessary full sensitive payloads.

## Failure / containment
Unsupported type, malformed content, authorization failure, size/resource limit, or parser failure => fail closed; no unintended external mutation.

## Dependencies / gaps
Exact existing attachment/runtime primitive mapping, generic invocation/result envelope, and export/share boundary.

## Exit condition
The selected existing file capability is proven to fit the E boundary without introducing a parallel storage/authority system.
