# SECOND HEAD — Tool / Action Generalization — Step 6 Completion

## Status

**WORKING / IMPLEMENTED — STEP 6 COMPLETE FOR CURRENT REPRESENTATIVE SCOPE**

Dokumen ini adalah working completion record. Bukan Canonical dan tidak mengubah Approved Contract.

Branch kerja repository: `dev`

## 1. Authority

Urutan authority tetap:

```text
Owner / User Decision
↓
Canonical
↓
Approved Contract
↓
Architecture / Design
↓
Current Implementation
↓
Historical evidence
```

Architecture Step 6 menetapkan:

1. common Tool contract;
2. Action lifecycle;
3. authorization/risk gate;
4. normalized result/error;
5. audit/event contract;
6. representative tools secara bertahap;
7. connector/MCP sebagai integration boundary.

Dokumen ini menurunkan requirement tersebut ke implementation tanpa mengubah semantics SH.

## 2. Implementation Result

### 2.1 Common Tool contract — DONE

Flutter contract baru:

`app/lib/capabilities/tools/tool_action_contract.dart`

Menyediakan:

- `ToolDefinition`;
- `ToolRisk`;
- `ToolActionRequest`;
- `ToolActionStatus`;
- `ToolActionResult`;
- `ToolActionExecutor`.

Contract memisahkan capability definition, action request, lifecycle state, normalized result, dan audit outcome.

### 2.2 Action lifecycle — DONE

Lifecycle yang distabilkan:

```text
PROPOSED
→ AWAITING_CONFIRMATION
→ EXECUTING
→ SUCCEEDED
```

Failure/rejection state:

```text
FAILED
REJECTED
```

Tool yang membutuhkan confirmation tidak boleh langsung dieksekusi.

### 2.3 Authorization / risk gate — DONE

Backend boundary baru:

`functions/runtime-tool-action/index.ts`

Function menggunakan:

```text
JWT required
↓
auth.getUser()
↓
resolve_identity()
↓
resolved SH identity
↓
tool registry
↓
risk / confirmation gate
↓
execution
```

UI confirmation bukan authorization. Authorization tetap berasal dari authenticated backend identity.

### 2.4 Normalized result / error — DONE

Semua execution melalui normalized envelope:

```text
status
↓
tool
↓
action
↓
result.output
```

Failure menggunakan:

```text
status: FAILED
error.code
error.message
action_id
tool_id
```

Provider-specific response tidak menjadi contract aplikasi.

### 2.5 Audit / event — DONE

Request dan response dicatat melalui existing:

`runtime_record_audit`

Metadata minimal mencakup:

- tool id/version;
- action id;
- risk;
- authorization classification;
- confirmation state;
- success/failure;
- normalized result boundary;
- error code bila gagal.

Tidak dibuat audit system kedua.

### 2.6 Representative tools — DONE

Registry awal menggunakan existing capability boundaries:

| Tool | Risk | Confirmation | Boundary |
|---|---|---:|---|
| `R8_SEARCH_YOUTUBE` | READ_ONLY | No | YouTube MCP |
| `R8_GET_YOUTUBE_VIDEO` | READ_ONLY | No | YouTube MCP |
| `R6_CREATE_TASK` | LOW | Yes | existing `r6_create_task` RPC |

Dengan demikian Step 6 tidak membuat provider baru atau menggandakan R6/R8 implementation. Generic bridge hanya menjadi execution boundary di atas capability yang sudah ada.

## 3. MCP / Connector Boundary

YouTube tetap berada di bawah MCP boundary.

```text
SH Tool Contract
↓
R8 Tool Adapter
↓
MCP
↓
YouTube provider
↓
Normalized result
```

MCP tidak menjadi authority SH.

R6 tidak menggunakan MCP karena capability persistence sudah tersedia melalui existing backend RPC.

## 4. Security Boundary

Function `runtime-tool-action` di-deploy dengan `verify_jwt=true`.

Current deployed state pada Supabase DEV:

```text
name: runtime-tool-action
status: ACTIVE
version: 1
verify_jwt: true
```

Backend tetap menjadi authority untuk identity dan authorization.

Tool registry tidak menerima account/sh identity dari client sebagai authority.

## 5. Repository Changes

Added:

```text
app/lib/capabilities/tools/tool_action_contract.dart
functions/runtime-tool-action/index.ts
docs/working/tools/sh_tool_action_generalization_step6_completion.md
```

Commit implementation utama:

```text
1cf1e787ed144b5175900aab1415292735f88bcd
feat(tools): add common Tool and Action contract
```

```text
af5ffa63e00a588476ad145fabb103afa27ba827
feat(tools): add normalized Tool Action execution boundary
```

Supabase DEV deployment:

```text
runtime-tool-action
version 1
status ACTIVE
verify_jwt true
```

## 6. Verification Classification

| Requirement | Status |
|---|---|
| Common Tool contract | **IMPLEMENTED** |
| Action lifecycle | **IMPLEMENTED** |
| Authorization boundary | **IMPLEMENTED / RUNTIME DEPLOYED** |
| Risk gate | **IMPLEMENTED** |
| Confirmation gate | **IMPLEMENTED** |
| Normalized result | **IMPLEMENTED** |
| Normalized error | **IMPLEMENTED** |
| Audit/event contract | **IMPLEMENTED** |
| Representative R8 tools | **IMPLEMENTED / PROVIDER-DEPENDENT** |
| Representative R6 tool | **IMPLEMENTED / RPC-DEPENDENT** |
| MCP containment | **IMPLEMENTED** |
| Authenticated positive execution | **NOT YET DEVICE/E2E VERIFIED** |
| Provider live verification | **NOT CLAIMED** |

## 7. Important Boundary

Step 6 dinyatakan **complete at implementation/contract level for the current representative scope**, bukan berarti semua external tools SH sudah tersedia.

Yang belum termasuk Step 6 completion:

- seluruh external capability inventory;
- Google Calendar genericization beyond existing representative path;
- broad tool catalog;
- provider switching;
- device/E2E verification seluruh tools;
- confirmation UX pada semua frontend surfaces.

Itu menjadi follow-up verification/expansion, bukan alasan untuk membuat ulang generic bridge.

## 8. Next Gate

Step berikutnya tidak boleh mengulang generic Tool/Action architecture.

Gunakan bridge ini sebagai boundary untuk:

```text
Step 7 — Multimodal / File
```

atau verification hardening yang diperlukan sebelum capability expansion.

## 9. Conclusion

Step 6 berhasil menutup GAP generic Tool/Action bridge yang sebelumnya tercatat pada inventory.

Hasilnya menjaga boundary:

```text
SH Runtime
↓
Tool Contract
↓
Authorization / Risk
↓
Confirmation bila diperlukan
↓
Action Execution
↓
Adapter / MCP / RPC
↓
Normalized Result
↓
Audit
```

Tidak ada perubahan Canonical atau SH semantics.
