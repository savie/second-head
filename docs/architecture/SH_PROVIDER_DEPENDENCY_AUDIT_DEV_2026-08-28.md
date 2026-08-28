# SECOND HEAD — PROVIDER DEPENDENCY AUDIT (DEV)

Date: 2026-08-28
Branch: `dev`
Status: DEV AUDIT / NON-CANONICAL
Purpose: memetakan dependency provider aktual tanpa mengubah Canonical.

## Kesimpulan

Current SH DEV masih menggunakan Supabase sebagai infrastructure/provider, tetapi dependency client-side sekarang dipusatkan pada satu boundary:

`app/services/backend.ts`

Tidak ada lagi modul application bernama `supabase.ts`.

Ini bukan berarti SH sudah database-provider agnostic sepenuhnya. Implementasi `backend.ts` masih menggunakan `@supabase/supabase-js`. Namun provider-specific client implementation sekarang terlokalisasi sehingga migration ke adapter/provider lain tidak perlu menyebarkan perubahan ke seluruh feature module.

## Dependency map

### App

`app/` adalah React Native + Expo delivery layer.

Application services/features tidak lagi mengimpor modul provider bernama `supabase.ts`. Akses backend client melalui `app/services/backend.ts`.

Current provider-specific implementation remains inside that boundary:

- `@supabase/supabase-js`
- `EXPO_PUBLIC_SUPABASE_URL`
- `EXPO_PUBLIC_SUPABASE_ANON_KEY`

Auth/session, RPC, table access, dan Edge Function invocation masih menggunakan client tersebut karena Supabase adalah current infrastructure.

### Functions

Current runtime functions berada di:

`functions/`

dan bukan di `runtime/` seperti yang masih tertulis pada beberapa dokumentasi architecture lama.

Functions yang berjalan sebagai Supabase Edge Functions secara alami mempunyai deployment/runtime coupling terhadap Supabase/Deno. Ini dianggap infrastructure coupling, bukan SH identity/business semantics.

Runtime code menggunakan Supabase server client dan environment variables seperti `SUPABASE_URL`, `SUPABASE_ANON_KEY`, dan privileged secrets pada server-side environment.

### Database

Database artifacts berada di:

`database/`

Migration source berada di:

`database/migrations/`

Database engine saat ini adalah PostgreSQL melalui Supabase.

Tidak dibuat folder provider-specific baru untuk schema/migration source.

Target boundary:

`database/ = SH database artifacts`

Supabase = current infrastructure/provider.

## What is portable now

- Product/application feature modules are not tied to a file named after Supabase.
- Database migration artifacts have a provider-neutral repository location.
- Model/provider selection remains behind runtime/model abstraction rather than the mobile client.
- Server secrets remain outside the client.

## What is NOT yet fully portable

- `app/services/backend.ts` implementation is still Supabase-specific.
- Supabase Auth is the current authentication provider.
- Runtime Edge Functions are currently deployed through Supabase.
- Runtime function implementations use Supabase client/database APIs.

Therefore this audit does NOT claim “drop-in multi-database support”.

It establishes a migration boundary that makes future provider replacement a contained engineering task.

## Required rule going forward

New feature code MUST NOT import a provider-specific client directly.

New database/application access should cross the existing backend/database boundary. If a future provider is introduced, provider-specific implementation should be isolated behind that boundary.

Do not create `app/supabase/`, `database/supabase/`, or equivalent provider-named application/database folders merely to support the current provider.

Provider-specific deployment/configuration may remain where technically required.

## No database mutation

This audit did not reset, replay, or mutate the Supabase DEV database.

It is a source/dependency architecture audit only.

## Relation to Canonical

This document is non-canonical. It does not alter SH identity, governance, memory, knowledge, experience, journey, lifecycle, authorization, or database semantics.

END
