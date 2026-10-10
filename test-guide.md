# Panduan Uji LSP Digital Mobile

Dokumen ini adalah checklist uji manual untuk aplikasi LSP Digital Mobile. Jalankan tabel secara berurutan: **Publik**, **Admin**, **Asesor**, lalu **Asesi**.

## Aturan Pencatatan

| Kolom | Isi oleh penguji |
|---|---|
| Hasil | `Lulus`, `Gagal`, atau `Tertunda` |
| Bukti | Tautan screenshot, rekaman layar, atau nomor tiket bug |
| Catatan | Perilaku aktual, pesan galat, dan langkah reproduksi bila gagal |

## Prasyarat Data Uji

| Kode | Data yang diperlukan | Tujuan |
|---|---|---|
| D-01 | Perangkat Android/iOS atau browser web yang didukung | Menguji tampilan dan interaksi aplikasi |
| D-02 | Koneksi internet aktif dan koneksi terputus | Menguji kondisi normal serta gagal jaringan |
| D-03 | Akun Admin aktif | Menguji menu dan aksi Admin |
| D-04 | Akun Asesor aktif dengan jadwal, tugas, laporan, honor, dan tiket | Menguji seluruh alur Asesor |
| D-05 | Akun Asesi aktif dengan skema, pendaftaran, jadwal, serta sertifikat | Menguji seluruh alur Asesi |
| D-06 | Sertifikat valid dan nomor sertifikat yang tidak terdaftar | Menguji pencarian dan validasi sertifikat |
| D-07 | Berkas valid (PDF/PNG/JPG) dan berkas tidak valid/terlalu besar | Menguji unggah dokumen |
| D-08 | Dua akun berbeda pada peran yang sama | Menguji isolasi data dan larangan akses data pengguna lain |
| D-09 | Calon Asesi baru dengan NIK yang belum memiliki akun | Menguji pendaftaran publik dan pembuatan akun otomatis |
| D-10 | Asesi dengan riwayat pernah diuji pada Skema A dan skema lain yang belum pernah diuji | Menguji larangan memilih Skema A serta pendaftaran ke skema lain |

## Uji Umum

| ID | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|
| U-01 | Splash dan inisialisasi | Buka aplikasi dari kondisi tertutup | Splash tampil lalu pengguna diarahkan ke onboarding/login/beranda sesuai status sesi |  |  |  |
| U-02 | Onboarding | Jalankan onboarding, pindah halaman, lalu pilih lewati/selesai | Navigasi halaman benar dan pengguna masuk ke pemilihan peran atau login |  |  |  |
| U-03 | Responsif | Uji layar kecil dan besar, orientasi portrait serta landscape bila didukung | Konten dapat dibaca, tidak terpotong, dan tombol tetap dapat digunakan |  |  |  |
| U-04 | Tidak ada koneksi | Matikan koneksi lalu buka atau muat ulang layar yang memakai API | Pesan gagal koneksi tampil jelas; aplikasi tidak crash |  |  |  |
| U-05 | Pemuatan dan galat API | Buka layar dengan data kosong atau API gagal | Indikator loading, empty state, dan error state tampil sesuai kondisi |  |  |  |
| U-06 | Tombol kembali | Dari setiap tab, detail, dan dialog gunakan tombol kembali | Kembali ke konteks sebelumnya; dari tab non-beranda kembali ke Beranda; dari Beranda tampil konfirmasi keluar |  |  |  |
| U-07 | Notifikasi | Izinkan notifikasi, buka lonceng notifikasi, lalu buka item notifikasi | Badge, daftar, status dibaca, dan tujuan navigasi item sesuai |  |  |  |
| U-08 | Sesi kedaluwarsa | Gunakan token kedaluwarsa atau cabut sesi dari perangkat lain | Dialog sesi berakhir tampil dan pengguna diarahkan untuk login kembali |  |  |  |
| U-09 | Scope notifikasi | Kirim payload dengan `user_id` akun lain, `target_role` role lain, lalu payload tanpa scope; ulangi saat foreground, background, dan ketuk push | Payload ditolak; tidak masuk daftar/badge/banner dan tidak membuka layar |  |  |  |
| U-10 | Notifikasi sesuai role | Kirim SPT ke Asesor dan umpan balik/status kompeten ke Asesi; coba kirim masing-masing ke role yang salah | Backend menolak tipe dengan role penerima yang salah; payload sah membawa `user_id`, `type`, dan `target_role` kanonikal |  |  |  |
| U-11 | Antrean jadwal Admin | Buka lonceng sebagai Admin, Asesor, lalu Asesi | Admin melihat daftar dan jumlah Draft/Waiting yang konsisten; Asesor/Asesi hanya melihat notifikasi aplikasi, tanpa tab/request antrean ACC Admin |  |  |  |
| U-12 | Pergantian akun dan badge | Muat daftar lalu logout/login akun lain; tandai dibaca, hapus item, dan hapus semua; kembali dari background | Hasil async akun lama tidak tampil; badge mengikuti notifikasi sesi aktif dan perubahan status dibaca/hapus |  |  |  |
| U-13 | Navigasi notifikasi | Buka FAQ dan sertifikat yang juga membawa `jadwal_id`; buka tipe umum dan kirim tawaran pekerjaan dari akun perekrut | FAQ/sertifikat tidak membuka detail jadwal; tipe tanpa rute khusus tidak membuka jadwal; perekrut tidak memperoleh salinan notifikasi penerima |  |  |  |

## Publik

| ID | Modul | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|---|
| P-01 | Beranda | Buka sebagai tamu | Buka aplikasi tanpa login | Tab Beranda, Berita, Sertifikat, dan Profil tampil |  |  |  |
| P-02 | Beranda | Konten dashboard | Periksa ringkasan, kartu, banner, dan tautan di Beranda | Data publik tampil konsisten; tautan membuka tujuan yang benar |  |  |  |
| P-03 | Berita | Daftar berita | Buka tab Berita dan gulir daftar | Daftar berita dapat dimuat; pagination/pemuatan berikutnya tidak duplikat atau crash |  |  |  |
| P-04 | Berita | Detail berita | Buka satu berita | Judul, gambar, tanggal, dan isi berita yang sesuai tampil |  |  |  |
| P-05 | Sertifikat | Pencarian sertifikat | Cari dengan kata kunci/nomor sertifikat yang valid | Hasil relevan tampil dan detail dapat dibuka |  |  |  |
| P-06 | Sertifikat | Pencarian kosong/tidak ditemukan | Kosongkan kata kunci dan cari nomor yang tidak ada | Validasi input atau empty state tampil tanpa hasil palsu |  |  |  |
| P-07 | Sertifikat | Unduh dari hasil pencarian | Pilih sertifikat yang memiliki berkas unduhan | Berkas/URL sertifikat terbuka atau diunduh dengan benar |  |  |  |
| P-08 | Validasi | Nomor valid | Masukkan nomor sertifikat yang valid lalu pilih validasi | Status valid dan informasi sertifikat sesuai data sumber |  |  |  |
| P-09 | Validasi | Nomor tidak valid | Masukkan nomor yang tidak terdaftar atau format salah | Status tidak valid/pesan validasi tampil jelas |  |  |  |
| P-10 | Profil publik | Informasi LSP | Buka tab Profil | Kontak, alamat, email, telepon, dan website dapat dilihat serta tautan berfungsi |  |  |  |
| P-11 | Profil publik | Informasi pendukung | Buka Tentang Sistem, Panduan Mendaftar, FAQ, Statistik LSP, dan Hubungi Kami | Setiap halaman terbuka, konten terbaca, dan kembali berfungsi |  |  |  |
| P-12 | Pendaftaran publik | Form pendaftaran calon Asesi | Dari area publik pilih Daftar, isi NIK dan data wajib yang valid, lalu kirim | Pendaftaran diterima, akun Asesi dibuat otomatis, dan sistem menampilkan instruksi login menggunakan NIK serta password awal `123456` |  |  |  |
| P-13 | Pendaftaran publik | NIK sudah terdaftar | Daftarkan kembali NIK yang telah memiliki akun | Pendaftaran ditolak; akun/record duplikat tidak dibuat; pengguna diarahkan untuk login atau reset password sesuai kebijakan |  |  |  |
| P-14 | Pendaftaran publik | Validasi data | Kirim form tanpa data wajib atau memakai format NIK tidak valid | Pesan validasi per field tampil; tidak ada akun yang dibuat |  |  |  |
| P-15 | Akses | Proteksi fitur akun | Coba buka profil Asesi, pendaftaran asesmen, atau pra-asesmen tanpa login | Akses ditolak atau pengguna diminta login; tidak ada data privat yang tampil |  |  |  |

## Admin

| ID | Modul | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|---|
| A-01 | Login | Login Admin valid | Pilih peran Admin, masukkan kredensial benar, lalu login | Masuk ke Beranda Admin dengan tab Beranda, Statistik, Jadwal, Sertifikat, dan Profil |  |  |  |
| A-02 | Login | Login Admin gagal | Gunakan password salah atau role tidak sesuai | Login ditolak dengan pesan jelas; sesi tidak dibuat |  |  |  |
| A-03 | Beranda | Ringkasan dashboard | Periksa total asesmen, pemegang sertifikat, asesor, TUK, asesi, tren, dan antrean | Nilai tampil, format angka benar, dan konsisten setelah muat ulang |  |  |  |
| A-04 | Beranda | Antrean tindakan | Buka kartu antrean jadwal, laporan, pendaftaran, dan honor jika tersedia | Jumlah antrean sesuai data dan navigasi tujuan benar |  |  |  |
| A-05 | Statistik | Overview statistik | Buka tab Statistik | Kartu total asesi, sertifikat, LSP, kelulusan, dan tren tampil |  |  |  |
| A-06 | Statistik | Grafik asesmen | Ubah periode/filter grafik bila tersedia | Data grafik, label bulan, total, kompeten, dan belum kompeten tampil benar |  |  |  |
| A-07 | Statistik | Distribusi asesor | Buka statistik/sebaran asesor | Distribusi wilayah, status asesor, dan nilai ringkasan tampil |  |  |  |
| A-08 | Statistik | Sertifikat per skema | Buka statistik sertifikat per skema | Daftar skema dan total pemegang sertifikat tampil serta dapat digulir |  |  |  |
| A-09 | Statistik | Asesor berdasarkan homebase | Buka daftar homebase asesor | Nama, skema, homebase, dan jumlah asesmen tampil dengan urutan yang benar |  |  |  |
| A-10 | Jadwal | Daftar dan tab status | Buka Jadwal lalu pindah tab Draft, Running, Pelaporan, dan Selesai | Data per tab sesuai status; badge jumlah konsisten |  |  |  |
| A-11 | Jadwal | Filter dan urutkan | Gunakan filter status/TUK/LSP serta urutan jika tersedia | Hasil berubah sesuai filter; reset mengembalikan data awal |  |  |  |
| A-12 | Jadwal | Detail jadwal | Buka satu jadwal | Detail jadwal, asesor, dan daftar asesi yang relevan tampil |  |  |  |
| A-13 | Jadwal | Ubah status jadwal | Lakukan perubahan status pada data uji | Konfirmasi tampil; status, tab, badge, dan data setelah muat ulang diperbarui |  |  |  |
| A-14 | Sertifikat | Pencarian sertifikat | Cari sertifikat sebagai Admin | Hasil pencarian, detail, dan unduhan bekerja seperti peran publik |  |  |  |
| A-15 | Tiket bantuan | Daftar dan detail tiket | Buka tiket, pilih satu tiket | Detail tiket, riwayat, dan status tampil sesuai |  |  |  |
| A-16 | Tiket bantuan | Balas dan ubah status | Kirim balasan serta ubah status tiket data uji | Balasan tersimpan sekali, status diperbarui, dan terlihat setelah muat ulang |  |  |  |
| A-17 | Pengumuman | Buat pengumuman | Buat pengumuman dengan data valid | Pengumuman tersimpan dan muncul di daftar/beranda yang dituju |  |  |  |
| A-18 | Pengumuman | Ubah dan hapus pengumuman | Edit lalu hapus pengumuman data uji | Perubahan tersimpan; penghapusan meminta konfirmasi dan item hilang setelah berhasil |  |  |  |
| A-19 | Keamanan | Sesi aktif | Buka Keamanan dan cabut sesi perangkat lain | Sesi terpilih hilang; perangkat yang dicabut menerima `401` pada request berikutnya |  |  |  |
| A-20 | Logout | Keluar akun | Pilih Keluar, batalkan sekali, lalu konfirmasi | Batal tidak mengubah sesi; konfirmasi menghapus sesi lokal dan kembali ke login |  |  |  |
| A-21 | Akses | Pembatasan hak Admin | Coba akses endpoint/data milik Asesor dan Asesi lain | Sistem menolak akses privat yang bukan milik/peran Admin sesuai kebijakan backend |  |  |  |

## Asesor

| ID | Modul | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|---|
| R-01 | Login | Login Asesor valid | Pilih peran Asesor dan login dengan akun aktif | Tab Beranda, Jadwal, Tugas, Laporan, dan Profil tampil |  |  |  |
| R-02 | Beranda | Dashboard Asesor | Buka Beranda dan periksa ringkasan/agenda | Data dashboard sesuai akun dan tautan tindakan berfungsi |  |  |  |
| R-03 | Jadwal | Daftar penugasan | Buka Jadwal lalu pindah tab Menunggu, Dibatalkan, dan Selesai | Hanya jadwal milik Asesor tampil pada status yang tepat |  |  |  |
| R-04 | Jadwal | Detail jadwal | Buka satu jadwal | Detail jadwal, informasi TUK/skema, dan peserta tampil |  |  |  |
| R-05 | Jadwal | Peserta asesmen | Buka daftar peserta lalu buka satu peserta | Data peserta yang ditugaskan tampil lengkap; peserta dari jadwal lain tidak dapat dibuka |  |  |  |
| R-06 | Jadwal | Surat tugas | Unduh/buka surat tugas dari jadwal | Dokumen atau URL surat tugas terbuka dengan benar |  |  |  |
| R-07 | Tugas | Daftar tugas | Buka tab Tugas dan pilih tugas | Daftar, detail, status, dan navigasi laporan tampil benar |  |  |  |
| R-08 | Laporan | Daftar laporan | Buka tab Laporan | Laporan milik Asesor, status, dan detailnya tampil |  |  |  |
| R-09 | Laporan | Buat laporan lengkap | Isi setiap langkah laporan dengan data valid dan lampiran valid, lalu kirim | Validasi tiap langkah benar; laporan terkirim sekali dan status diperbarui |  |  |  |
| R-10 | Laporan | Validasi laporan | Kosongkan data wajib atau gunakan lampiran tidak valid | Pengiriman ditolak dengan pesan per field; data tidak tersimpan sebagian |  |  |  |
| R-11 | Profil | Data diri | Buka Data Diri, edit informasi yang diizinkan, lalu simpan | Perubahan tersimpan dan tampil setelah muat ulang |  |  |  |
| R-12 | Profil | Honor | Buka Honor Saya lalu detail satu item | Periode, nominal, status, dan detail honor sesuai akun Asesor |  |  |  |
| R-13 | Tiket bantuan | Buat tiket | Buat tiket dengan subjek, isi, dan lampiran valid | Tiket masuk daftar dengan status awal yang benar |  |  |  |
| R-14 | Tiket bantuan | Detail tiket | Buka tiket yang sudah dibalas Admin | Riwayat percakapan dan status terkini tampil; Asesor tidak melihat kontrol balas Admin |  |  |  |
| R-15 | Keamanan | Cabut sesi | Cabut sesi perangkat lain | Sesi hilang dan perangkat tersebut tidak lagi dapat menggunakan token lama |  |  |  |
| R-16 | Logout | Keluar akun | Konfirmasi keluar dari Profil | Token/sesi lokal dibersihkan dan aplikasi kembali ke Login |  |  |  |
| R-17 | Akses | Proteksi data Asesor | Dengan ID yang diubah, coba akses jadwal, peserta, laporan, honor, atau tiket Asesor lain | Server mengembalikan `403`/`404`; aplikasi tidak menampilkan data pihak lain |  |  |  |

## Asesi

| ID | Modul | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|---|
| S-01 | Login | Login akun otomatis | Setelah pendaftaran publik berhasil, login sebagai Asesi dengan NIK dan password awal `123456` | Login berhasil dan tab Beranda, Skema, Jadwal, Sertifikat, dan Profil tampil |  |  |  |
| S-02 | Beranda | Dashboard Asesi | Buka Beranda | Ringkasan skema, sertifikat, banner/alert, dan berita tampil sesuai akun |  |  |  |
| S-03 | Skema | Daftar skema yang dapat dipilih | Buka tab Skema menggunakan akun yang memiliki riwayat asesmen | Daftar hanya menampilkan skema yang belum pernah diuji oleh Asesi; pagination/infinite scroll tetap berfungsi |  |  |  |
| S-04 | Skema | Pencarian dan filter bidang | Cari nama/kode skema dan pilih/bersihkan filter bidang | Hasil sesuai kata kunci/filter; tidak duplikat dan empty state tepat |  |  |  |
| S-05 | Skema | Detail skema | Buka satu skema yang belum pernah diuji | Informasi, unit kompetensi, persyaratan, dan dokumen skema tampil |  |  |  |
| S-06 | Skema | Rekomendasi asesor | Dari detail skema buka rekomendasi asesor | Daftar asesor yang sesuai skema tampil |  |  |  |
| S-07 | Pendaftaran | Daftar skema baru | Pilih skema yang belum pernah diuji, TUK, jadwal/tanggal, lalu konfirmasi dengan data valid | Pendaftaran berhasil; status pendaftaran berubah dan tidak tercipta duplikasi |  |  |  |
| S-08 | Pendaftaran | Tolak skema yang pernah diuji | Kirim pendaftaran untuk `skema_id` yang pernah diuji, termasuk dengan manipulasi request | Server menolak dengan `422`; tidak ada pendaftaran baru dibuat; pesan menjelaskan skema sudah pernah diuji |  |  |  |
| S-09 | Pendaftaran | Validasi pendaftaran | Coba daftar tanpa data wajib atau daftar ulang pada skema yang masih aktif | Pesan validasi/penolakan jelas; data tidak berubah |  |  |  |
| S-10 | Pra-asesmen | Informasi dan kompetensi | Buka pra-asesmen dari pendaftaran aktif | Status, judul, unit kompetensi, elemen, dan KUK sesuai skema |  |  |  |
| S-11 | Pra-asesmen | Simpan jawaban | Isi jawaban `K` dan `BK`, lalu lanjut antar langkah | Pilihan tersimpan selama alur; indikator progres benar |  |  |  |
| S-12 | Pra-asesmen | Kirim jawaban | Lengkapi jawaban wajib lalu kirim | Konfirmasi/hasil berhasil tampil dan status pra-asesmen diperbarui |  |  |  |
| S-13 | Portofolio | Daftar dokumen | Buka langkah portofolio | Dokumen wajib, status, komentar, dan nama file yang sudah ada tampil |  |  |  |
| S-14 | Portofolio | Unggah berkas valid | Unggah masing-masing berkas yang dipersyaratkan | Progres/status berhasil tampil; nama dan status tetap benar setelah muat ulang |  |  |  |
| S-15 | Portofolio | Tolak berkas tidak valid | Unggah format salah atau ukuran melebihi batas | Unggahan ditolak dengan pesan jelas; status dokumen tidak menjadi berhasil |  |  |  |
| S-16 | Jadwal | Jadwal Asesi | Buka tab Jadwal lalu pindah tab Mendatang dan Berjalan | Hanya jadwal milik Asesi tampil dengan status dan detail yang benar |  |  |  |
| S-17 | Sertifikat | Daftar sertifikat | Buka tab Sertifikat dan gunakan pencarian | Hanya sertifikat terbit milik Asesi tampil; pencarian bekerja |  |  |  |
| S-18 | Sertifikat | Detail sertifikat | Buka satu sertifikat | Nomor, blanko/seri, skema, jadwal, dan asesor tampil sesuai data |  |  |  |
| S-19 | Sertifikat | Unggah foto/TTD | Pilih PDF/PNG/JPG valid lalu unggah | Berkas berhasil diunggah, status berubah berhasil, dan berkas dapat dihapus dari antrean sebelum kirim |  |  |  |
| S-20 | Sertifikat | Unduh sertifikat | Pilih unduh dari detail atau daftar sertifikat | URL aman/berkas PDF dapat dibuka; sertifikat pihak lain tidak dapat diunduh |  |  |  |
| S-21 | Profil | Data diri | Buka Data Diri, ubah data yang diizinkan, lalu simpan | Perubahan tersimpan dan data validasi ditampilkan dengan benar |  |  |  |
| S-22 | Profil | Instansi Mahasiswa | Ubah tipe menjadi Mahasiswa, isi data, lalu simpan | Field Mahasiswa yang sesuai tampil dan tetap ada setelah muat ulang |  |  |  |
| S-23 | Profil | Instansi Pekerja/Karyawan | Ubah tipe menjadi Pekerja/Karyawan, isi data, lalu simpan | Field perusahaan/pekerjaan yang sesuai tampil dan tersimpan |  |  |  |
| S-24 | Profil | Instansi Wirausaha | Ubah tipe menjadi Wirausaha, isi data, lalu simpan | Field usaha yang sesuai tampil dan tersimpan |  |  |  |
| S-25 | Keamanan | Sesi aktif | Buka Keamanan dan cabut perangkat lain | Sesi terpilih dicabut dan token perangkat tersebut tidak dapat digunakan lagi |  |  |  |
| S-26 | Logout | Keluar akun | Konfirmasi keluar dari Profil | Pengguna kembali ke Login dan tab Asesi tidak dapat diakses tanpa login |  |  |  |
| S-27 | Akses | Proteksi data Asesi | Dengan ID yang diubah, coba akses pendaftaran, portofolio, instansi, jadwal, atau sertifikat Asesi lain | Server mengembalikan `403`/`404`; aplikasi tidak membocorkan data |  |  |  |

## Uji Otorisasi Lintas Peran

| ID | Skenario | Langkah Uji | Hasil yang Diharapkan | Hasil | Bukti | Catatan |
|---|---|---|---|---|---|---|
| X-01 | Tamu ke fitur privat | Akses endpoint/layer navigasi Asesi, Asesor, dan Admin tanpa token | Ditolak dengan `401` atau dialihkan ke Login |  |  |  |
| X-02 | Asesi ke fitur Asesor | Dengan token Asesi, akses jadwal peserta, laporan, honor, atau tiket Asesor | Ditolak dengan `403`/`404` |  |  |  |
| X-03 | Asesor ke fitur Asesi | Dengan token Asesor, akses pendaftaran, portofolio, instansi, dan sertifikat privat Asesi | Ditolak dengan `403`/`404` |  |  |  |
| X-04 | Peran non-Admin ke aksi Admin | Dengan token Asesi/Asesor, buat/edit/hapus pengumuman, balas tiket sebagai Admin, atau ubah status jadwal | Ditolak dengan `403`; data tidak berubah |  |  |  |
| X-05 | Isolasi kepemilikan | Ganti ID sumber daya pada request milik akun kedua dengan token akun pertama | Data tidak tampil, diunduh, diubah, atau dihapus |  |  |  |
| X-06 | Token tidak valid | Hapus, ubah, atau gunakan token kedaluwarsa pada request privat | Server memberi `401`; aplikasi menampilkan alur sesi berakhir/login |  |  |  |

## Ringkasan Eksekusi

| Peran | Total Kasus | Lulus | Gagal | Tertunda | Penguji | Tanggal |
|---|---:|---:|---:|---:|---|---|
| Umum | 13 |  |  |  |  |  |
| Publik | 15 |  |  |  |  |  |
| Admin | 21 |  |  |  |  |  |
| Asesor | 17 |  |  |  |  |  |
| Asesi | 27 |  |  |  |  |  |
| Otorisasi lintas peran | 6 |  |  |  |  |  |
| **Total** | **99** |  |  |  |  |  |
