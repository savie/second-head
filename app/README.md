# SECOND HEAD — Application

Folder ini adalah application foundation untuk SH yang menggunakan Flutter + Dart.

## Fungsi

- menampung application code Flutter + Dart;
- presentation dan feature surfaces;
- domain/client contracts yang memang menjadi tanggung jawab application;
- bounded local state dan integrasi platform melalui boundary yang eksplisit.

## Boundary

Application tidak menjadi authority untuk SH identity, ownership, authorization, privacy, governance, atau audit authority.

Struktur internal mengikuti architecture yang ditetapkan dan tidak perlu meniru struktur implementation pada dev_old yang menggunakan React Native + Expo.
