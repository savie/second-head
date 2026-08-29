# WORKSTREAM E9 — EXISTING DEV CAPABILITY-TO-ACTION MINING

**Project:** SECOND HEAD V1.0  
**Workstream:** E9  
**Date:** 2026-08-29  
**Status:** AUDIT → MAP → RECONCILE COMPLETE / TOOL LANDSCAPE MAPPED  
**Implementation:** NOT AUTHORIZED

> Living evolution/design document. Non-Canonical. No implementation or schema mutation is authorized by this document.

## 1. Purpose

E9 mines existing DEV capabilities and operations to identify reusable foundations for the Workstream E Tool/Action system.

**Important correction:** E9 does not make Global Search the scope or architectural center of Workstream E. Global Search is retained only as the strongest currently evidenced **reference vertical-slice candidate**.

The Workstream E system must remain extensible to additional built-in Tools, extensions, plugins, and future providers without allowing those mechanisms to bypass SH governance.

## 2. Evidence hierarchy

- Canonical SH documents remain conceptual authority.
- Implementation Contract / Guide / Execution Strategy constrain implementation.
- Evolution documents are living working design.
- Resume/history is contextual input only.
- GitHub DEV is implementation evidence.
- Supabase DEV is running backend/database evidence.

## 3. Existing DEV capability / operation map

### A — Global Search
- `app/services/global-search.ts`
- `globalSearch({ shId, query, limit, offset, domains })`
- backend: `global_search_bounded`
- read-oriented, bounded, explicit SH context.
- **Assessment: 🟢 strongest reference-slice candidate.**

### B — SH Context
- `app/services/context.ts`
- `loadSHContext(...)`
- uses `assemble_context` and bounded Journey retrieval.
- primarily internal Runtime context assembly.
- **Assessment: 🟡 foundation; not automatically a Tool.**

### C — Journey operations
- `app/features/journey/journey-service.ts`
- includes retrieval/classification plus state-changing operations such as deletion/transfer.
- **Assessment: 🟡 reusable domain operations; individual Actions require separate governance/risk treatment.**

### D — Model/provider capabilities
- `functions/runtime-p4a-001/sh_runtime_bundle.ts`
- includes provider adapters and image-generation capability.
- These demonstrate existing provider/runtime capability, but do not prove a generic governed Tool executor.
- **Assessment: 🟡 provider foundation; not automatically a Tool.**

### E — Runtime governance foundations
Supabase DEV exposes Runtime operations including:
- `runtime_assert_active_sh`
- `runtime_record_audit`
- `runtime_confirm_high_risk_action`
- `runtime_create_high_risk_confirmation`
- `runtime_execute_high_risk_action`
- `global_search_bounded`
- `assemble_context`
- Journey/lifecycle and memory/knowledge/experience Runtime operations.

These are reusable foundations. They are not to be reinterpreted as an already-existing generic Tool registry/executor.

## 4. Tool landscape principle

The existence of an operation does **not** automatically make it a Tool.

Likewise:
- Capability ≠ Tool;
- Tool ≠ Action;
- Tool availability ≠ authorization;
- Tool ≠ authority;
- provider ≠ authority;
- plugin ≠ authorization;
- private-data capability ≠ private-data permission.

A Tool becomes governed only when its concrete Actions pass the SH Runtime governance boundary.

## 5. Extensible Tool classes

The Workstream E design must be able to accommodate, when justified:
- built-in/internal Tools;
- extension Tools;
- plugin/provider-backed Tools;
- future Tools not yet known.

No fixed V1.0 Tool inventory is declared here.

No plugin marketplace/ecosystem is being designed as part of E merely to achieve extensibility.

## 6. Global Search role

Global Search remains the preferred **reference vertical slice** because it is already implemented, bounded, read-oriented, and has an inspectable result shape.

Proposed semantic identifiers remain provisional:
- Capability: `GLOBAL_SEARCH`
- Tool: `SH_GLOBAL_SEARCH`
- Action: `SEARCH_SH`

These are working design identifiers only. They are not Canonical and do not constitute an implementation contract yet.

The reference slice must prove the generic governance lifecycle; it must not dictate the architecture of every future Tool.

## 7. Generic lifecycle to preserve

Every Tool/Action mechanism must be able to fit the governed lifecycle:

Capability
→ Tool
→ Action
→ Invocation
→ Actor + SH context
→ Authorization
→ Risk classification
→ Confirmation when required
→ Execution eligibility
→ Tool/extension adapter
→ Concrete execution
→ Result
→ Audit

Tool-specific implementation may differ, but governance ownership remains with SH Runtime.

## 8. Extensibility boundary

Future Tool/plugin/extension support must preserve:

1. **SH owns authorization.**
2. **SH owns risk classification.**
3. **SH owns confirmation gates.**
4. **SH owns execution eligibility.**
5. **SH owns audit correlation.**
6. **External provider/plugin cannot become authority.**
7. **A Tool cannot directly infer private-data permission.**
8. **No unrestricted autonomous execution path is introduced.**
9. **Plugin/extension does not receive implicit access merely because it exists.**
10. **Tool output is result data, not SH authority.**

These are bounded design principles, not permission to implement an ecosystem.

## 9. Registry position

E6 remains valid: a physical generic registry is not required merely because the system is extensible.

Static binding is acceptable for an initial slice.

Registry/discovery/configuration becomes a new design requirement only if later evidence demonstrates a real need such as dynamic lifecycle, discovery, enable/disable, version negotiation, or equivalent runtime behavior.

## 10. Selection rule

When choosing a concrete reference Tool:
1. prefer an existing bounded internal operation where appropriate;
2. otherwise define the smallest new Tool boundary;
3. do not select a provider first and retrofit SH governance;
4. do not let the first Tool become the universal architecture by accident.

## 11. E9 decision

**E9 = 🟢 TOOL LANDSCAPE / REUSABLE FOUNDATION MAPPED.**

Global Search is retained as a **reference candidate**, not as Workstream E scope.

No implementation is authorized.

## 12. Next candidate

**E10 — TOOL GOVERNANCE & EXTENSIBILITY BOUNDARY**

E10 should define the common governance contract for all future Tool classes—built-in, extension, plugin/provider-backed—while explicitly bounding authority, authorization, risk, confirmation, execution, result, and audit.

Global Search may be used as an example/test case inside E10, but E10 must not be designed solely around it.
