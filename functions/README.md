# SECOND HEAD — Server Functions

Folder ini menampung server-side execution units yang berjalan di luar Flutter application dan ditempatkan pada boundary server yang sesuai.

## Fungsi

- menjalankan execution unit server-side;
- menyediakan adapter/execution path untuk capability yang memang membutuhkan server execution;
- menjaga credential dan secret yang tidak boleh berada di Flutter client;
- menerapkan contract antara SH Runtime/capability dengan infrastructure atau external provider.

## Boundary

Function tidak menjadi authority SH hanya karena berjalan di server atau menggunakan provider tertentu.

Implementasi pada dev_old menjadi reference/evidence untuk capability dan execution pattern, bukan baseline code untuk pembangunan Flutter + Dart.
