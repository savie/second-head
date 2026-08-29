# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R3 FILE CONTENT / EXTRACT / TRANSFORM

Status: **IMPLEMENTED / CI VERIFIED / RUNTIME-SPECIFIC EVIDENCE PENDING**
Date: 2026-08-29
Branch: dev

## 1. Position

R3 is the selected representative Tool for Family C — Files & Content.
Candidate: C.1 File Content / Extract / Transform.
Role: test bounded artifact processing without creating a generic file platform.
Strategy: REUSE / ADAPT existing attachment/file capability where valid.

R3 covers content processing of an explicitly supplied/authorized artifact. It does not become a general filesystem, storage, sharing, or file-management system.

## 2. Why R3

R1 tests governed search.
R2 tests the boundary between connection/capability and permission to read data.
R3 tests a different boundary:

> SH may process an artifact that is explicitly supplied and authorized, but processing that artifact does not grant broader rights over the artifact or its result.

This gives the representative set bounded content handling without introducing an external write side effect.

## 3. Basic Flow

artifact supplied → identify actor + SH/account → bind exact artifact → identify operation READ / EXTRACT / TRANSFORM → authorization/scope check → process → normalize result + provenance → audit.

If the artifact, operation, scope, or authorization cannot be established unambiguously, processing does not proceed.

## 4. Existing Capability / Source Strategy

R3 should not build a generic document/file platform.

Preferred order:
1. identify the existing attachment/file-handling capability available to SH;
2. verify the concrete parser/extractor/converter capability needed;
3. reuse it directly when its boundary already fits;
4. otherwise adapt it through the SH Runtime boundary;
5. build only SH-specific behavior that cannot reasonably be reused/adapted.

The first verified implementation is the existing SH Runtime attachment path. It accepts exactly one explicitly supplied artifact and currently supports text/plain, text/markdown, text/csv, application/json, application/xml, and text/xml. No generic filesystem or external file provider is introduced.

## 5. Boundary

IN:
- one explicitly supplied/authorized artifact;
- one bounded operation;
- authenticated actor / SH context;
- permitted content access;
- bounded processing;
- normalized output;
- provenance;
- audit correlation.

OUT:
- arbitrary filesystem access;
- arbitrary path traversal;
- unrestricted bulk file access;
- silent export;
- automatic external sharing;
- unrestricted file creation;
- deletion or mutation of external files;
- private-data permission bypass;
- new storage/authority system;
- generic document-management platform.

## 6. Tool vs Action

Tool: File Content / Extract / Transform capability.
Actions: bounded READ, EXTRACT, or TRANSFORM against one explicitly bound artifact.

The Tool provides capability; it does not provide authority.

Processing a file does not imply permission to export, share, publish, create an external record, or modify the original externally. Those are separate governed operations.

## 7. Authorization & Ownership

Before processing, SH Runtime must establish:
- WHO is requesting;
- WHICH SH/account context applies;
- WHAT artifact is targeted;
- WHAT operation is requested;
- WHAT scope applies;
- WHETHER the request is authorized.

For an explicitly supplied file, possession/supply is context but must not become blanket authority for subsequent operations.

If authorization or scope is ambiguous, R3 must deny/fail closed rather than guess.

## 8. Risk / Resource Boundary

R3 is normally low side-effect because processing is bounded and local to the supplied artifact.

Resource limits remain relevant: file size, page/record count, parser complexity, processing time, memory/compute limits, and unsupported or potentially unsafe formats.

Resource exhaustion must fail safely. It must not cause scope expansion or fallback to an unbounded source.

TRANSFORM means bounded content transformation. It does not include external export/share/create/update.

## 9. Contract Coverage

| E requirement | R3 coverage |
|---|---|
| Capability identity | Covered |
| Tool identity | Covered |
| Actor / SH context | Required |
| Artifact binding | Required |
| Operation binding | Required |
| Authorization | Required |
| Ownership / privacy boundary | Explicit |
| Result normalization | Required |
| Provenance | Required |
| Audit / traceability | Required |
| Resource bounds | Explicit |
| External side effect | Out of scope |
| Confirmation | Normally not required for bounded local processing; contextual policy may escalate |

R3 is a representative coverage slice. It does not imply a generic file framework already exists.

## 10. Result Boundary

The processed result is data, not authority.

The result should remain bounded and provenance-aware and identify, conceptually: invocation identity, artifact reference, operation, success/failure, bounded result, provenance, metadata, and error information where applicable.

The exact generic result envelope belongs to the shared E contract; R3 must consume it rather than invent a parallel envelope.

## 11. Audit

Each R3 invocation remains traceable through existing SH audit infrastructure.

Audit should establish actor/SH context, artifact reference, requested operation, authorization outcome, execution outcome, provenance, and timing/correlation.

Do not store unnecessary full sensitive file contents in audit metadata.
R3 must reuse the existing audit primitive rather than create a parallel audit authority.

## 12. Failure / Containment

R3 must fail closed for missing/invalid artifact binding, authorization failure, unsupported type, malformed/corrupt content, size/resource limit exceeded, parser/extractor/converter failure, or invalid normalized result.

Failure must not expose content outside the authorized scope, silently export/share content, mutate an external target, or broaden source/artifact scope.

## 13. Dependencies / Open Gaps

R3 depends on:
1. exact existing attachment/file runtime primitive mapping;
2. a verified parser/extractor/converter capability for the selected bounded operation;
3. generic invocation contract;
4. generic authorization boundary;
5. normalized result/error envelope;
6. audit correlation.

These are shared E dependencies. R3 must not create parallel versions of them.

## 14. Non-Goals

R3 does not establish a generic filesystem abstraction, document-management system, unrestricted file access, automatic sharing/export, external file mutation, generic file-storage authority, new identity/ownership system, generic workflow engine, plugin/extension marketplace, or MCP as a required architecture.

## 15. Exit Condition

R3 implementation is complete for the first bounded supplied-artifact slice:

WHO → SH/account → artifact → operation → scope → AUTHORIZED → PROCESS → NORMALIZE + PROVENANCE → AUDIT.

No external parser/provider is required for this first bounded slice; parsing/transformation is limited to the explicitly supported text-based classes.

R3 conclusion: File Content / Extract / Transform is implemented as the selected representative of Family C. It exercises one-artifact binding, bounded operations, resource limits, normalization, provenance, and audit while remaining separate from export, sharing, creation, and external mutation.


## CURRENT DEV AUDIT — 2026-08-29

DEV contains the R3 client boundary plus runtime handling in `runtime-p4a-001`, including one-artifact validation, supported MIME/resource bounds, bounded READ/EXTRACT/TRANSFORM processing, provenance, and audit events. Current DEV CI is GREEN. No separate manual/device runtime acceptance is inferred from CI alone.
