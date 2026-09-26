import '../utils/json_helper.dart';
import 'jadwal_models.dart';
import 'sertifikat_models.dart';

// ============================================================================
// Asesi Dashboard Summary Model
// ============================================================================

class AsesiDashboardSummary {
  final int totalJadwalDiikuti;
  final int sertifikatDiterima;
  final int tukTerdekat;
  final int skemaPernahDijalani;
  /// Profile ringkasan fields
  final int sertifikatAktif;
  final int skemaKompetensi;
  final int sertifikatKadaluarsa;
  final int totalUjiKompetensi;
  final bool hasAlert;
  final String alertTitle;
  final String alertSubtitle;
  final AsesiTimelineTerakhir timelineTerakhir;
  final List<SertifikatItem> sertifikatList;

  const AsesiDashboardSummary({
    required this.totalJadwalDiikuti,
    required this.sertifikatDiterima,
    required this.tukTerdekat,
    required this.skemaPernahDijalani,
    this.sertifikatAktif = 0,
    this.skemaKompetensi = 0,
    this.sertifikatKadaluarsa = 0,
    this.totalUjiKompetensi = 0,
    this.hasAlert = false,
    this.alertTitle = '',
    this.alertSubtitle = '',
    this.timelineTerakhir = const AsesiTimelineTerakhir(),
    this.sertifikatList = const [],
  });

  factory AsesiDashboardSummary.fromJson(Map<String, dynamic> json) {
    // Check if the json has a nested 'summary' key (from /api/asesi/dashboard)
    final Map<String, dynamic> summary = json['summary'] is Map<String, dynamic>
        ? json['summary']
        : json;
    final Map<String, dynamic> alert = json['alert_banner'] is Map<String, dynamic>
        ? json['alert_banner']
        : {};

    final skemaDiikuti = JsonHelper.asInt(
      summary['skema_diikuti'] ?? summary['total_jadwal_diikuti'],
    );
    final sertAktif = JsonHelper.asInt(
      summary['sertifikat_aktif'] ?? summary['sertifikat_diterima'],
    );
    final skemaKomp = JsonHelper.asInt(
      summary['skema_kompetensi'] ?? summary['hasil_asesmen'],
    );
    final sertKadal = JsonHelper.asInt(summary['sertifikat_kadaluarsa']);
    final tuk = JsonHelper.asInt(summary['tuk_terdekat'] ?? json['tuk_terdekat']);
    final hasil = JsonHelper.asInt(
      summary['hasil_asesmen'] ?? summary['skema_pernah_dijalani'],
    );

    final timeline = AsesiTimelineTerakhir.fromJson(
      json['timeline_terakhir'] is Map<String, dynamic>
          ? json['timeline_terakhir']
          : null,
    );

    final rawCerts = json['sertifikat_list'];
    final List<SertifikatItem> parsedCerts = [];
    if (rawCerts is List) {
      for (final c in rawCerts) {
        if (c is Map<String, dynamic>) {
          parsedCerts.add(SertifikatItem.fromJson(c));
        }
      }
    }
    return AsesiDashboardSummary(
      totalJadwalDiikuti: skemaDiikuti,
      sertifikatDiterima: sertAktif,
      tukTerdekat: tuk,
      skemaPernahDijalani: hasil,
      sertifikatAktif: sertAktif,
      skemaKompetensi: skemaKomp,
      sertifikatKadaluarsa: sertKadal,
      totalUjiKompetensi: skemaDiikuti,
      hasAlert: alert['has_alert'] == true,
      alertTitle: alert['title']?.toString() ?? '',
      alertSubtitle: alert['subtitle']?.toString() ?? '',
      timelineTerakhir: timeline,
      sertifikatList: parsedCerts,
    );
  }

  factory AsesiDashboardSummary.empty() {
    return const AsesiDashboardSummary(
      totalJadwalDiikuti: 0,
      sertifikatDiterima: 0,
      tukTerdekat: 0,
      skemaPernahDijalani: 0,
      sertifikatAktif: 0,
      skemaKompetensi: 0,
      sertifikatKadaluarsa: 0,
      totalUjiKompetensi: 0,
      hasAlert: false,
      alertTitle: '',
      alertSubtitle: '',
      timelineTerakhir: AsesiTimelineTerakhir(),
      sertifikatList: const [],
    );
  }
}

// ============================================================================
// Asesi Timeline Models
// ============================================================================

class AsesiTimelineTerakhir {
  final bool hasUji;
  final int asesiId;
  final int jadwalId;
  final String namaJadwal;
  final String tanggalMulai;
  final String tanggalAkhir;
  final String tuk;
  final String namaAsesor;
  final int skemaId;
  final String namaSkema;
  final String kodeSkema;
  final String statusJadwal;
  final String statusLabel;
  final String currentStep;
  final List<AsesiTimelineStep> steps;
  final bool isSertifikatTerbit;
  final String noSertifikat;
  final String noRegistrasi;
  final String noSeri;
  final String tanggalTerbit;
  final String tanggalBerlaku;
  final String masaBerlaku;

  const AsesiTimelineTerakhir({
    this.hasUji = false,
    this.asesiId = 0,
    this.jadwalId = 0,
    this.namaJadwal = '',
    this.tanggalMulai = '',
    this.tanggalAkhir = '',
    this.tuk = '',
    this.namaAsesor = '',
    this.skemaId = 0,
    this.namaSkema = '',
    this.kodeSkema = '',
    this.statusJadwal = '0',
    this.statusLabel = 'Aktif',
    this.currentStep = 'apl01',
    this.steps = const [],
    this.isSertifikatTerbit = false,
    this.noSertifikat = '',
    this.noRegistrasi = '',
    this.noSeri = '',
    this.tanggalTerbit = '',
    this.tanggalBerlaku = '',
    this.masaBerlaku = '',
  });

  factory AsesiTimelineTerakhir.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['has_uji'] != true) {
      return const AsesiTimelineTerakhir();
    }

    final rawSteps = json['steps'];
    final List<AsesiTimelineStep> parsedSteps = [];
    if (rawSteps is List) {
      for (final s in rawSteps) {
        if (s is Map<String, dynamic>) {
          parsedSteps.add(AsesiTimelineStep.fromJson(s));
        }
      }
    }

    return AsesiTimelineTerakhir(
      hasUji: json['has_uji'] == true,
      asesiId: JsonHelper.asInt(json['asesi_id']),
      jadwalId: JsonHelper.asInt(json['jadwal_id']),
      namaJadwal: json['nama_jadwal']?.toString() ?? '',
      tanggalMulai: json['tanggal_mulai']?.toString() ?? '',
      tanggalAkhir: json['tanggal_akhir']?.toString() ?? '',
      tuk: json['tuk']?.toString() ?? '',
      namaAsesor: json['nama_asesor']?.toString() ?? '',
      skemaId: JsonHelper.asInt(json['skema_id']),
      namaSkema: json['nama_skema']?.toString() ?? '',
      kodeSkema: json['kode_skema']?.toString() ?? '',
      statusJadwal: json['status_jadwal']?.toString() ?? '0',
      statusLabel: json['status_label']?.toString() ?? 'Aktif',
      currentStep: json['current_step']?.toString() ?? 'apl01',
      steps: parsedSteps,
      isSertifikatTerbit: json['is_sertifikat_terbit'] == true,
      noSertifikat: json['no_sertifikat']?.toString() ?? '',
      noRegistrasi: json['no_registrasi']?.toString() ?? '',
      noSeri: json['no_seri']?.toString() ?? '',
      tanggalTerbit: json['tanggal_terbit']?.toString() ?? '',
      tanggalBerlaku: json['tanggal_berlaku']?.toString() ?? '',
      masaBerlaku: json['masa_berlaku']?.toString() ?? '',
    );
  }

  JadwalItem toJadwalItem() {
    return JadwalItem(
      id: jadwalId,
      skema: namaSkema,
      tuk: tuk,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalAkhir.isNotEmpty ? tanggalAkhir : tanggalMulai,
      status: statusJadwal == '1' ? 'completed' : (statusJadwal == '3' ? 'running' : 'draft'),
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      jumlahAsesi: 1,
      asesor: namaAsesor.isNotEmpty ? [namaAsesor] : const [],
    );
  }
}

class AsesiTimelineStep {
  final String key;
  final String title;
  final String subtitle;
  final String status;
  final String statusLabel;
  final bool isActive;
  final bool canClick;

  const AsesiTimelineStep({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    this.isActive = false,
    this.canClick = false,
  });

  factory AsesiTimelineStep.fromJson(Map<String, dynamic> json) {
    return AsesiTimelineStep(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      isActive: json['is_active'] == true,
      canClick: json['can_click'] == true,
    );
  }
}
