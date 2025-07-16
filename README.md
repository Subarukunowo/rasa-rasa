# 🍲 RasaRasa — Aplikasi Resep Masakan Flutter

**RasaRasa** adalah aplikasi Flutter yang memungkinkan pengguna untuk menjelajahi, mencari, dan menyimpan berbagai resep masakan. Proyek ini dirancang dengan antarmuka yang modern dan pengalaman pengguna yang intuitif.

## ✨ Fitur Utama

- 🔐 **Autentikasi**: Login & Registrasi pengguna.
- 📄 **Detail Resep**: Lihat resep lengkap, termasuk gambar, deskripsi, waktu memasak, dan langkah-langkah.
- 📷 **Tambah Resep**: Unggah resep sendiri lengkap dengan foto makanan.
- ❤️ **Bookmark**: Simpan resep favorit.
- 🔍 **Pencarian**: Cari resep berdasarkan nama atau kategori.
- ⚙️ **Pengaturan Profil**: Edit profil, ubah foto, dan informasi akun.

## 🧰 Teknologi yang Digunakan

- **Flutter** (frontend)
- **Dart** sebagai bahasa utama
- **PHP & MySQL** untuk backend API
- **HTTP package** untuk komunikasi dengan server
- **Image Picker** untuk unggah gambar
- **Stateful Widgets** untuk UI dinamis

## 📁 Struktur Folder (lib/)
```text
├── model/ # Model data (resep, user, dll)
├── route/ # Routing aplikasi
├── screen/ # Layar utama (home, login, profil, dll)
│ ├── auth/ # Layar otentikasi
│ ├── beranda.dart
│ ├── detail.dart
│ └── ...
├── service/ # Pemanggilan API
├── util/ # Utility dan session helper
├── widget/ # Komponen UI custom


## 🚀 Cara Menjalankan

1. Clone repository ini:
   ```bash
   git clone https://github.com/Subarukunowo/rasa-rasa.git
   cd rasa-rasa

2. Install dependencies:
   ```bash
   flutter pub get

3. Jalankan aplikasi:
    ```bash
   flutter run

 ## 📌 Status Proyek
 **🚧** Masih dalam tahap pengembangan aktif. Beberapa fitur utama sudah selesai, namun terus diperbarui dan ditingkatkan.

 ##📜 Lisensi
 Proyek ini dilisensikan di bawah lisensi MIT. Silakan gunakan, modifikasi, dan kontribusi dengan bebas.

 💡 Developed with ❤️ by Subarukunowo
