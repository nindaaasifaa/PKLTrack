# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# PKLTrack – Aplikasi Jurnal Kegiatan PKL Siswa

## 1. Deskripsi Aplikasi

PKLTrack merupakan aplikasi mobile berbasis Flutter yang dikembangkan untuk membantu pencatatan dan pengarsipan kegiatan Praktik Kerja Lapangan (PKL) siswa. Aplikasi ini menyediakan fitur sesuai peran pengguna, yaitu siswa, guru, dan admin.

Aplikasi ini berfokus pada dokumentasi kegiatan PKL, pemeriksaan jurnal oleh guru, serta pengelolaan data dan laporan arsip.

## 2. Teknologi yang Digunakan

- **Framework:** Flutter
- **Bahasa Pemrograman:** Dart
- **Editor:** Visual Studio Code
- **Target Platform:** Android
- **Alat bantu pengembangan:** GitHub Copilot dan ChatGPT

## 3. Fitur Aplikasi

### Siswa
- Login ke aplikasi.
- Melihat dashboard siswa.
- Menambahkan jurnal kegiatan PKL.
- Menambahkan foto dokumentasi kegiatan.
- Melihat riwayat jurnal.
- Mengelola foto profil.
- Logout dari aplikasi.

### Guru
- Melihat dashboard guru.
- Melihat dan memeriksa jurnal kegiatan siswa.
- Memvalidasi jurnal sesuai fungsi yang tersedia.
- Mencari jurnal berdasarkan nama siswa dan kelas.
- Melihat riwayat jurnal.
- Mengelompokkan jurnal berdasarkan periode PKL.
- Mengelola foto profil.

### Admin
- Melihat dashboard admin.
- Mengelola data pengguna dan kelas.
- Melihat data jurnal.
- Melihat statistik kegiatan.
- Menyiapkan laporan arsip sesuai fitur yang tersedia.

*Catatan: daftar fitur perlu disesuaikan dengan fungsi yang benar-benar sudah diterapkan dan diuji pada versi aplikasi yang diunggah.*

## 4. Screenshot Aplikasi

Screenshot antarmuka aplikasi akan ditampilkan pada bagian ini.

Simpan gambar dokumentasi aplikasi pada folder `screenshots/` di direktori utama proyek, kemudian gunakan format berikut untuk menampilkannya:

### Halaman Login

![Halaman Login](screenshots/login.png)

### Dashboard Siswa

![Dashboard Siswa](screenshots/dashboard_siswa.png)

### Formulir Tambah Jurnal

![Tambah Jurnal](screenshots/tambah_jurnal.png)

### Dashboard Guru

![Dashboard Guru](screenshots/dashboard_guru.png)

### Dashboard Admin

![Dashboard Admin](screenshots/dashboard_admin.png)

*Ganti atau sesuaikan nama gambar dengan file screenshot yang benar-benar kamu simpan.*

## 5. Cara Menjalankan Proyek

### Persyaratan
- Flutter SDK telah terpasang.
- Dart SDK tersedia melalui Flutter.
- Android Studio atau Android Emulator tersedia jika ingin menjalankan aplikasi pada emulator.
- Visual Studio Code dapat digunakan sebagai editor.

### Langkah Menjalankan

1. Unduh atau clone repositori PKLTrack.
2. Buka folder proyek di Visual Studio Code.
3. Buka terminal pada direktori proyek.
4. Jalankan perintah berikut untuk mengunduh dependensi:

   ```bash
   flutter pub get
   ```

5. Pastikan perangkat Android atau emulator terdeteksi:

   ```bash
   flutter devices
   ```

6. Jalankan aplikasi:

   ```bash
   flutter run
   ```

## 6. Struktur Proyek

```text
flutter_application_1/
├── lib/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── widgets/
│   └── main.dart
├── android/
├── assets/
├── pubspec.yaml
├── README.md
└── AI_DECLARATION.md
```

Struktur di atas merupakan gambaran umum. Folder `assets/` dan subfolder lainnya dicantumkan jika memang tersedia pada proyek.

## 7. Penggunaan AI

Pengembangan PKLTrack menggunakan bantuan AI untuk mendukung penulisan kode, perbaikan bug, dan penyempurnaan antarmuka. Penjelasan mengenai alat AI, pembagian peran, contoh prompt. 

## 8. Tujuan Pengembangan

PKLTrack dikembangkan untuk membantu dokumentasi dan pengarsipan kegiatan PKL siswa secara lebih terstruktur serta memudahkan guru dalam memeriksa jurnal kegiatan.