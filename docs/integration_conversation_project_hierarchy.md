# Integrasi Project → Conversation → Message

## Status

Implementasi DEV menyelaraskan Conversation sebagai container chat, dengan Message sebagai unit persistence dan selection boundary untuk Journey.

## Struktur

- Project: grouping opsional untuk Conversation.
- Conversation: container chat.
- Message: unit percakapan yang tersimpan.
- Conversation standalone tetap valid ketika `project_id` bernilai null.

## Boundary

Conversation tidak memiliki policy. Policy tetap berada pada domain Lifecycle sesuai kontrak SH.

Journey menerima Message secara selektif; tidak seluruh Conversation otomatis masuk Journey.

## Frontend

Sidebar menampilkan Project di atas Conversation. Pemilihan Conversation menetapkan active Conversation ID dan membangun ulang chat view untuk thread tersebut.

## Backend

Supabase DEV mempertahankan tabel `conversations` sebagai storage message untuk kompatibilitas, menambahkan `conversation_threads` sebagai container dan `projects` sebagai grouping. Runtime RPC baru menjadi boundary untuk listing, creation, loading, rename, update, dan deletion.
