# SECOND HEAD — Database

Folder ini menjadi source boundary untuk database schema dan migration artifacts SH.

## Fungsi

- menyimpan migration source;
- mendokumentasikan perubahan schema yang menjadi bagian dari repository;
- menjaga keterlacakan antara source migration dan database state;
- mendukung verification terhadap database parity.

## Boundary

Database menyimpan dan menyediakan data sesuai contract, tetapi database/provider tidak menjadi authority untuk SH identity, ownership, governance, atau semantics.

Supabase + PostgreSQL merupakan technology direction backend. Tidak diperlukan folder root khusus bernama supabase hanya karena technology tersebut digunakan.
