# EV-BUG-002 — MEMORY PERSISTENCE POLICY / DUPLICATE PREVENTION

Status: **FIXED + VERIFIED**

## Scope
Memory persistence behavior, explicit-save semantics, retrieval non-persistence, and duplicate prevention.

## Problem
Ordinary conversation could previously cause Memory to be persisted automatically without an explicit request.

Required behavior:

`ordinary conversation → NO automatic Memory persistence`

`explicit remember/save as Memory → Memory may be persisted`

`explicit opt-out → hard boundary / do not persist`

## Historical evidence
Earlier implementation could create duplicate Memory records on repeated explicit save.

Those historical duplicates are retained as evidence/history and are not to be deleted merely to make current state appear clean.

## Fix / reconciliation
Behavior and deduplication were corrected.

Verified expected behavior:

- ordinary statement does not create Memory/Experience;
- explicit Memory request creates Memory;
- Memory recall works;
- repeated explicit save of the same Memory does not create a new duplicate;
- ordinary paraphrase does not create Memory;
- retrieval does not create Memory.

## Verification
Behavior was verified on device.

## Evidence basis
Reconstructed from Session Resume 68. The Resume records the historical duplicate evidence and the final verified behavior; this EV does not invent additional test identifiers or database evidence.

## Final
**🟢 FIXED + VERIFIED**

Historical duplicate evidence remains preserved.
