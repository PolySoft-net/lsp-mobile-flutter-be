# TODO Backend: Modul Investasi & Payment Gateway

Dokumen ini mencatat rancangan kebutuhan database dan endpoint backend untuk mendukung alur transaksi investasi, pembayaran (payment gateway), dan portofolio pengguna yang saat ini masih disimulasikan di sisi Flutter Mobile.

---

### 1. Perubahan Tabel `investment_startups`

Tambahkan kolom `estimasi_roi` untuk menyimpan perkiraan imbal hasil (ROI) tahunan startup:
```sql
ALTER TABLE `investment_startups`
ADD COLUMN `estimasi_roi` VARCHAR(100) NOT NULL DEFAULT '12-18% / tahun' AFTER `equity_offered`;
```

---

### 2. Tabel Baru: `investment_transactions` (Order / Checkout Investasi)

Tabel untuk mencatat order investasi pengguna yang diproses melalui payment gateway:
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

### 3. Endpoint API yang Perlu Diimplementasikan di Backend

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

#### B. Riwayat Transaksi & Portofolio Pengguna
- **URL**: `GET /api/investment/portfolio`
- **Auth**: `AuthMiddleware`
- **Deskripsi**: Mengembalikan total portofolio riil pengguna (akumulasi nominal investasi dengan status `paid`) serta daftar startup yang didanai pengguna.

#### C. Webhook / Callback Payment Gateway
- **URL**: `POST /api/investment/payment/callback`
- **Auth**: Publik / Verifikasi Signature Header Payment Gateway (Xendit / Midtrans / Duitku)
- **Deskripsi**: Memperbarui status pembayaran transaksi (`pending` -> `paid`), mencatat `paid_at`, serta menambahkan `collected_funding` pada tabel `investment_startups`.
