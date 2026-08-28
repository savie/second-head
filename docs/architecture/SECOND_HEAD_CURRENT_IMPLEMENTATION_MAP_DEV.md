# SECOND HEAD — CURRENT IMPLEMENTATION MAP

Date: 2026-08-28
Branch baseline: `dev`
Status: DEV working architecture map / NON-CANONICAL

> Dokumen ini memetakan implementasi repository DEV saat ini terhadap konsep SH. Ini bukan pengganti Canonical dan tidak mengubah Canonical.

## 1. Tujuan

Map ini menjadi dasar bersama saat audit, tracking, debugging, dan pengembangan V1.0.

Prinsip tracking:
- audit kondisi sekarang dimulai dari latest verified DEV baseline;
- history Git digunakan bila perlu menelusuri asal perubahan/regression;
- Canonical tetap menjadi authority semantik/arsitektur;
- implementation map menggambarkan kondisi code aktual, bukan menetapkan Canonical baru.

## 2. Gambaran besar

```
SECOND HEAD
│
├── app/
│   └── mobile application / UI / client interaction
│
├── functions/
│   └── server-side executable/deployment units
│       └── runtime-p4a-001/ (current runtime function)
│
├── database/
│   └── database artifacts
│       └── migrations/
│
└── docs/
    ├── canonical/
    ├── architecture/
    └── resume/
```

## 3. App

`app/` adalah delivery/application layer React Native + Expo.

Tanggung jawab utamanya meliputi UI, interaction, local client state, attachment interaction, streaming presentation, dan pemanggilan backend.

Backend/provider access dipusatkan melalui:

`app/services/backend.ts`

Saat ini implementation boundary tersebut masih menggunakan Supabase client. Jadi boundary sudah dipisahkan dari feature modules, tetapi provider replacement belum otomatis tersedia.

## 4. Functions

`functions/` adalah lokasi executable server-side functions yang saat ini dideploy sebagai Supabase Edge Functions.

Contoh aktual:
`functions/runtime-p4a-001/`

Function adalah **execution/deployment unit**, bukan sinonim dari konsep SH Runtime.

Karena deployment saat ini menggunakan Supabase Edge Functions, folder ini memang mempunyai infrastructure coupling terhadap Supabase/Deno.

## 5. Runtime

SH Runtime adalah **system/runtime concept** yang menjalankan orchestration dan capability processing di server side.

`runtime-p4a-001` adalah implementation/execution unit yang membawa sebagian runtime tersebut dalam deployment saat ini.

Karena itu:

```
SH Runtime
    = system capability / runtime concept

runtime-p4a-001
    = current executable function/deployment unit
```

Jangan menganggap keduanya sebagai dua sistem SH yang berbeda hanya karena nama folder/identifier berbeda.

## 6. Database

`database/` adalah repository location untuk database artifacts.

Migration source berada di:
`database/migrations/`

Current database engine/provider deployment:

```
PostgreSQL
   ↑
Supabase DEV
```

Repository naming sengaja tidak menggunakan folder `database/supabase/`.

Tujuannya menjaga database artifacts tetap general dan tidak mengikat struktur repository pada provider saat ini.

## 7. Provider boundary

Current state:

```
                  SH
                   │
          ┌────────┴────────┐
          │                 │
      Application        Runtime
          │                 │
          ↓                 ↓
   backend.ts          current functions
          │                 │
          └────────┬────────┘
                   ↓
             Supabase DEV
              │         │
              ↓         ↓
          PostgreSQL   Edge Functions
```

Supabase masih merupakan current infrastructure/provider.

Portability boundary yang sudah diperbaiki terutama berada di application backend client:
`app/services/backend.ts`

Provider-specific runtime/deployment coupling masih berada di server-side functions dan deployment configuration.

## 8. Function vs Runtime — aturan istilah

Gunakan istilah:
- **Runtime** = konsep/sistem SH yang melakukan processing/orchestration.
- **Function** = executable server-side unit.
- **runtime-p4a-001** = current function/deployment unit untuk runtime implementation.
- **Supabase Edge Function** = infrastructure execution mechanism yang saat ini dipakai.

Jangan menggunakan `functions/` sebagai sinonim untuk seluruh SH Runtime.

## 9. Portability status

### 🟢 Relatif terisolasi
- application feature modules dari nama file provider;
- database artifacts dari folder provider-specific;
- model/provider selection dari mobile client;
- server secrets dari client.

### 🟡 Masih provider-coupled
- `app/services/backend.ts` implementation;
- Supabase Auth;
- Supabase Edge Function deployment;
- server-side database/client calls.

### 🔴 Belum ada
- true drop-in multi-database provider switching;
- independent runtime deployment abstraction;
- verified alternate infrastructure implementation.

## 10. Aturan implementasi ke depan

Feature baru tidak boleh menambahkan direct provider coupling ke feature/UI layer hanya karena provider saat ini adalah Supabase.

Jika provider-specific code memang diperlukan, letakkan pada boundary/infrastructure implementation yang jelas.

Jangan membuat folder baru bernama provider hanya untuk mengakomodasi provider saat ini.

## 11. Hubungan dengan Canonical

Canonical tetap authority.

Map ini hanya menjawab:
> “Bagaimana Canonical/system SH saat ini direpresentasikan oleh code DEV?”

Jika implementation berbeda dari Canonical, perbedaan tersebut harus dicatat sebagai gap/implementation state dan tidak boleh diam-diam dianggap sebagai perubahan Canonical.

END