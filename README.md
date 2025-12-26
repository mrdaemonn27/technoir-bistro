# 🍷 Technoir Bistro

[![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=for-the-badge&logo=laravel)](https://laravel.com)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.0-38B2AC?style=for-the-badge&logo=tailwind-css)](https://tailwindcss.com)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?style=for-the-badge&logo=php)](https://www.php.net)

**Technoir Bistro** adalah platform manajemen restoran modern yang dibangun dengan Laravel. Aplikasi ini dirancang untuk menangani reservasi meja, manajemen menu, dan integrasi pembayaran melalui Xendit, memberikan pengalaman premium baik untuk pelanggan maupun administrator.

---

## ✨ Fitur Utama

-   **🛒 Manajemen Menu:** Kelola katalog makanan dan minuman dengan kategori yang rapi.
-   **📅 Reservasi Meja:** Sistem booking meja secara real-time untuk pelanggan.
-   **💳 Integrasi Xendit:** Pembayaran aman dan otomatis menggunakan Payment Gateway Xendit.
-   **🛡️ Panel Admin:** Dashboard intuitif untuk mengelola konten dan melihat laporan reservasi.
-   **🧪 Robust Testing:** Dilengkapi dengan Feature Tests untuk menjamin keandalan fitur vital.

---

## 🚀 Panduan Instalasi

Ikuti langkah-langkah di bawah ini untuk menjalankan project ini di lingkungan lokal Anda.

### 📋 Prasyarat

Pastikan Anda sudah menginstal:

-   PHP >= 8.2
-   Composer
-   Node.js & NPM
-   MySQL / MariaDB

### 🛠️ Langkah-Langkah

1.  **Clone Repository**

    ```bash
    git clone https://github.com/mrdaemonn27/technoir-bistro.git
    cd technoir-bistro
    ```

2.  **Instalasi Dependensi**

    ```bash
    composer install
    npm install
    ```

3.  **Konfigurasi Environment**
    Salin file `.env.example` menjadi `.env`:

    ```bash
    cp .env.example .env
    ```

    > **Catatan Penting:** Buka file `.env` dan sesuaikan konfigurasi database (`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`) serta API Key Xendit.
    > **Catatan Penting:** Saya sudah memberikan api key xendit di LMS.

4.  **Generate Application Key**

    ```bash
    php artisan key:generate
    ```

5.  **Migrasi & Seed Database**
    Jalankan migrasi untuk membuat tabel dan masukkan data awal (menu & meja):

    ```bash
    php artisan migrate --seed
    ```

6.  **Build Aset Frontend**
    ```bash
    npm run build
    ```

---

## 💻 Menjalankan Aplikasi

Atau jalankan secara manual di dua terminal terpisah:

**Terminal 1 (Backend):**

```bash
php artisan serve
```

**Terminal 2 (Frontend/Vite):**

```bash
npm run dev
```

Akses aplikasi di: [http://localhost:8000](http://localhost:8000)

---

## 🧪 Menjalankan Test

Untuk memastikan semua fungsi berjalan dengan baik, Anda dapat menjalankan suite pengujian menggunakan Pest atau Artisan:

```bash
php artisan test
```

---

## 🛠️ Integrasi Xendit

Aplikasi ini menggunakan Xendit sebagai Payment Gateway. Pastikan variabel berikut terisi di `.env`:

```env
XENDIT_SECRET_KEY=xnd_development_...
XENDIT_WEBHOOK_TOKEN=...
XENDIT_PUBLIC_KEY=xnd_public_...
```

---

<p align="center">
  Proudly powered by Laravel & Tailwind CSS.
</p>
