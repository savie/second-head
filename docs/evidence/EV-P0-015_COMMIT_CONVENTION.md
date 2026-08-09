# EV-P0-015 — COMMIT CONVENTION (BL-P0-015)

Project: SECOND HEAD — SYSTEM BUILD
Evidence ID: EV-P0-015
Backlog Item: BL-P0-015 (Commit Convention)
AC Ref: AC-DEV-05
Phase: Phase 0
Status: DONE / PASS (Owner-verified)
Closure Mode: VERIFICATION-ONLY / DEFERRED-STRUCTURE
Date: 2026-08-09
Repository: savie/second-head (GitHub)
Supabase Project: second-head (ref: pkhkgvsrqeupvwoqjwmd, region: ap-northeast-2)

## 1. PURPOSE & CLOSURE
- Evidence closure BL-P0-015 (Commit Convention) untuk Phase 0.
- Closure mode: VERIFICATION-ONLY / DEFERRED-STRUCTURE.
- Konvensi commit didokumentasikan sebagai ADVISORY repository convention,
  BUKAN canonical requirement dan BUKAN enforced policy.
- Tidak ada enforcement tooling yang diperkenalkan oleh closure ini.

## 2. AUTHORITY & TRACEABILITY
- Backlog: BL-P0-015 | Commit Convention | P2 | dep: none | AC-DEV-05.
- AC-DEV-05 bersifat ID-only; tidak ada teks acceptance canonical di frozen
  authority set. FLAG-015-AC dipertahankan: jangan mengarang teks AC.
- Build Scope: setiap perubahan implementasi harus classified & controlled;
  NO SILENT CHANGE (reason / what / when / actor / impact / result / version).
- Implementation Spec: keputusan implementasi wajib traceable.
- Konvensi di bawah adalah engineering/repository convention yang diturunkan dari
  praktik teramati + prinsip traceability; BUKAN canonical invariant.

## 3. ACTUAL REPO CONDITION (READ-ONLY, VERIFIED)
- Repository: savie/second-head; working branch dev; stable branch main.
- History commit Phase 0 mengikuti pola conventional-commit-style yang konsisten:
  - `docs: add EV-P0-00X ... (DONE/PASS, Owner-verified)`
  - `docs: normalize ...`
- History linear; tidak ada merge commit; tidak ada force-push teramati.
- Tidak ada commitlint, hooks, CI commit-check, atau GitHub enforcement.

## 4. ADVISORY COMMIT CONVENTION (DOCUMENTED, NOT ENFORCED)
Format:
  <type>: <description>
- type (advisory set): docs | chore | feat | fix | test | refactor
  (ekspansi set = keputusan Owner).
- description: ringkas; mereferensikan BL-/EV- ID bila commit memajukan/menutup
  item backlog/evidence.
- Suffix status opsional selaras state evidence, mis. `(DONE/PASS, Owner-verified)`.
Aturan (advisory):
- Satu perubahan logis per commit.
- Jaga history linear; hindari merge commit bila praktis.
- No force-push pada branch shared (dev/main).
- Commit message harus membuat perubahan traceable (BL/EV mana yang dilayani).
- Konvensi bersifat advisory; pelanggaran = review note, bukan blocked commit.

## 5. NOT ENFORCED (DEFERRED / OPEN)
- Tidak ada konfigurasi commitlint.
- Tidak ada git hooks (client/server).
- Tidak ada CI commit-message check (BL-P0-013 deferred).
- Tidak ada GitHub branch-protection / required-status enforcement (BL-P0-014 deferred).
- Enforcement tetap OPEN (FLAG-015-ENF); dapat ditinjau ulang saat CI (BL-P0-013)
  dan toolchain ada dan Owner memutuskan.

## 6. FLAGS
- FLAG-015-AC: AC-DEV-05 ID-only; tidak ada teks canonical; tidak ada invention.
- FLAG-015-FMT: format/type set advisory, tidak binding; ekspansi = keputusan Owner.
- FLAG-015-ENF: enforcement/tooling (commitlint/hooks/CI/GitHub) deferred — OPEN.

## 7. BOUNDARY
- BL-P0-013 (CI Pipeline): commit-check via CI milik item tersebut; deferred; untouched.
- BL-P0-014 (Branching Strategy): policy branch/merge/protection terpisah; untouched.
- BL-P0-016 (Migration Tooling): penamaan/versioning migration terpisah; untouched.
- Evidence ini tidak mendefinisikan migration file naming, branch protection, atau CI gate.

## 8. ACTIONS NOT TAKEN (BY DESIGN)
- Tidak membuat commitlint / hooks / CI / GitHub enforcement.
- Tidak menyentuh BL-P0-016 atau BL lain.
- Tidak melakukan push (batch push tetap deferred per keputusan Owner).
- Tidak mengubah canonical authority; tidak mengarang AC.

## 9. CONCLUSION / STATUS
- BL-P0-015 = DONE / PASS (Owner-verified) untuk scope Phase 0
  (VERIFICATION-ONLY / DEFERRED-STRUCTURE).
- Konvensi advisory terdokumentasi + praktik konsisten yang teramati memenuhi kebutuhan
  Phase 0 akan commit yang traceable & classified tanpa enforcement tooling.
- Enforcement dan binding format tetap deferred/open (FLAG-015-ENF / FLAG-015-FMT).

## 10. SIGN-OFF
| Role | Name | Date | Decision |
|---|---|---|---|
| Implementation Agent | [AI] | 2026-08-09 | SUBMITTED |
| Owner / Gatekeeper | [Owner] | 2026-08-09 | APPROVED — DONE / PASS (Owner-verified), VERIFICATION-ONLY / DEFERRED-STRUCTURE |