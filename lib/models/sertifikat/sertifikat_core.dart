// ============================================================================
// Sertifikat Models — inti (item sertifikat, ringkasan, distribusi, meta)
// ============================================================================

class SertifikatItem {
  final int id;
  final String skema;
  final String pemegang;
  final String nomorSertifikat;
  final String tanggalTerbit;
  final String tanggalBerlaku;
  final String status; // 'aktif', 'kadaluarsa', 'akan_kadaluarsa'
  final String kategori; // 'Digital Marketing', 'Informatika', dll
  final String? institusi;
  final String nomorRegistrasi;
  final String nomorBlanko;
  final String nomorSeri;
  final String tempatUji;
  final String namaAsesor;
  final String namaJadwal;
  final String tanggalAsesmen;
  final int jadwalId;
  final String fileSertifikat;
  final String fileSertifikatBelakang;
  final String fileSertifikatPreview;
  final String fileSertifikatDownload;
  final String fileSertifikatBelakangPreview;
  final String fileSertifikatBelakangDownload;
  const SertifikatItem({
    required this.id,
    required this.skema,
    required this.pemegang,
    required this.nomorSertifikat,
    required this.tanggalTerbit,
    required this.tanggalBerlaku,
    required this.status,
    required this.kategori,
    this.institusi,
    this.nomorRegistrasi = '',
    this.nomorBlanko = '',
    this.nomorSeri = '',
    this.tempatUji = '',
    this.namaAsesor = '',
    this.namaJadwal = '',
    this.tanggalAsesmen = '',
    this.jadwalId = 0,
    this.fileSertifikat = '',
    this.fileSertifikatBelakang = '',
    this.fileSertifikatPreview = '',
    this.fileSertifikatDownload = '',
    this.fileSertifikatBelakangPreview = '',
    this.fileSertifikatBelakangDownload = '',
  });

  factory SertifikatItem.fromJson(Map<String, dynamic> json) {
    final skemaMap = json['skema'] is Map<String, dynamic> ? json['skema'] : {};
    final asesorMap = json['asesor'] is Map<String, dynamic>
        ? json['asesor']
        : {};

    return SertifikatItem(
      id: json['id'] ?? 0,
      skema: json['skema'] is String
          ? json['skema']
          : (skemaMap['nama_skema'] ?? ''),
      pemegang: json['pemegang'] ?? '',
      nomorSertifikat: json['no_sertifikat'] ?? json['nomor_sertifikat'] ?? '',
      tanggalTerbit: json['tanggal_terbit'] ?? '',
      tanggalBerlaku:
          json['tanggal_kadaluarsa'] ?? json['tanggal_berlaku'] ?? '',
      status: json['status_sertifikat'] ?? json['status'] ?? 'aktif',
      kategori: json['kategori'] is String
          ? json['kategori']
          : (skemaMap['kategori'] ?? ''),
      institusi: json['institusi'],
      nomorRegistrasi: json['nomor_registrasi'] ?? '',
      nomorBlanko: json['nomor_blanko'] ?? '',
      nomorSeri: json['nomor_seri'] ?? '',
      tempatUji: json['tempat_uji'] ?? json['tuk'] ?? '',
      namaAsesor: json['nama_asesor'] ?? asesorMap['nama'] ?? '',
      namaJadwal: json['nama_jadwal'] ?? '',
      tanggalAsesmen: json['tanggal_asesmen'] ?? '',
      jadwalId: json['jadwal_id'] ?? 0,
      fileSertifikat: json['file_sertifikat'] ?? '',
      fileSertifikatBelakang: json['file_sertifikat_belakang'] ?? '',
      fileSertifikatPreview: json['file_sertifikat_preview'] ?? '',
      fileSertifikatDownload: json['file_sertifikat_download'] ?? '',
      fileSertifikatBelakangPreview: json['file_sertifikat_belakang_preview'] ?? '',
      fileSertifikatBelakangDownload: json['file_sertifikat_belakang_download'] ?? '',
    );
  }
}


class SertifikatDistribusi {
  final int idSkema;
  final String kodeSkema;
  final String skema;
  final String kategori;
  final int totalPemegang;
  final double persentase;
  final String color;

  const SertifikatDistribusi({
    required this.idSkema,
    required this.kodeSkema,
    required this.skema,
    required this.kategori,
    required this.totalPemegang,
    required this.persentase,
    required this.color,
  });

  factory SertifikatDistribusi.fromJson(
    Map<String, dynamic> json, {
    double? persentase,
    String? color,
  }) {
    return SertifikatDistribusi(
      idSkema: json['id_skema'] ?? 0,
      kodeSkema: json['kode_skema'] ?? '',
      skema: json['skema'] ?? '',
      kategori: json['kategori'] ?? '',
      totalPemegang: json['total_pemegang'] ?? 0,
      persentase: persentase ?? 0.0,
      color: color ?? '5B9FD8',
    );
  }
}

class SertifikatApiResponse {
  final List<SertifikatDistribusi> data;
  final SertifikatMeta meta;

  const SertifikatApiResponse({required this.data, required this.meta});

  factory SertifikatApiResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    final meta = SertifikatMeta.fromJson(json['meta'] ?? {});

    final colors = [
      '0D47A1', // Dark Blue
      '1976D2', // Bright Blue
      '42A5F5', // Mid Blue
      '64B5F6', // Light Blue
      '90CAF9', // Very Light Blue
      'BBDEFB', // Extra Light Blue
      '5B9FD8', // Default Blue
    ];

    // Calculate total from current data list (not from meta)
    // This ensures percentages add up to 100% for the displayed items
    int totalFromData = 0;
    for (var item in dataList) {
      totalFromData += (item['total_pemegang'] ?? 0) as int;
    }

    final List<SertifikatDistribusi> distribusiList = [];
    for (int i = 0; i < dataList.length; i++) {
      final item = dataList[i];
      final totalPemegang = item['total_pemegang'] ?? 0;
      // Calculate percentage based on displayed data total
      final persentase = totalFromData > 0
          ? (totalPemegang / totalFromData * 100)
          : 0.0;
      final color = colors[i % colors.length];

      distribusiList.add(
        SertifikatDistribusi.fromJson(
          item,
          persentase: persentase,
          color: color,
        ),
      );
    }

    return SertifikatApiResponse(data: distribusiList, meta: meta);
  }
}

class SertifikatMeta {
  final int totalSkema;
  final int totalPemegangSertifikat;
  final int? tahunFilter;
  final int limit;
  final String? periode;
  final String? tanggalUpdate;

  const SertifikatMeta({
    required this.totalSkema,
    required this.totalPemegangSertifikat,
    this.tahunFilter,
    required this.limit,
    this.periode,
    this.tanggalUpdate,
  });

  factory SertifikatMeta.fromJson(Map<String, dynamic> json) {
    return SertifikatMeta(
      totalSkema: json['total_skema'] ?? 0,
      totalPemegangSertifikat: json['total_pemegang_sertifikat'] ?? 0,
      tahunFilter: json['tahun_filter'],
      limit: json['limit'] ?? 10,
      periode: json['periode'],
      tanggalUpdate: json['tanggal_update'],
    );
  }
}
