/// Guard identitas + tabel rute notifikasi.
///
/// File ini **murni Dart** (tanpa import Flutter) supaya logika guard/routing
/// hanya punya SATU versi dan bisa dipakai bersama oleh tiga entry point
/// notifikasi: foreground (`onMessage`), background (`onBackgroundMessage`),
/// dan klik notifikasi (banner / daftar notifikasi).
///
/// Backend adalah single source of truth untuk aturan bisnis & otorisasi:
/// FE **tidak** menduplikasi matriks izin tipe-notifikasi vs role. FE hanya
/// memverifikasi identitas penerima (`user_id`) dan role kanonikal penerima
/// (`target_role`) terhadap sesi login yang aktif, lalu memetakan tipe
/// notifikasi ke tujuan navigasi yang memang sudah ada di aplikasi.
library;

/// Tujuan navigasi kanonikal sebuah notifikasi.
enum NotificationDestination {
  /// Boleh dibaca di daftar notifikasi, tapi tidak punya tujuan navigasi.
  /// Dipakai untuk tipe tak dikenal, tawaran pekerjaan, dan produk digital.
  none,

  /// Halaman FAQ.
  faq,

  /// Tab Sertifikat/Statistik (tidak pernah membuka detail jadwal).
  sertifikat,

  /// Tab Jadwal (daftar jadwal).
  jadwal,

  /// Form umpan balik asesi (AK03) — hanya untuk role asesi.
  umpanBalikForm,
}

/// Identitas pemilik notifikasi (penerima).
///
/// Dibandingkan 1:1 dengan identitas sesi login aktif: `user_id` (ID `t_users`)
/// dan role kanonikal primer (`admin` / `asesor` / `asesi`).
class NotificationIdentity {
  final String userId;
  final String role;

  const NotificationIdentity({required this.userId, required this.role});

  /// Membangun identitas dari payload push. Mengembalikan `null` bila
  /// `user_id` atau `target_role` kosong/hilang — caller WAJIB memperlakukan
  /// `null` sebagai gagal (fail closed).
  static NotificationIdentity? fromPushData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final userId = (data['user_id'] ?? '').toString().trim();
    final role = (data['target_role'] ?? '').toString().trim().toLowerCase();
    if (userId.isEmpty || role.isEmpty) return null;
    return NotificationIdentity(userId: userId, role: role);
  }

  /// Membangun identitas dari nilai mentah (mis. sesi login).
  /// Mengembalikan `null` bila salah satu wajib kosong.
  static NotificationIdentity? of(Object? userId, Object? role) {
    final uid = (userId ?? '').toString().trim();
    final r = (role ?? '').toString().trim().toLowerCase();
    if (uid.isEmpty || r.isEmpty) return null;
    return NotificationIdentity(userId: uid, role: r);
  }

  /// Cocok hanya bila user DAN role kanonikal identik. Identitas yang tidak
  /// lengkap (`null`) selalu dianggap tidak cocok.
  bool matches(NotificationIdentity? other) =>
      other != null && userId == other.userId && role == other.role;
}

/// Tabel tipe notifikasi -> tujuan navigasi.
///
/// Tabel ini HANYA memetakan tipe ke layar/tab yang sudah ada; ia tidak
/// menyimpan aturan izin role (itu milik backend).
class NotificationGuard {
  NotificationGuard._();

  // Tipe kanonikal.
  static const String faq = 'faq';
  static const String statusKompeten = 'status_kompeten';
  static const String sertifikatTerbit = 'sertifikat_terbit';
  static const String sptAsesor = 'spt_asesor';
  static const String rekomendasiAsesor = 'rekomendasi_asesor';
  static const String pendaftaranAsesor = 'pendaftaran_asesor';
  static const String linkPersetujuanAsesmen = 'link_persetujuan_asesmen';
  static const String linkUmpanBalik = 'link_umpan_balik';
  static const String linkTugasPraktek = 'link_tugas_praktek';
  static const String linkKegiatanTerstruktur = 'link_kegiatan_terstruktur';

  /// Alias tipe lama yang mungkin masih dikirim backend versi sebelumnya.
  /// Backend menormalkan ini; FE tetap toleran agar build lama tidak salah rute.
  static const Map<String, String> _legacyAliases = {
    'persetujuan_asesmen': linkPersetujuanAsesmen,
    'umpan_balik': linkUmpanBalik,
    'tugas_praktek': linkTugasPraktek,
    'kegiatan_terstruktur': linkKegiatanTerstruktur,
  };

  /// Normalisasi tipe: trim + lowercase + alias lama -> tipe kanonikal.
  static String normalizeType(Object? rawType) {
    final type = (rawType ?? '').toString().trim().toLowerCase();
    return _legacyAliases[type] ?? type;
  }

  /// Tujuan navigasi untuk sebuah tipe notifikasi.
  ///
  /// Tipe tak dikenal, `tawaran_pekerjaan`, dan produk digital sengaja
  /// mengembalikan [NotificationDestination.none] supaya tidak pernah membuka
  /// Jadwal secara asal.
  static NotificationDestination destinationFor(
    Object? rawType, {
    bool isAsesi = false,
  }) {
    switch (normalizeType(rawType)) {
      case faq:
        return NotificationDestination.faq;
      case statusKompeten:
      case sertifikatTerbit:
        return NotificationDestination.sertifikat;
      case linkUmpanBalik:
        return isAsesi
            ? NotificationDestination.umpanBalikForm
            : NotificationDestination.jadwal;
      case sptAsesor:
      case rekomendasiAsesor:
      case linkPersetujuanAsesmen:
      case linkTugasPraktek:
      case linkKegiatanTerstruktur:
      case pendaftaranAsesor:
        return NotificationDestination.jadwal;
      default:
        return NotificationDestination.none;
    }
  }

  /// Apakah tipe ini punya tujuan navigasi nyata di aplikasi.
  ///
  /// Dipakai UI untuk hanya menampilkan tombol aksi bila rutenya memang ada —
  /// tipe tak dikenal / tawaran pekerjaan / produk digital tidak boleh
  /// menampilkan tombol yang jatuh ke Jadwal.
  static bool hasAction(Object? rawType, {bool isAsesi = false}) {
    return destinationFor(rawType, isAsesi: isAsesi) !=
        NotificationDestination.none;
  }

  /// Index tab pada `MainNavigator` yang sesuai dengan tipe notifikasi.
  ///
  /// Layout tab yang ada:
  /// - asesor: 0 Dashboard, 1 Jadwal, 2 AI, 3 Statistik, 4 Asesi, 5 Marketing
  /// - asesi : 0 Dashboard, 1 Skema, 2 Jadwal, 3 Sertifikat, 4 Profil
  /// - admin : 0 Dashboard, 1 Statistik, 2 Jadwal, 3 Sertifikat, 4 Profil
  ///
  /// Mengembalikan `-1` bila tidak boleh pindah tab (FAQ / tanpa tujuan).
  static int tabIndexFor(
    Object? rawType, {
    required String primaryRole,
    bool isAsesi = false,
  }) {
    final destination = destinationFor(rawType, isAsesi: isAsesi);
    final isAsesor = primaryRole.trim().toLowerCase() == 'asesor';
    final jadwalTab = isAsesor ? 1 : 2;

    if (destination == NotificationDestination.sertifikat) {
      return 3; // Tab Sertifikat/Statistik (sama untuk asesor, asesi, admin)
    }
    if (destination == NotificationDestination.jadwal ||
        destination == NotificationDestination.umpanBalikForm) {
      return jadwalTab;
    }
    // FAQ punya layar sendiri dan tipe tanpa tujuan tidak memindahkan tab.
    return -1;
  }
}
