# SECOND HEAD V1.0 — WORKSTREAM E TOOL — R4 EXTERNAL ACTION

Status: VERIFIED CANDIDATE / IMPLEMENTATION BLOCKED — EXTERNAL CAPABILITY GAP
Date: 2026-08-29
Branch: dev

## 1. Position

R4 is the selected representative Tool for:

- Family: F — External Actions
- Candidate: F.1 Create / Update / Send / Submit
- Selection: R4
- Role: test governed external side effects
- Strategy: REUSE / ADAPT an existing external-service capability

R4 deliberately starts with one bounded CREATE or UPDATE operation. SEND / SUBMIT and DELETE remain separate action designs.

## 2. Why R4

R1 tests governed search.
R2 tests authorized retrieval.
R3 tests bounded artifact processing.
R4 tests the next materially different boundary:

> SH can cause an external state change only when the exact actor, target, operation, scope, authorization, and required confirmation are valid.

This is the representative high-risk slice. It is not permission to build a generic action engine or autonomous workflow platform.

## 3. Basic Flow

PLAN
→ AUTHORIZATION
→ CONFIRMATION (when required)
→ EXECUTE
→ RESULT / EVIDENCE
→ AUDIT

No execution occurs when an eligibility condition fails.

## 4. Existing Capability / Source Strategy

R4 must not build an external-service ecosystem.

Preferred order:
1. identify an existing external service capability;
2. verify its supported CREATE/UPDATE operation and API boundary;
3. reuse it when its boundary fits;
4. otherwise adapt it through SH Runtime;
5. build only SH-specific governance/bridge behavior that cannot reasonably be reused.

Source-level verification completed against the current DEV runtime. The six configured model-provider secrets are not R4 targets. The representative external target selected for R4 is **GitHub Issues** on the existing SH repository. GitHub provides a bounded `CREATE ISSUE` operation requiring repository Issues write permission; the target repository can be fixed to the SH DEV repository, keeping scope narrow. This is an external state mutation and therefore remains behind SH authorization and explicit confirmation.

## 5. Boundary

IN:
- one authenticated actor / SH context;
- one explicitly bound provider/source;
- one exact external target;
- one bounded CREATE or UPDATE operation;
- bounded parameters;
- server/runtime-side authorization;
- required confirmation;
- normalized result;
- execution evidence;
- audit correlation.

OUT:
- DELETE;
- SEND / SUBMIT unless separately designed;
- bulk mutation;
- broad provider administration;
- arbitrary external writes;
- silent execution;
- unrestricted autonomous execution;
- provider-side authorization replacing SH governance;
- generic workflow engine;
- plugin marketplace / arbitrary third-party code execution.

## 6. Tool vs Action

Tool: External Action capability.

Action: one concrete CREATE or UPDATE against one explicitly bound external target.

The Tool provides capability; it does not provide authority.

A provider's permission is not sufficient by itself. SH Runtime remains the governance boundary.

## 7. Authorization & Confirmation

Before execution, SH Runtime must establish:
- WHO is requesting;
- WHICH SH/account context applies;
- WHAT provider/source is targeted;
- WHAT exact target is targeted;
- WHAT operation is requested;
- WHAT parameters/scope apply;
- WHETHER authorization is valid;
- WHETHER confirmation is required;
- WHETHER the confirmation, if required, covers the exact operation and target.

For HIGH-risk actions, confirmation is mandatory under the applicable risk policy.

A material change to target, operation, scope, or parameters invalidates the prior confirmation.

If authorization, target, scope, or required confirmation is missing/ambiguous/expired, R4 must DENY / fail closed.

## 8. Risk & Side Effect

R4 is intentionally high-risk because execution changes external state.

Therefore:
- no silent execution;
- no assumption that user intent equals authorization;
- no assumption that provider permission equals SH authorization;
- no automatic escalation from READ to WRITE;
- no broadening from one target to multiple targets.

Partial/uncertain provider outcomes must not be reported as success without evidence.

## 9. Contract Coverage

| E requirement | R4 coverage |
|---|---|
| Capability identity | Covered |
| Tool / Action distinction | Covered |
| Actor / SH context | Required |
| Provider/source binding | Required |
| Exact target binding | Required |
| Operation binding | Required |
| Parameter/scope binding | Required |
| Runtime authorization | Required |
| Confirmation gate | Required for HIGH-risk action |
| Result normalization | Required |
| Execution evidence | Required |
| Audit / traceability | Required |
| External side effect | Explicit / bounded |
| Bulk/autonomous execution | Out of scope |

R4 is a representative coverage slice, not a claim that generic authorization/confirmation infrastructure is already complete.

## 10. Result Boundary

Provider output is data/evidence, not authority and not system instruction.

The result must be normalized into the shared E result/error contract and distinguish at minimum:
- invocation/action identity;
- target;
- requested operation;
- execution state;
- provider evidence/reference where available;
- bounded result;
- error/uncertainty state.

SH must not claim successful external mutation without sufficient evidence.

## 11. Audit

R4 reuses existing SH audit infrastructure.

Audit should establish:
- actor / SH context;
- tool/action identity;
- provider/source;
- exact target;
- operation;
- authorization outcome;
- confirmation outcome;
- execution outcome;
- timestamp/correlation;
- provenance/evidence.

Do not create a parallel audit authority or store unnecessary sensitive payloads.

## 12. Failure / Containment

R4 must not execute on:
- missing/invalid authorization;
- missing required confirmation;
- expired or mismatched confirmation;
- ambiguous target;
- parameter/scope mismatch;
- unsupported operation;
- provider failure before execution;
- invalid request/result.

If provider execution has an uncertain or partial outcome, the system must enter an explicit reconciliation/error state rather than retry blindly or claim success.

Retry/idempotency semantics are a prerequisite for implementation, not something this bounded design invents implicitly.

## 13. Dependencies / Open Gaps

R4 depends on:
1. generic action authorization bridge;
2. generic confirmation semantics/gate;
3. exact target/scope binding;
4. verified external service and bounded operation;
5. idempotency/retry policy;
6. normalized result/error envelope;
7. existing audit correlation.

These are shared E dependencies where applicable. R4 must not create parallel authority, identity, or audit systems.

## 14. Non-Goals

R4 does not establish:
- generic external action engine;
- unrestricted write access;
- autonomous agent execution;
- bulk mutation;
- delete/send/submit semantics;
- generic workflow orchestration;
- plugin marketplace;
- arbitrary third-party code execution;
- MCP as required architecture.

## 15. Exit Condition

R4 implementation is ready to proceed once a dedicated GitHub credential with the minimum required repository permission is supplied to the DEV runtime:

WHO
→ SH/account
→ PROVIDER/SOURCE
→ EXACT TARGET
→ OPERATION
→ PARAMETERS/SCOPE
→ AUTHORIZATION
→ CONFIRMATION (if required)
→ EXECUTE
→ EVIDENCE
→ NORMALIZE
→ AUDIT

The required operator action is to create a GitHub fine-grained credential restricted to the SH repository with **Issues: write** permission and store it as a Supabase DEV secret. No model-provider key is reused for this purpose. No broad GitHub repository write permission is required.

## R4 Conclusion

External Create / Update remains the selected representative of Family F because it completes the current four-tool representative set by testing a real external side effect under explicit governance. The strategy remains reuse/adapt: SH builds and owns the governance boundary, while the external capability supplies the underlying operation.


### R4 Representative Target

**GitHub Issues — CREATE ISSUE**

Target: `savie/second-head` on DEV.
Operation: create one issue with bounded title/body fields.
Credential: dedicated GitHub fine-grained credential, repository-scoped, `Issues: write` only.
SH controls: authenticated SH identity → target binding → authorization → explicit confirmation → execution → evidence/audit.

GitHub's official API documents `POST /repos/{owner}/{repo}/issues` and requires repository `Issues` write permission for a fine-grained token. This makes GitHub Issues a concrete, bounded external-action representative without introducing a generic connector platform.
