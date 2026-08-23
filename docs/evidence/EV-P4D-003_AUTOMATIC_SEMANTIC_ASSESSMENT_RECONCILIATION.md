# EV-P4D-003 — Automatic Semantic Assessment Reconciliation

Status: OPEN / FIX COMMITTED — awaiting CI + real E2E verification

## Trigger

APK #191 reproduced a semantic-acquisition failure:

- User message: `Saya suka kopi hitam dan biasanya minum kopi hitam setiap pagi sebelum mulai bekerja.`
- SH produced a natural-language acknowledgement saying the preference would be remembered.
- No new Memory, Knowledge, or Experience record appeared; only pre-existing records were visible.

## Trace

```text
User message
  ↓
P4D model adapter
  ↓
semantic_signals
  ├─ memory_candidate
  ├─ knowledge_candidate
  └─ journey_candidate
  ↓
P4A decision / P3D acquisition
  ↓
persistence
  ↓
Memory / Knowledge / Experience UI
```

P4D candidate formation is intentionally explicit: ordinary prose is not converted into a candidate by the formation helper. Downstream Memory consumes `semantic_signals.memory_candidate`, while Knowledge consumes `semantic_signals.knowledge_candidate`.

## Root cause identified

The production `runtime-p4a-001/sh_runtime_bundle.ts` already described automatic semantic assessment, but its provider request did not enforce a structured response envelope. The model could therefore return a natural-language `response` without a machine-readable semantic candidate. The downstream sinks correctly received no candidate and therefore had nothing to persist.

The modular OpenRouter adapter had the same weakness in its prompt/schema contract: `semantic_signals` was optional and the prompt did not explicitly require a durable preference such as the coffee example to produce a candidate.

## Fix

Committed on `dev`:

- `a77a42708aa350b5a0e1df09c19b376b9ac108ba` — production runtime bundle now requires a two-field structured response and explicitly instructs automatic semantic assessment; provider payload uses a JSON-schema response format with required `response` and `semantic_signals`.
- `959caaf3822f80e4bf2a55574d220eefe2f8d69d` — modular OpenRouter P4D adapter reconciled to the same contract and durable-preference behavior.

The fix does **not** make P4D infer candidates from ordinary prose deterministically. It strengthens the model-output contract so the model must place warranted semantic proposals in the machine-readable `semantic_signals` envelope consumed by downstream decision layers.

## Verification required

1. CI/typecheck/tests pass.
2. Deploy the runtime fix.
3. Build the next APK.
4. Repeat the exact coffee-preference E2E message without a `do not capture` marker.
5. Verify a **new** Memory and/or Knowledge/Experience record appears after the test message, rather than relying on historical records.

Until those checks pass, automatic semantic acquisition remains RED.
