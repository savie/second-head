# SECOND HEAD — Runtime

Folder ini menampung SH Runtime sebagai execution/orchestration boundary.

## Fungsi

- menerima request melalui contract yang ditetapkan;
- menyelesaikan identity, ownership, dan authorization sesuai authority SH;
- melakukan orchestration context, model, capability, tool, dan action;
- menghasilkan normalized result/event dan mengintegrasikan audit bila diperlukan.

## Boundary

Runtime bukan authority yang berdiri sendiri di atas Canonical SH. Runtime menjalankan semantics dan contract yang telah ditetapkan SH.

Struktur runtime pada dev_old digunakan sebagai reference/evidence. Penamaan dan pembagian implementation tidak harus dipertahankan.
