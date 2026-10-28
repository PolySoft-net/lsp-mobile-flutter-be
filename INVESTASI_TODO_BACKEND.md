# TODO Backend: Modul Investasi & Payment Gateway

Dokumen ini mencatat rancangan kebutuhan database dan endpoint backend untuk mendukung alur transaksi investasi, pembayaran (payment gateway), portofolio pengguna, dan notifikasi yang saat ini disimulasikan di sisi Flutter Mobile.

---

### 1. Perubahan Tabel `investment_startups`

Tambahkan kolom `estimasi_roi` untuk menyimpan perkiraan imbal hasil (ROI) tahunan startup (default kosong, diisi spesifik per startup):
```sql
ALTER TABLE `investment_startups`
ADD COLUMN `estimasi_roi` VARCHAR(100) NOT NULL DEFAULT '' AFTER `equity_offered`;
```

---

### 2. Tabel Baru / Penyesuaian: `investment_transactions` (Order & Pembayaran)

Tabel untuk mencatat transaksi investasi pengguna yang diproses melalui payment gateway:
```sql
CREATE TABLE IF NOT EXISTS `investment_transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transaction_code` VARCHAR(100) NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `startup_id` BIGINT UNSIGNED NOT NULL,
  `nominal` BIGINT UNSIGNED NOT NULL,
  `equity_percentage` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
  `payment_method` VARCHAR(50) NOT NULL DEFAULT 'transfer_bank', -- 'transfer_bank', 'ewallet', 'virtual_account'
  `payment_channel` VARCHAR(50) NOT NULL DEFAULT '', -- 'bca_va', 'bni_va', 'gopay', 'qris', dll.
  `payment_status` VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'paid', 'expired', 'failed'
  `payment_url` VARCHAR(255) NOT NULL DEFAULT '',
  `payment_reference` VARCHAR(100) NOT NULL DEFAULT '',
  `paid_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_inv_trx_code` (`transaction_code`),
  KEY `idx_inv_trx_user` (`user_id`),
  KEY `idx_inv_trx_startup` (`startup_id`),
  KEY `idx_inv_trx_status` (`payment_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 3. Tabel Notifikasi Investasi: `investment_notifications`

Tabel untuk mencatat update perkembangan startup, pembayaran, laporan berkala, dan pengumuman untuk investor:
```sql
CREATE TABLE IF NOT EXISTS `investment_notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL, -- 0 jika broadcast ke semua user
  `startup_id` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `kategori` VARCHAR(50) NOT NULL DEFAULT 'investasi', -- 'investasi', 'sistem', 'update', 'pembayaran'
  `judul` VARCHAR(255) NOT NULL,
  `pesan` TEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inv_notif_user` (`user_id`),
  KEY `idx_inv_notif_cat` (`kategori`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 4. Endpoint API yang Perlu Diimplementasikan di Backend

#### A. Checkout / Buat Order Investasi
- **URL**: `POST /api/investment/checkout`
- **Auth**: `AuthMiddleware` (Bearer Token)
- **Request Body**:
  ```json
  {
    "startup_id": 1,
    "nominal": 5000000,
    "payment_method": "transfer_bank"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "transaction_code": "INV-20261028-0001",
      "startup_id": 1,
      "nominal": 5000000,
      "equity_percentage": 2.5,
      "payment_method": "transfer_bank",
      "payment_status": "pending",
      "payment_url": "https://app.sandbox.midtrans.com/snap/v2/vtweb/...",
      "created_at": "2026-10-28T10:00:00Z"
    }
  }
  ```

#### B. Riwayat Portofolio Pengguna
- **URL**: `GET /api/investment/portfolio`
- **Auth**: `AuthMiddleware`
- **Response**:
  ```json
  {
    "data": {
      "total_invested": 5000000,
      "total_return_pct": 12.0,
      "items": [
        {
          "id": 1,
          "startup_id": 1,
          "startup_name": "EduTech Plus",
          "category": "Pendidikan | EdTech",
          "invested_amount": 1000000,
          "return_pct": 12.0,
          "return_amount": 120000,
          "status": "Aktif"
        }
      ]
    }
  }
  ```

#### C. Daftar Notifikasi Investasi
- **URL**: `GET /api/investment/notifications`
- **Auth**: `AuthMiddleware`
- **Query Params**: `?kategori=semua|investasi|sistem`

#### D. Webhook / Callback Payment Gateway
- **URL**: `POST /api/investment/payment/callback`
- **Auth**: Publik / Verifikasi Signature Header Payment Gateway
