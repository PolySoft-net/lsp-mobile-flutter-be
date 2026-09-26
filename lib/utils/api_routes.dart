// ============================================================================
// API Routes Constants
// ============================================================================
// Konstanta untuk semua API routes yang digunakan dalam aplikasi

class ApiRoutes {
  // ============================================================================
  // Dashboard Routes (Enhanced)
  // ============================================================================

  static const String dashboardSummary = '/api/dashboard/summary';
  static const String dashboardStatistikOverview =
      '/api/dashboard/statistik-overview';
  static const String dashboardDistribusiSektor =
      '/api/dashboard/distribusi-sektor';
  static const String dashboardAsesorStats = '/api/dashboard/asesor-stats';
  static const String dashboardLspCount = '/api/dashboard/lsp-count';
  static const String dashboardMonthlyAssessments =
      '/api/dashboard/monthly-assessments';
  static const String dashboardAssessmentGraph =
      '/api/dashboard/assesmen-graph';
  static const String dashboardPenyebaranRegional =
      '/api/dashboard/penyebaran-regional';
  static const String dashboardTrends = '/api/dashboard/trends';
  static const String dashboardSertifikatPerSkema =
      '/api/dashboard/sertifikat-per-skema';
  static const String dashboardSertifikatSummary =
      '/api/dashboard/sertifikat-summary';
  static const String dashboardAsesorDistribution =
      '/api/dashboard/asesor-distribution';
  static const String dashboardPenyebaranTuk = '/api/dashboard/penyebaran-tuk';
  static const String dashboardPenyebaranWilayahDetail =
      '/api/dashboard/penyebaran-wilayah/detail';
  static const String dashboardPenyebaranMitra =
      '/api/dashboard/penyebaran-mitra';
  static const String dashboardSebaranSkemaAsesor =
      '/api/dashboard/sebaran-skema-asesor';

  static const String dashboardDomisiliAsesor =
      '/api/dashboard/domisili-asesor';
  static String dashboardDomisiliAsesorDetail(String provinsiId) =>
      '/api/dashboard/domisili-asesor/$provinsiId/asesor';
  static const String dashboardKompetensiTeknis =
      '/api/dashboard/kompetensi-teknis';
  static String dashboardKompetensiTeknisDetail(dynamic skemaId) =>
      '/api/dashboard/kompetensi-teknis/$skemaId/asesor';
  static const String dashboardMasaBerlakuAsesor =
      '/api/dashboard/masa-berlaku-asesor';
  static const String dashboardMasaBerlakuAsesorDetail =
      '/api/dashboard/masa-berlaku-asesor/detail';
  static const String dashboardMasaTenggangSertifikat =
      '/api/dashboard/masa-tenggang-sertifikat';
  static const String dashboardJenisSkema = '/api/dashboard/jenis-skema';
  static const String dashboardMukDistribusi = '/api/dashboard/muk-distribusi';
  static String dashboardMukDistribusiDetail(dynamic skemaId) =>
      '/api/dashboard/muk-distribusi/$skemaId/perangkat';
  static const String dashboardSptAsesor2026 = '/api/dashboard/spt-asesor-2026';
  static String dashboardSptAsesorJadwal(int asesorId) =>
      '/api/dashboard/spt-asesor/$asesorId/jadwal';
  static const String asesi2026 = '/api/dashboard/asesi-2026';

  // ============================================================================
  // Admin Honor Asesor Routes
  // ============================================================================

  static const String adminHonorAsesor = '/api/admin/honor-asesor';
  static String adminHonorAsesorTugas(int asesorId) =>
      '/api/admin/honor-asesor/$asesorId/tugas';
  static String adminHonorAsesorTugasDetail(int tugasId) =>
      '/api/admin/honor-asesor/tugas/$tugasId';

  // ============================================================================
  // Admin Blanko Routes
  // ============================================================================

  static const String adminBlanko = '/api/admin/blanko';
  static String adminBlankoDetail(dynamic id) => '/api/admin/blanko/$id';

  // ============================================================================
  // Jadwal Routes
  // ============================================================================

  static const String jadwalOutOfDate = '/api/jadwal/out-of-date';
  static const String jadwalBaru = '/api/jadwal/baru';
  static const String jadwalActive = '/api/jadwal/active';
  static const String jadwalCompleted = '/api/jadwal/completed';
  static const String jadwalStatistics = '/api/jadwal/statistics';
  static const String jadwalUpdateStatus = '/api/jadwal/update-status';
  static const String jadwalUpdateStatusApply =
      '/api/jadwal/update-status/apply';
  static const String jadwalNotificationsCount =
      '/api/jadwal/notifications/count';
  static const String jadwalWaiting = '/api/jadwal/waiting';
  static const String jadwalDraft = '/api/jadwal/draft';
  static String jadwalAsesi(int jadwalId) => '/api/jadwal/$jadwalId/asesi';
  static String jadwalAsesorDetail(int jadwalId) =>
      '/api/jadwal/$jadwalId/asesor-detail';

  // ============================================================================
  // Sertifikat Routes
  // ============================================================================

  static const String sertifikatSearch = '/api/sertifikat/search';
  static const String sertifikatValidate = '/api/sertifikat/validate';
  static const String talenta = '/api/talenta';

  // Skema Sertifikasi (protected, role=asesi)
  static const String sertifikatSkema = '/api/sertifikat/skema';
  static const String sertifikatSkemaBidang = '/api/sertifikat/skema/bidang';
  static String sertifikatSkemaDetail(int id) => '/api/sertifikat/skema/$id';
  static String sertifikatSkemaAsesor(int skemaId) =>
      '/api/sertifikat/skema/$skemaId/asesor';

  // ============================================================================
  // Pra-Asesmen Routes
  // ============================================================================

  static String praAsesmenSkemaInfo(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/info';
  static String praAsesmenSkemaKompetensi(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/kompetensi';
  static String praAsesmenSkemaSubmit(int skemaId) =>
      '/api/pra-asesmen/skema/$skemaId/submit';

  // ============================================================================
  // Ujian (Tes Tertulis) — universal paths
  // ============================================================================

  static String ujianSkema(int skemaId) => '/api/ujian/skema/$skemaId';
  static String ujianSkemaSoal(int skemaId) => '/api/ujian/skema/$skemaId/soal';
  static String ujianSoalByExam(int examId) => '/api/ujian/soal/$examId';
  static String ujianSubmit(int asesiId) => '/api/ujian/$asesiId/submit';

  // ============================================================================
  // Sertifikasi Routes
  // ============================================================================

  static const String sertifikasiDaftar = '/api/sertifikasi/daftar';
  static const String sertifikasiStatus = '/api/sertifikasi/status';
  static String sertifikasiPortofolio(int sertifikasiId) =>
      '/api/sertifikasi/$sertifikasiId/portofolio';
  static String sertifikasiPortofolioUpload(int sertifikasiId) =>
      '/api/sertifikasi/$sertifikasiId/portofolio/upload';

  // ============================================================================
  // Auth Routes
  // ============================================================================

  static const String authLogin = '/api/auth/login';
  static const String authGoogle = '/api/auth/google';
  static const String authForgotPassword = '/api/auth/forgot-password';
  static const String authCurrent = '/api/auth/current';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  static const String uploadFotoProfil = '/api/user/upload-foto';

  /// Public: create asesi (NIM/NIK + default password 123456) if missing, return tokens
  static const String authEnsureAsesi = '/api/auth/ensure-asesi';

  // ============================================================================
  // Notifications Routes
  // ============================================================================

  static const String notificationsRegister = '/api/notifications/register';

  // ============================================================================
  // Asesi Routes
  // ============================================================================

  static const String asesiDashboard = '/api/asesi/dashboard';
  static const String asesiInstansi = '/api/asesi/instansi';
  static const String asesiSertifikat = '/api/asesi/sertifikat';
  static const String asesiJadwal = '/api/asesi/jadwal';
  static String asesiAK03(int jadwalId) => '/api/asesi/jadwal/$jadwalId/ak03';
  static String asesiSertifikatDetail(int id) => '/api/asesi/sertifikat/$id';
  static String asesiSertifikatUploadTtd(int id) =>
      '/api/asesi/sertifikat/$id/upload-ttd';
  static String asesiSertifikatDownload(int id) =>
      '/api/asesi/sertifikat/$id/download';
  static const String asesiECertificate = '/api/asesi/e-certificate';
  static String asesiECertificateView({int? idAsesi, String? token}) {
    final query = <String>[];
    if (idAsesi != null && idAsesi > 0) query.add('id_asesi=$idAsesi');
    if (token != null && token.isNotEmpty) query.add('token=$token');
    return query.isEmpty
        ? '/api/asesi/e-certificate/view'
        : '/api/asesi/e-certificate/view?${query.join('&')}';
  }
  static String asesiECertificateDownload({int? idAsesi, String? token}) {
    final query = <String>[];
    if (idAsesi != null && idAsesi > 0) query.add('id_asesi=$idAsesi');
    if (token != null && token.isNotEmpty) query.add('token=$token');
    return query.isEmpty
        ? '/api/asesi/e-certificate/download'
        : '/api/asesi/e-certificate/download?${query.join('&')}';
  }

  // ============================================================================
  // Asesor Routes
  // ============================================================================

  static const String asesorDashboard = '/api/asesor/dashboard';
  static const String asesorMUK = '/api/asesor/muk';
  static const String asesorStatistikBulanan = '/api/asesor/statistik-bulanan';
  static const String asesorJadwal = '/api/asesor/jadwal';
  static const String asesorLaporan = '/api/asesor/laporan';
  static const String asesorLaporanUploadLampiran =
      '/api/asesor/laporan/upload-lampiran';
  static const String asesorSkemaTuk = '/api/asesor/skema-tuk';
  static const String asesorProfile = '/api/asesor/profile';
  static const String asesorHonor = '/api/asesor/honor';
  static const String asesorTiket = '/api/asesor/tiket';
  static const String asesorTiketUploadDokumentasi =
      '/api/asesor/tiket/upload-dokumentasi';
  static String asesorLaporanDetail(int id) => '/api/asesor/laporan/$id';
  static String asesorJadwalPeserta(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/peserta';
  static String asesorJadwalPesertaDetail(int jadwalId, int pesertaId) =>
      '/api/asesor/jadwal/$jadwalId/peserta/$pesertaId';
  static String asesorJadwalPesertaAssignment(int jadwalId, int pesertaId) =>
      '/api/asesor/jadwal/$jadwalId/peserta/$pesertaId/assignment';
  static String asesorJadwalDetail(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/detail';
  static String asesorJadwalSuratTugas(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/surat-tugas';
  static String asesorJadwalAK05(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/ak05';
  static String asesorJadwalAK06(int jadwalId) =>
      '/api/asesor/jadwal/$jadwalId/ak06';
  static String asesorTiketDetail(int id) => '/api/asesor/tiket/$id';
  static String asesorTiketReply(int id) => '/api/asesor/tiket/$id/reply';
  static const String asesorAiChat = '/api/asesor/ai/chat';
  static const String publicAiChat = '/api/ai/chat';
  static const String asesorLeads = '/api/asesor/leads';
  static const String asesorLeadsStats = '/api/asesor/leads/stats';
  static const String asesorLeadsRegisteredPlaces =
      '/api/asesor/leads/registered-places';
  static String asesorLeadDetail(String id) => '/api/asesor/leads/$id';
  static String asesorLeadStatus(String id) => '/api/asesor/leads/$id/status';

  // ============================================================================
  // Admin Tiket Routes
  // ============================================================================

  static const String adminTiket = '/api/admin/tiket';
  static String adminTiketDetail(int id) => '/api/admin/tiket/$id';
  static String adminTiketReply(int id) => '/api/admin/tiket/$id/reply';
  static String adminTiketStatus(int id) => '/api/admin/tiket/$id/status';

  // ============================================================================
  // Session Routes
  // ============================================================================

  static const String sessions = '/api/sessions';

  // ============================================================================
  // Berita Routes
  // ============================================================================

  static const String berita = '/api/berita';
  static String beritaDetail(int id) => '/api/berita/$id';
  static const String adminBerita = '/api/admin/berita';
  static String adminBeritaDetail(int id) => '/api/admin/berita/$id';
  static const String adminBeritaUploadFoto = '/api/admin/berita/upload-foto';
  static const String fileSignedUrl = '/api/files/signed-url';

  // ============================================================================
  // Digital Product Routes
  // ============================================================================

  static const String digitalProducts = '/api/digital-products';
  static const String digitalProductFavorites =
      '/api/digital-products/favorites';
  static const String digitalProductMine = '/api/digital-products/mine';
  static const String digitalProductProfile = '/api/digital-products/profile';
  static String digitalProductDetail(dynamic id) => '/api/digital-products/$id';
  static String digitalProductFavorite(dynamic id) =>
      '/api/digital-products/$id/favorite';
  static String digitalProductPopular({int limit = 10}) =>
      '/api/digital-products/popular?limit=$limit';

  // ============================================================================
  // Health Routes
  // ============================================================================

  static const String health = '/api/health';
  static const String ready = '/api/ready';

  // ============================================================================
  // Wilayah/Master Routes
  // ============================================================================

  static const String wilayahTukPerKabupaten = '/api/wilayah/tuk-per-kabupaten';
  static const String masterProvinsi = '/api/master/provinsi';
  static const String masterKabupaten = '/api/master/kabupaten';
  static const String masterKecamatan = '/api/master/kecamatan';
  static const String masterSkema = '/api/master/skema';
  static String masterSkemaUnitPersyaratan(int id) =>
      '/api/master/skema/$id/unit-persyaratan';
  static const String masterJadwal = '/api/master/jadwal';
  static const String masterSumberAnggaran = '/api/master/sumber-anggaran';
  static const String masterPemberiAnggaran = '/api/master/pemberi-anggaran';
  static const String masterPendidikan = '/api/master/pendidikan';
  static const String masterPekerjaan = '/api/master/pekerjaan';
  static const String asesiProfile = '/api/asesi/profile';

  // ============================================================================
  // Helper Methods untuk build URL dengan query parameters
  // ============================================================================

  /// Build URL dengan period parameter
  static String withPeriod(String route, String period) {
    return '$route?period=$period';
  }

  /// Build URL dengan months parameter
  static String withMonths(String route, int months) {
    return '$route?months=$months';
  }

  /// Build URL dengan limit parameter
  static String withLimit(String route, int limit) {
    return '$route?limit=$limit';
  }

  /// Build URL dengan limit dan include_invalid parameters
  static String withLimitAndIncludeInvalid(
    String route,
    int limit,
    bool includeInvalid,
  ) {
    return '$route?limit=$limit&include_invalid=$includeInvalid';
  }

  /// Build URL dengan provinsi_id parameter
  static String withProvinsiId(String route, int provinsiId) {
    return '$route?provinsi_id=$provinsiId';
  }

  /// Build URL dengan metric dan compare_period parameters
  static String withTrendsParams(
    String route,
    String metric,
    String comparePeriod,
  ) {
    return '$route?metric=$metric&compare_period=$comparePeriod';
  }

  /// Build URL dengan multiple filters untuk monthly assessments
  static String withMonthlyAssessmentsFilters(
    String route, {
    int? months,
    int? provinsiId,
    String? sektor,
    int? idLsp,
    int? idTuk,
  }) {
    final params = <String>[];
    if (months != null) params.add('months=$months');
    if (provinsiId != null) params.add('provinsi_id=$provinsiId');
    if (sektor != null) params.add('sektor=$sektor');
    if (idLsp != null) params.add('id_lsp=$idLsp');
    if (idTuk != null) params.add('id_tuk=$idTuk');

    return params.isEmpty ? route : '$route?${params.join('&')}';
  }

  /// Build URL dengan multiple filters untuk jadwal
  static String withJadwalFilters(
    String route, {
    int? limit,
    int? offset,
    String? statusJadwal,
    int? idTuk,
    String? idLsp,
    String? search,
    String? tanggalAsesmen,
    String? tuk,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String>[];
    if (limit != null) params.add('limit=$limit');
    if (offset != null) params.add('offset=$offset');
    if (statusJadwal != null) params.add('status_jadwal=$statusJadwal');
    if (idTuk != null) params.add('id_tuk=$idTuk');
    if (idLsp != null) params.add('id_lsp=$idLsp');
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (tanggalAsesmen != null && tanggalAsesmen.trim().isNotEmpty) {
      params.add(
        'tanggal_asesmen=${Uri.encodeQueryComponent(tanggalAsesmen.trim())}',
      );
    }
    if (tuk != null && tuk.trim().isNotEmpty) {
      params.add('tuk=${Uri.encodeQueryComponent(tuk.trim())}');
    }
    if (sortBy != null) params.add('sort_by=$sortBy');
    if (sortOrder != null) params.add('sort_order=$sortOrder');

    return params.isEmpty ? route : '$route?${params.join('&')}';
  }

  // Asesor Asesi Routes
  static const String asesorAsesi = '/api/asesor/asesi';
  static String asesorAsesiDetail(int id) => '/api/asesor/asesi/$id';
  static String asesorAsesiUpdateRekomendasi(int id) =>
      '/api/asesor/asesi/$id/rekomendasi';
  static String asesorAsesiUpdateAK01(int id) => '/api/asesor/asesi/$id/ak01';
  static String asesorAsesiUpdateAPL02(int id) => '/api/asesor/asesi/$id/apl02';
  static String asesorAsesiUpdateAK02(int id) => '/api/asesor/asesi/$id/ak02';
  static String asesorAsesiIA01(int id) => '/api/asesor/asesi/$id/ia01';
  static String asesorAsesiIA02(int id) => '/api/asesor/asesi/$id/ia02';
  static String asesorAsesiIA03(int id) => '/api/asesor/asesi/$id/ia03';
  static String asesorAsesiIA04A(int id) => '/api/asesor/asesi/$id/ia04a';
  static String asesorAsesiIA04B(int id) => '/api/asesor/asesi/$id/ia04b';
  static String asesorAsesiIA05(int id) => '/api/asesor/asesi/$id/ia05';
  static String asesorAsesiIA11(int id) => '/api/asesor/asesi/$id/ia11';
  static String asesorAsesiIA04Upload(int id) =>
      '/api/asesor/asesi/$id/ia04/upload';
}
