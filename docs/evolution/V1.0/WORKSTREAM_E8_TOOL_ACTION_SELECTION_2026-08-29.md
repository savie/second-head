# WORKSTREAM E8 — CONCRETE TOOL/ACTION SELECTION + CONTRACT FREEZE

**Project:** SECOND HEAD V1.0  
**Workstream:** E8  
**Date:** 2026-08-29  
**Status:** AUDIT → MAP → RECONCILE COMPLETE / SELECTION OPEN  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Non-Canonical. This document may evolve; it does not modify Canonical authority.

## 1. Purpose

E8 determines whether current DEV evidence is sufficient to select the first concrete V1.0 Tool/Action vertical slice and freeze its minimum contract.

The rule is evidence-first: do not choose a provider or Tool first and retrofit SH governance afterward.

## 2. Source hierarchy

- Canonical SH documents remain conceptual authority.
- Implementation Contract / Guide / Execution Strategy constrain implementation when implementation begins.
- Evolution documents define the current working plan.
- Resume/history is context only.
- DEV GitHub is implementation evidence.
- Supabase DEV is runtime/database evidence.

E8 does not promote working product direction into Canonical.

## 3. Evidence found

GitHub DEV confirms:
- Capability / Tool / Action are established as Workstream E vocabulary.
- Existing Runtime is primarily the model/conversation execution path.
- Existing file/attachment and multimodal capability evidence exists, but does not establish a governed generic Tool executor.
- Existing documentation references web retrieval, calendar management, image generation, and file processing as capability/tool directions.
- No verified generic Tool adapter, registry, or concrete governed external Tool Action implementation was found during the E7/E8 search.

Product Direction also explicitly treats Tools/Extensions as capability direction and warns against exposing a button merely because a capability exists.

## 4. Candidate assessment

| Candidate | Capability direction | Complete governed Tool/Action path | E8 result |
|---|---:|---:|---|
| Web retrieval | 🟢 | 🔴 | Not selected |
| Calendar | 🟢 | 🔴 | Not selected |
| Image generation | 🟢 | 🔴 | Not selected |
| File processing | 🟢 | 🔴 | Not selected |

These are not rejected as future Tools. They are simply not proven implementation-ready by current DEV evidence.

## 5. Selection criteria

The first Tool/Action must have:
1. clear Capability;
2. one bounded Action;
3. explicit target/context;
4. Runtime-only execution;
5. concrete identity/authorization mapping;
6. inspectable result;
7. audit correlation;
8. known risk classification;
9. minimal external ecosystem dependency;
10. a contract that can be tested end-to-end.

## 6. Contract-freeze decision

A full generic Tool contract is not frozen at E8 because no concrete Tool has been evidenced strongly enough to justify it.

E8 freezes the minimum semantic contract that every selected first slice must satisfy:

Capability → Tool → Action → Invocation → Authorization → Risk/Confirmation → Execution Eligibility → Adapter → Execution → Result → Audit

Physical schema, adapter API, registry mechanism, and universal result model remain open until a concrete Tool is selected.

## 7. Built-in-first principle

If a suitable built-in/internal Tool is discovered in DEV, it should be preferred for the first proof slice because it minimizes new ecosystem dependencies.

This is a working design preference, not Canonical.

If no suitable built-in Tool exists, an external provider may be considered only after provider boundary is explicit; SH governance remains Runtime-owned; authorization is not delegated; private-data access is not inferred from capability; and risk/confirmation remains SH-controlled.

## 8. Critical non-selection

E8 deliberately does not select Web, Calendar, Image Generation, or File Processing merely because they appear in planning material.

Doing so now would create a false implementation premise.

Therefore: **No concrete Tool/Action is promoted to implementation-ready status in E8.**

## 9. What E8 closes

- evidence-based selection criteria;
- minimum semantic contract;
- built-in-first selection principle;
- provider boundary;
- non-selection of unsupported candidates;
- prohibition against retrofitting governance after provider selection.

## 10. What remains open

1. concrete first Tool;
2. concrete Action;
3. actual implementation/provider evidence;
4. exact authorization mapping;
5. exact risk class;
6. exact result envelope;
7. adapter contract;
8. whether registry is ever needed.

## 11. Status

**E8 = 🟡 BOUNDED DESIGN ACCEPTED / CONCRETE SELECTION BLOCKED BY EVIDENCE**

This is an evidence blocker, not a Canonical blocker.

No implementation is authorized.

## 12. Next candidate

**E9 — Existing DEV Capability-to-Action Mining**

Before inventing a new Tool, E9 should inspect existing DEV source/runtime capabilities more deeply and identify whether an already-working internal operation can be formalized as the first governed Action.

If such an operation is found, it becomes the candidate for the vertical slice. If not, E9 should explicitly document the evidence gap and define the smallest new Tool boundary without implementing it.
