import 'dart:ui';

import '../utils/json_helper.dart';

List<String> _parseAsesor(dynamic jsonVal) {
  if (jsonVal == null) {
    return [];
  }
  if (jsonVal is List) {
    return jsonVal
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (jsonVal is String) {
    final trimmed = jsonVal.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return [];
    }
    return [trimmed];
  }
  return [];
}

class JadwalItem {
  final int id;
  final String skema;
  final String tuk;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String createdWhen;

  /// Canonical internal status:
  /// draft(0) | completed(1) | canceled(2) | running(3) | pelaporan(4)
  final String status;

  /// Raw DB code: 0/1/2/3/4
  final String statusJadwal;

  /// Label dari BE (`status_label`), mis. Draft / Running
  final String statusLabel;
  final String statusJadwalLabel;
  final String statusRekaman;
  final String statusBlanko;
  final String statusPengiriman;
  final int jumlahAsesi;
  final List<String> asesor;
  final int sisaHari;
  final int?
  daysLate; // days_late — relevan untuk running (status_jadwal = "3")
  final String? catatan;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;
  final bool needsAcc;
  final int? kuota;
  final String? jenisAsesmen;
  final String? jenisUji;
  final bool? isAjj;

  const JadwalItem({
    required this.id,
    required this.skema,
    required this.tuk,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.createdWhen = '',
    required this.status,
    this.statusJadwal = '0',
    this.statusLabel = '',
    this.statusJadwalLabel = '',
    this.statusRekaman = '',
    this.statusBlanko = '',
    this.statusPengiriman = '',
    required this.jumlahAsesi,
    required this.asesor,
    this.sisaHari = 0,
    this.daysLate,
    this.catatan,
    this.totalAsesi = 0,
    this.jumlahKompeten = 0,
    this.jumlahBelumKompeten = 0,
    this.needsAcc = false,
    this.kuota,
    this.jenisAsesmen,
    this.jenisUji,
    this.isAjj,
  });

  bool get isDraft =>
      status == 'draft' || status == 'waiting' || statusJadwal == '0';
  bool get isRunning => status == 'running' || statusJadwal == '3';

  bool get isAJJ => isSjj;

  /// Asesmen Jarak Jauh (SJJ / AJJ)
  bool get isSjj {
    if (isAjj == true) return true;
    if (jenisUji?.trim() == '1' || jenisAsesmen?.trim() == '1') return true;
    if (jenisAsesmen != null) {
      final j = jenisAsesmen!.trim().toUpperCase();
      if (j == 'SJJ' || j == 'AJJ' || j == '1' || j.contains('ONLINE') || j.contains('DARING') || j.contains('JARAK JAUH')) {
        return true;
      }
    }
    if (jenisUji != null) {
      final j = jenisUji!.trim().toUpperCase();
      if (j == 'SJJ' || j == 'AJJ' || j == '1' || j.contains('ONLINE') || j.contains('DARING') || j.contains('JARAK JAUH')) {
        return true;
      }
    }
    final tukUpper = tuk.toUpperCase();
    final skemaUpper = skema.toUpperCase();
    return tukUpper.contains('SJJ') ||
        tukUpper.contains('AJJ') ||
        tukUpper.contains('ONLINE') ||
        tukUpper.contains('JARAK JAUH') ||
        skemaUpper.startsWith('SJJ') ||
        skemaUpper.startsWith('AJJ') ||
        skemaUpper.contains('SJJ') ||
        skemaUpper.contains('AJJ') ||
        skemaUpper.contains('JARAK JAUH');
  }

  /// Label tampilan: prioritaskan status_label BE
  String get displayStatusLabel {
    if (statusLabel.trim().isNotEmpty) return statusLabel.trim();
    switch (status) {
      case 'draft':
      case 'waiting':
        return 'Draft';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      case 'running':
        return 'Running';
      case 'pelaporan':
        return 'Pelaporan';
      default:
        return status;
    }
  }

  (Color, Color) get statusColors => statusColorsFor(status.isNotEmpty ? status : statusJadwal);

  /// Canonical color tuple: (textColor, backgroundColor)
  static (Color, Color) statusColorsFor(String status) {
    switch (status.toLowerCase().trim()) {
      case '0':
      case 'draft':
      case 'waiting':
      case 'menunggu':
        return (const Color(0xFFEA580C), const Color(0xFFFFEDD5));
      case '1':
      case 'completed':
      case 'selesai':
        return (const Color(0xFF10B981), const Color(0xFFECFDF5));
      case '2':
      case 'canceled':
      case 'dibatalkan':
        return (const Color(0xFFEF4444), const Color(0xFFFEE2E2));
      case '3':
      case 'running':
      case 'berlangsung':
        return (const Color(0xFF3F8CFF), const Color(0xFFF0F5FF));
      case '4':
      case 'pelaporan':
        return (const Color(0xFFD97706), const Color(0xFFFEF3C7));
      default:
        return (const Color(0xFFEA580C), const Color(0xFFFFEDD5));
    }
  }

  /// Canonical map: 0=Draft, 1=Completed, 2=Canceled, 3=Running, 4=Pelaporan
  static String mapStatusCode(String statusJadwal) {
    switch (statusJadwal.toLowerCase().trim()) {
      case '0':
      case 'draft':
      case 'waiting':
      case 'menunggu':
        return 'draft';
      case '1':
      case 'completed':
      case 'selesai':
        return 'completed';
      case '2':
      case 'canceled':
      case 'dibatalkan':
        return 'canceled';
      case '3':
      case 'running':
      case 'berlangsung':
        return 'running';
      case '4':
      case 'pelaporan':
        return 'pelaporan';
      default:
        return 'draft';
    }
  }

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    final statusJadwal = json['status_jadwal']?.toString() ?? '0';
    final daysOverdue = json['days_overdue'] ?? 0;
    final daysLate = json['days_late'];
    final statusLabel = (json['status_label'] ?? '').toString();

    final totalAsesi = json['total_asesi'] ?? json['jumlah_asesi'] ?? 0;
    final jumlahKompeten = json['jumlah_kompeten'] ?? 0;
    final jumlahBelumKompeten = json['jumlah_belum_kompeten'] ?? 0;
    final needsAcc = json['needs_acc'] == true || json['needs_acc'] == 1;

    final rawIsAjj = json['is_ajj'];
    final isAjj = rawIsAjj == true || rawIsAjj == 1 || rawIsAjj == '1' || rawIsAjj == 'true';

    final statusRekaman = json['status_rekaman']?.toString() ?? '';
    final statusBlanko = json['status_blanko']?.toString() ?? '';
    final statusPengiriman = json['status_pengiriman']?.toString() ?? '';
    final statusJadwalLabel = json['status_jadwal_label']?.toString() ?? (statusLabel.isNotEmpty ? statusLabel : mapStatusCode(statusJadwal));

    return JadwalItem(
      id: json['id'] ?? 0,
      skema: json['jadwal'] ?? json['nama_jadwal'] ?? '',
      tuk: json['tuk'] ?? '',
      tanggalMulai: json['tanggal'] ?? json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_akhir'] ?? json['tanggal_selesai'] ?? '',
      createdWhen: (json['created_when'] ?? '').toString(),
      status: mapStatusCode(statusJadwal),
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      statusJadwalLabel: statusJadwalLabel,
      statusRekaman: statusRekaman,
      statusBlanko: statusBlanko,
      statusPengiriman: statusPengiriman,
      jumlahAsesi: totalAsesi,
      asesor: _parseAsesor(json['asesor']),
      sisaHari: daysOverdue is int
          ? daysOverdue
          : int.tryParse('$daysOverdue') ?? 0,
      daysLate: daysLate == null
          ? null
          : (daysLate is int ? daysLate : int.tryParse('$daysLate')),
      catatan: json['catatan'],
      totalAsesi: totalAsesi is int
          ? totalAsesi
          : int.tryParse('$totalAsesi') ?? 0,
      jumlahKompeten: jumlahKompeten is int
          ? jumlahKompeten
          : int.tryParse('$jumlahKompeten') ?? 0,
      jumlahBelumKompeten: jumlahBelumKompeten is int
          ? jumlahBelumKompeten
          : int.tryParse('$jumlahBelumKompeten') ?? 0,
      needsAcc: needsAcc,
      kuota: json['kuota'] == null
          ? null
          : (json['kuota'] is int
                ? json['kuota']
                : int.tryParse('${json['kuota']}')),
      jenisAsesmen: json['jenis_asesmen']?.toString() ?? json['jenis_tuk']?.toString(),
      jenisUji: json['jenis_uji']?.toString(),
      isAjj: isAjj,
    );
  }
}

class JadwalStatistik {
  final int totalJadwal;
  final int draft;
  final int akanBerakhir;
  final int sedangBerjalan;
  final int selesai;
  final int pelaporan;
  final int terlambat;
  final int runningLewatTanggal;
  final String trendPercentage;
  const JadwalStatistik({
    required this.totalJadwal,
    this.draft = 0,
    required this.akanBerakhir,
    required this.sedangBerjalan,
    required this.selesai,
    this.pelaporan = 0,
    this.terlambat = 0,
    this.runningLewatTanggal = 0,
    this.trendPercentage = '+0%',
  });

  factory JadwalStatistik.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    int readInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return JadwalStatistik(
      totalJadwal: readInt(data['total_jadwal']),
      draft: readInt(data['draft']),
      akanBerakhir: readInt(data['akan_berakhir']),
      sedangBerjalan: readInt(data['sedang_berjalan']),
      selesai: readInt(data['selesai']),
      pelaporan: readInt(data['pelaporan']),
      terlambat: readInt(data['terlambat']),
      runningLewatTanggal: readInt(data['running_lewat_tanggal'] ?? data['running_overdue']),
      trendPercentage: _normalizeTrend(
        meta['trend_percentage']?.toString() ??
            data['trend_percentage']?.toString(),
      ),
    );
  }

  static String _normalizeTrend(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '+0%';
    final upper = v.toUpperCase();
    if (upper == 'N/A' || upper == 'NA' || upper == '-' || upper == 'NULL') {
      return '+0%';
    }
    return v;
  }

  factory JadwalStatistik.fallback() {
    return const JadwalStatistik(
      totalJadwal: 0,
      draft: 0,
      akanBerakhir: 0,
      sedangBerjalan: 0,
      selesai: 0,
      pelaporan: 0,
      terlambat: 0,
      trendPercentage: '+0%',
    );
  }
}

class UserRole {
  final String role; // 'admin', 'asesor', 'viewer'
  final String name;
  final String email;

  const UserRole({required this.role, required this.name, required this.email});

  static const admin = UserRole(role: 'admin', name: 'Admin', email: '');
  static const asesor = UserRole(role: 'asesor', name: 'Asesor', email: '');
  static const asesi = UserRole(role: 'asesi', name: 'Asesi', email: '');

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get canEditSchedule => isAdmin;
}

// ============================================================================
// Notification Models
// ============================================================================

class NotificationCount {
  final int count;

  const NotificationCount({required this.count});

  factory NotificationCount.fromJson(Map<String, dynamic> json) {
    return NotificationCount(count: JsonHelper.asInt(json['count']));
  }
}

class WaitingSchedule {
  final int id;
  final String jadwal;
  final String tanggal;
  final String? tanggalAkhir;
  final String statusJadwal;
  final String statusLabel;
  final String? idLsp;
  final int idTuk;
  final String tuk;
  final int jumlahAsesi;
  final List<String> asesor;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;

  const WaitingSchedule({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    this.tanggalAkhir,
    required this.statusJadwal,
    required this.statusLabel,
    this.idLsp,
    required this.idTuk,
    required this.tuk,
    required this.jumlahAsesi,
    required this.asesor,
    this.totalAsesi = 0,
    this.jumlahKompeten = 0,
    this.jumlahBelumKompeten = 0,
  });

  factory WaitingSchedule.fromJson(Map<String, dynamic> json) {
    final totalAsesi = json['total_asesi'] ?? json['jumlah_asesi'] ?? 0;
    final jumlahKompeten = json['jumlah_kompeten'] ?? 0;
    final jumlahBelumKompeten = json['jumlah_belum_kompeten'] ?? 0;

    return WaitingSchedule(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tanggalAkhir: json['tanggal_akhir'],
      statusJadwal: json['status_jadwal']?.toString() ?? '0',
      statusLabel: json['status_label'] ?? 'Draft/Baru',
      idLsp: json['id_lsp'],
      idTuk: json['id_tuk'] ?? 0,
      tuk: json['tuk'] ?? '',
      jumlahAsesi: totalAsesi,
      asesor: _parseAsesor(json['asesor']),
      totalAsesi: totalAsesi,
      jumlahKompeten: jumlahKompeten,
      jumlahBelumKompeten: jumlahBelumKompeten,
    );
  }

  JadwalItem toJadwalItem() {
    return JadwalItem(
      id: id,
      skema: jadwal,
      tuk: tuk,
      tanggalMulai: tanggal,
      tanggalSelesai: tanggalAkhir ?? tanggal,
      createdWhen: '',
      status: 'draft',
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      statusJadwalLabel: statusLabel,
      statusRekaman: '',
      statusBlanko: '',
      statusPengiriman: '',
      jumlahAsesi: jumlahAsesi,
      asesor: asesor,
      sisaHari: 0,
      totalAsesi: totalAsesi,
      jumlahKompeten: jumlahKompeten,
      jumlahBelumKompeten: jumlahBelumKompeten,
      needsAcc: false,
    );
  }
}

class WaitingScheduleResponse {
  final List<WaitingSchedule> data;
  final NotificationMeta meta;

  const WaitingScheduleResponse({required this.data, required this.meta});

  factory WaitingScheduleResponse.fromJson(Map<String, dynamic> json) {
    return WaitingScheduleResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => WaitingSchedule.fromJson(item))
              .toList() ??
          [],
      meta: NotificationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class NotificationMeta {
  final int totalWaiting;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const NotificationMeta({
    required this.totalWaiting,
    required this.limit,
    required this.sortBy,
    required this.sortOrder,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      totalWaiting: JsonHelper.asInt(json['total_waiting']),
      limit: JsonHelper.asInt(json['limit'], 20),
      sortBy: JsonHelper.asString(json['sort_by'], 'tanggal'),
      sortOrder: JsonHelper.asString(json['sort_order'], 'desc'),
    );
  }
}

// ============================================================================
// Asesi List Models
// ============================================================================

class AsesiItem {
  final int id;
  final String namaLengkap;
  final String? hasilRekomendasi; // 'K', 'BK', or '-'
  final String? rekomendasiAsesor; // '1', '2', '0'
  final String? waktuRekomendasi;
  final String? rekomendasiAsesorLabel;
  final String? noPeserta;
  final String? nik;
  final String? kota;
  final String? namaAsesor;

  // Verification indicators
  final bool isAPL01Valid;
  final String statusAPL01;
  final String colorAPL01;

  final bool isAPL02Valid;
  final String statusAPL02;
  final String colorAPL02;

  final bool isAK02Valid;
  final String statusAK02;
  final String colorAK02;
  // Asesor Assignment & Edit permission
  final int? idAsesor;
  final bool isMyAsesi;
  final bool canEdit;
  final bool canViewDetail;
  final bool isTidakHadir;

  const AsesiItem({
    required this.id,
    required this.namaLengkap,
    this.hasilRekomendasi,
    this.rekomendasiAsesor,
    this.rekomendasiAsesorLabel,
    this.noPeserta,
    this.nik,
    this.kota,
    this.namaAsesor,
    this.waktuRekomendasi,
    this.isAPL01Valid = false,
    this.statusAPL01 = 'Belum Lengkap',
    this.colorAPL01 = 'red',
    this.isAPL02Valid = false,
    this.statusAPL02 = 'Belum Lengkap',
    this.colorAPL02 = 'red',
    this.isAK02Valid = false,
    this.statusAK02 = 'Belum Dinilai',
    this.colorAK02 = 'red',
    this.idAsesor,
    this.isMyAsesi = true,
    this.canEdit = true,
    this.canViewDetail = true,
    this.isTidakHadir = false,
  });

  bool get isEditable => canEdit && isAPL01Valid && !isAbsent;
  bool get isAbsent => isTidakHadir || idAsesor == 99999 || idAsesor == 9999;

  factory AsesiItem.fromJson(Map<String, dynamic> json) {
    final rawKota =
        json['kota'] ??
        json['kabupaten'] ??
        json['nama_kabupaten'] ??
        json['kabupaten_kota'] ??
        json['tempat_lahir'] ??
        json['alamat'];
    final kotaStr = rawKota?.toString().trim();
    final asesorStr = json['nama_asesor']?.toString().trim();
    final waktuRekomendasiVal = json['waktu_rekomendasi']?.toString().trim();
    final rekomCode = json['rekomendasi_asesor']?.toString().trim() ?? '';
    final hasilRekom = json['hasil_rekomendasi']?.toString().trim() ??
        (rekomCode == '1' ? 'K' : (rekomCode == '2' ? 'BK' : '-'));

    final idAsesorVal = json['id_asesor'] is int
        ? json['id_asesor'] as int
        : int.tryParse(json['id_asesor']?.toString() ?? '');
    final isTidakHadirVal = json['is_tidak_hadir'] == true || idAsesorVal == 99999 || idAsesorVal == 9999;
    final isMyAsesiVal = !isTidakHadirVal && (json['is_my_asesi'] != false); // default true unless explicitly false
    final isAPL01ValidVal = json['is_apl01_valid'] == true;
    final isAPL02ValidVal = json['is_apl02_valid'] == true && isAPL01ValidVal;
    final isAK02ValidVal = (json['is_ak02_valid'] == true || rekomCode == '1' || rekomCode == '2') && isAPL01ValidVal && isAPL02ValidVal;
    final canEditVal = json['can_edit'] == true;
    final canViewDetailVal = json['can_view_detail'] != null
        ? json['can_view_detail'] == true
        : (!isTidakHadirVal && isMyAsesiVal);

    return AsesiItem(
      id: json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      hasilRekomendasi: hasilRekom.isNotEmpty ? hasilRekom : '-',
      rekomendasiAsesor: rekomCode.isNotEmpty ? rekomCode : null,
      rekomendasiAsesorLabel: json['rekomendasi_asesor_label'] ?? json['status_penilaian'],
      noPeserta: json['no_peserta']?.toString(),
      nik: json['nik']?.toString(),
      waktuRekomendasi: (waktuRekomendasiVal != null && waktuRekomendasiVal.isNotEmpty)
          ? waktuRekomendasiVal
          : null,
      kota: (kotaStr != null && kotaStr.isNotEmpty) ? kotaStr : null,
      namaAsesor: (asesorStr != null && asesorStr.isNotEmpty) ? asesorStr : null,
      isAPL01Valid: isAPL01ValidVal,
      statusAPL01: json['status_apl01']?.toString() ?? (isAPL01ValidVal ? 'Lengkap' : 'Belum Lengkap'),
      colorAPL01: json['color_apl01']?.toString() ?? (isAPL01ValidVal ? 'green' : 'red'),
      isAPL02Valid: isAPL02ValidVal,
      statusAPL02: isAPL02ValidVal ? (json['status_apl02']?.toString() ?? 'Lengkap') : 'Belum',
      colorAPL02: isAPL02ValidVal ? 'green' : 'red',
      isAK02Valid: isAK02ValidVal,
      statusAK02: isAK02ValidVal ? (json['status_ak02']?.toString() ?? 'Sudah Dinilai') : 'Belum Dinilai',
      colorAK02: isAK02ValidVal ? 'green' : 'red',
      idAsesor: idAsesorVal,
      isMyAsesi: isMyAsesiVal,
      canEdit: canEditVal,
      canViewDetail: canViewDetailVal,
      isTidakHadir: isTidakHadirVal,
    );
  }
}

class AsesiMeta {
  final int jadwalId;
  final String namaJadwal;
  final String tuk;
  final String tanggal;
  final String tanggalAkhir;
  final String waktuAsesmen;
  final String lokasiAsesmen;
  final String statusJadwal;
  final String statusLabel;
  final bool isSelesai;
  final int totalAsesi;
  final int jumlahKompeten;
  final int jumlahBelumKompeten;
  final int jumlahBelumDinilai;
  final int jumlahTidakHadir;

  const AsesiMeta({
    required this.jadwalId,
    this.namaJadwal = '',
    this.tuk = '',
    this.tanggal = '',
    this.tanggalAkhir = '',
    this.waktuAsesmen = '',
    this.lokasiAsesmen = '',
    this.statusJadwal = '',
    this.statusLabel = '',
    this.isSelesai = false,
    required this.totalAsesi,
    required this.jumlahKompeten,
    required this.jumlahBelumKompeten,
    required this.jumlahBelumDinilai,
    this.jumlahTidakHadir = 0,
  });

  factory AsesiMeta.fromJson(Map<String, dynamic> json) {
    final statusJadwal = json['status_jadwal']?.toString() ?? '';
    final statusLabel = json['status_label']?.toString() ?? '';
    final isSelesai = json['is_selesai'] == true ||
        statusJadwal == '1' ||
        statusJadwal.toLowerCase() == 'completed' ||
        statusLabel.toLowerCase() == 'selesai';

    return AsesiMeta(
      jadwalId: json['jadwal_id'] ?? 0,
      namaJadwal: json['nama_jadwal'] ?? json['jadwal'] ?? '',
      tuk: json['tuk'] ?? json['nama_tuk'] ?? '',
      tanggal: json['tanggal'] ?? json['tanggal_asesmen'] ?? '',
      tanggalAkhir: json['tanggal_akhir'] ?? '',
      waktuAsesmen: json['waktu_asesmen'] ?? '',
      lokasiAsesmen: json['lokasi_asesmen'] ?? '',
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      isSelesai: isSelesai,
      totalAsesi: json['total_asesi'] ?? 0,
      jumlahKompeten: json['jumlah_kompeten'] ?? 0,
      jumlahBelumKompeten: json['jumlah_belum_kompeten'] ?? 0,
      jumlahBelumDinilai: json['jumlah_belum_dinilai'] ?? 0,
      jumlahTidakHadir: json['jumlah_tidak_hadir'] ?? 0,
    );
  }
}

class AsesiListResponse {
  final String namaJadwal;
  final String tuk;
  final String tanggal;
  final String tanggalAkhir;
  final String waktuAsesmen;
  final String lokasiAsesmen;
  final String statusJadwal;
  final String statusLabel;
  final bool isSelesai;
  final List<AsesiItem> data;
  final AsesiMeta meta;

  const AsesiListResponse({
    this.namaJadwal = '',
    this.tuk = '',
    this.tanggal = '',
    this.tanggalAkhir = '',
    this.waktuAsesmen = '',
    this.lokasiAsesmen = '',
    this.statusJadwal = '',
    this.statusLabel = '',
    this.isSelesai = false,
    required this.data,
    required this.meta,
  });

  factory AsesiListResponse.fromJson(Map<String, dynamic> json) {
    final metaObj = AsesiMeta.fromJson(json['meta'] ?? {});
    final statusJadwal = json['status_jadwal']?.toString() ??
        json['jadwal_detail']?['status_jadwal']?.toString() ??
        json['jadwal_info']?['status_jadwal']?.toString() ??
        metaObj.statusJadwal;
    final statusLabel = json['status_label']?.toString() ??
        json['jadwal_detail']?['status_label']?.toString() ??
        json['jadwal_info']?['status_label']?.toString() ??
        metaObj.statusLabel;
    final isSelesai = json['is_selesai'] == true ||
        metaObj.isSelesai ||
        statusJadwal == '1' ||
        statusJadwal.toLowerCase() == 'completed' ||
        statusLabel.toLowerCase() == 'selesai' ||
        json['jadwal_detail']?['is_selesai'] == true ||
        json['jadwal_info']?['is_selesai'] == true;

    return AsesiListResponse(
      namaJadwal: json['nama_jadwal'] ?? json['jadwal'] ?? '',
      tuk: json['tuk'] ?? json['nama_tuk'] ?? '',
      tanggal: json['tanggal'] ?? json['tanggal_asesmen'] ?? '',
      tanggalAkhir: json['tanggal_akhir'] ?? '',
      waktuAsesmen: json['waktu_asesmen'] ?? '',
      lokasiAsesmen: json['lokasi_asesmen'] ?? '',
      statusJadwal: statusJadwal,
      statusLabel: statusLabel,
      isSelesai: isSelesai,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => AsesiItem.fromJson(item))
              .toList() ??
          [],
      meta: metaObj,
    );
  }
}

class JadwalAsesorDetailResponse {
  final JadwalAsesorDetailData data;
  final int totalAsesor;

  const JadwalAsesorDetailResponse({
    required this.data,
    required this.totalAsesor,
  });

  factory JadwalAsesorDetailResponse.fromJson(Map<String, dynamic> json) {
    return JadwalAsesorDetailResponse(
      data: JadwalAsesorDetailData.fromJson(json['data'] ?? {}),
      totalAsesor: json['meta']?['total_asesor'] ?? 0,
    );
  }
}

class MateriUjiItem {
  final int id;
  final String namaMapa;
  final String linkMukManual;
  final String penyusun;
  final String validator;
  final String statusMapa;

  const MateriUjiItem({
    required this.id,
    required this.namaMapa,
    required this.linkMukManual,
    this.penyusun = '',
    this.validator = '',
    this.statusMapa = '',
  });

  bool get hasDownloadLink => linkMukManual.trim().isNotEmpty;

  factory MateriUjiItem.fromJson(Map<String, dynamic> json) {
    return MateriUjiItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      namaMapa: json['nama_mapa']?.toString() ?? 'MUK / MAPA',
      linkMukManual: json['link_muk_manual']?.toString() ??
          json['link_mapa_manual']?.toString() ??
          '',
      penyusun: json['penyusun']?.toString() ?? '',
      validator: json['validator']?.toString() ?? '',
      statusMapa: json['status_mapa']?.toString() ?? '',
    );
  }
}

class JadwalAsesorDetailData {
  final int id;
  final String jadwal;
  final String tanggal;
  final String tanggalAkhir;
  final String statusJadwal;
  final String statusLabel;
  final int idTuk;
  final String tuk;
  final String alamatTuk;
  String get lokasiAsesmen => alamatTuk;
  String get tanggalAsesmen => tanggal;
  final String jenisTuk;
  final List<AsesorDetailItem> asesor;
  final List<AsesiItem> asesi;
  final List<MateriUjiItem> materiUji;
  final String? linkMukManual;
  final String? waktuAsesmen;
  final String? leadAsesor;
  final int? jumlahPeserta;
  final String? jenisUji;
  final bool? isAjj;
  final bool isAK01Valid;
  final bool isAK05Unlocked;
  final bool isAK06Unlocked;
  final String lockReasonAK05;
  final String lockReasonAK06;

  const JadwalAsesorDetailData({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.tanggalAkhir,
    required this.statusJadwal,
    required this.statusLabel,
    required this.idTuk,
    required this.tuk,
    required this.alamatTuk,
    required this.jenisTuk,
    required this.asesor,
    this.asesi = const [],
    this.materiUji = const [],
    this.linkMukManual,
    this.waktuAsesmen,
    this.leadAsesor,
    this.jumlahPeserta,
    this.jenisUji,
    this.isAjj,
    this.isAK01Valid = false,
    this.isAK05Unlocked = false,
    this.isAK06Unlocked = false,
    this.lockReasonAK05 = 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu sebelum mengisi Laporan Asesmen (FR-AK.05).',
    this.lockReasonAK06 = 'Selesaikan FR-AK.01 dan FR-AK.05 terlebih dahulu sebelum meninjau proses asesmen (FR-AK.06).',
  });
  bool get isAJJ => isSjj;
  bool get isSjj {
    if (isAjj == true) return true;
    if (jenisUji?.trim() == '1') return true;
    final j = jenisUji?.trim().toUpperCase();
    if (j == 'SJJ' || j == 'AJJ' || j == '1' || (j?.contains('ONLINE') ?? false) || (j?.contains('DARING') ?? false)) {
      return true;
    }
    final t = tuk.toUpperCase();
    final s = jadwal.toUpperCase();
    return t.contains('AJJ') || t.contains('ONLINE') || s.contains('AJJ') || s.contains('ONLINE');
  }

  factory JadwalAsesorDetailData.fromJson(Map<String, dynamic> json) {
    final String rawAlamat = json['alamat_tuk']?.toString() ??
        json['lokasi_asesmen']?.toString() ??
        json['alamat']?.toString() ??
        '';
    final String tukName = json['tuk']?.toString() ?? '';
    final String resolvedAlamat = rawAlamat.isNotEmpty ? rawAlamat : tukName;
    final rawIsAjj = json['is_ajj'];
    final isAjj = rawIsAjj == true || rawIsAjj == 1 || rawIsAjj == '1' || rawIsAjj == 'true';

    return JadwalAsesorDetailData(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? json['nama_jadwal'] ?? '',
      tanggal: json['tanggal'] ?? json['tanggal_asesmen'] ?? '',
      tanggalAkhir: json['tanggal_akhir'] ?? json['tanggal_asesmen'] ?? '',
      statusJadwal: json['status_jadwal']?.toString() ?? '',
      statusLabel: json['status_label'] ?? '',
      idTuk: json['id_tuk'] ?? 0,
      tuk: tukName,
      alamatTuk: resolvedAlamat,
      jenisTuk: json['jenis_tuk'] ?? '',
      waktuAsesmen: json['waktu_asesmen'],
      leadAsesor: json['lead_asesor'],
      jumlahPeserta: json['jumlah_peserta'],
      jenisUji: json['jenis_uji']?.toString(),
      isAjj: isAjj,
      isAK01Valid: json['is_ak01_valid'] == true,
      isAK05Unlocked: json['is_ak05_unlocked'] == true,
      isAK06Unlocked: json['is_ak06_unlocked'] == true,
      lockReasonAK05: json['lock_reason_ak05']?.toString() ?? 'Selesaikan dan setujui formulir FR-AK.01 terlebih dahulu sebelum mengisi Laporan Asesmen (FR-AK.05).',
      lockReasonAK06: json['lock_reason_ak06']?.toString() ?? 'Selesaikan FR-AK.01 dan FR-AK.05 terlebih dahulu sebelum meninjau proses asesmen (FR-AK.06).',
      asesor:
          (json['asesor'] as List<dynamic>?)
              ?.map(
                (item) =>
                    AsesorDetailItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      asesi:
          (json['asesi'] as List<dynamic>?)
              ?.map((item) => AsesiItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      materiUji:
          (json['materi_uji'] as List<dynamic>?)
              ?.map((item) => MateriUjiItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      linkMukManual: json['link_muk_manual']?.toString(),
    );
  }
}

class AsesorDetailItem {
  final int idAsesor;
  final String namaAsesor;
  final String noReg;
  final String email;
  final String hp;
  final String jenisAsesmen;
  final String statusSpt;
  final String isComplete;
  final String? sertifikatAsesor;
  final String? sertifikatTeknis;
  final String masaBerlaku;
  final String kabupatenKota;
  final String provinsiId;
  final String kabupatenId;
  final int totalAsesmen;

  const AsesorDetailItem({
    required this.idAsesor,
    required this.namaAsesor,
    this.noReg = '',
    this.email = '',
    this.hp = '',
    this.jenisAsesmen = '',
    this.statusSpt = '',
    this.isComplete = '',
    this.sertifikatAsesor,
    this.sertifikatTeknis,
    this.masaBerlaku = '',
    this.kabupatenKota = '',
    this.provinsiId = '',
    this.kabupatenId = '',
    this.totalAsesmen = 0,
  });

  factory AsesorDetailItem.fromJson(Map<String, dynamic> json) {
    return AsesorDetailItem(
      idAsesor: json['id_asesor'] ?? 0,
      namaAsesor: json['nama_asesor'] ?? '',
      noReg: json['no_reg'] ?? '',
      email: json['email'] ?? '',
      hp: json['hp'] ?? '',
      jenisAsesmen: json['jenis_asesmen']?.toString() ?? '',
      statusSpt: json['status_spt']?.toString() ?? '',
      isComplete: json['is_complete']?.toString() ?? '',
      sertifikatAsesor: json['sertifikat_asesor'],
      sertifikatTeknis: json['sertifikat_teknis'],
      masaBerlaku: json['masa_berlaku'] ?? '',
      kabupatenKota: json['kabupaten_kota'] ?? '',
      provinsiId: json['provinsi_id']?.toString() ?? '',
      kabupatenId: json['kabupaten_id']?.toString() ?? '',
      totalAsesmen: json['total_asesmen'] ?? 0,
    );
  }
}

class ParticipantDetailResponse {
  final String status;
  final String message;
  final ParticipantDetailData data;

  const ParticipantDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ParticipantDetailResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ParticipantDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class ParticipantDetailData {
  final int pesertaId;
  final String noPeserta;
  final String namaLengkap;
  final String nik;
  final String tempatLahir;
  final String tanggalLahir;
  final String skemaSertifikat;
  final String institusi;
  final String email;
  final String noTelepon;
  final StatusKelengkapan statusKelengkapan;
  final StatusAssessment statusAssessment;

  const ParticipantDetailData({
    required this.pesertaId,
    required this.noPeserta,
    required this.namaLengkap,
    required this.nik,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.skemaSertifikat,
    required this.institusi,
    required this.email,
    required this.noTelepon,
    required this.statusKelengkapan,
    required this.statusAssessment,
  });

  factory ParticipantDetailData.fromJson(Map<String, dynamic> json) {
    return ParticipantDetailData(
      pesertaId: json['peserta_id'] ?? 0,
      noPeserta: json['no_peserta'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      nik: json['nik'] ?? '',
      tempatLahir: json['tempat_lahir'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      skemaSertifikat: json['skema_sertifikat'] ?? '',
      institusi: json['institusi'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      statusKelengkapan: StatusKelengkapan.fromJson(
        json['status_kelengkapan'] ?? {},
      ),
      statusAssessment: StatusAssessment.fromJson(
        json['status_assessment'] ?? {},
      ),
    );
  }
}

class StatusKelengkapan {
  final String portofolio;
  final String dokumenPendukung;
  final String persyaratan;

  const StatusKelengkapan({
    required this.portofolio,
    required this.dokumenPendukung,
    required this.persyaratan,
  });

  factory StatusKelengkapan.fromJson(Map<String, dynamic> json) {
    return StatusKelengkapan(
      portofolio: json['portofolio'] ?? '',
      dokumenPendukung: json['dokumen_pendukung'] ?? '',
      persyaratan: json['persyaratan'] ?? '',
    );
  }
}

class StatusAssessment {
  final String kehadiran;
  final String tugasAsesmen;
  final String laporan;
  final String rekaman;

  const StatusAssessment({
    required this.kehadiran,
    required this.tugasAsesmen,
    required this.laporan,
    required this.rekaman,
  });

  factory StatusAssessment.fromJson(Map<String, dynamic> json) {
    return StatusAssessment(
      kehadiran: json['kehadiran'] ?? '',
      tugasAsesmen: json['tugas_asesmen'] ?? '',
      laporan: json['laporan'] ?? '',
      rekaman: json['rekaman'] ?? '',
    );
  }
}

/// Hasil pemindahan asesi ke asesor lain.
class TransferAsesiResult {
  final bool success;
  final String message;
  final int? targetAsesorId;
  final String? targetAsesorName;

  const TransferAsesiResult({
    required this.success,
    required this.message,
    this.targetAsesorId,
    this.targetAsesorName,
  });

  factory TransferAsesiResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final target = data is Map<String, dynamic> ? data['target_asesor'] : null;
    return TransferAsesiResult(
      success: json['status']?.toString() == 'success',
      message: json['message']?.toString() ?? 'Asesi berhasil dipindahkan',
      targetAsesorId: target is Map<String, dynamic>
          ? int.tryParse(target['id_asesor']?.toString() ?? '')
          : null,
      targetAsesorName: target is Map<String, dynamic>
          ? target['nama_asesor']?.toString()
          : null,
    );
  }

  factory TransferAsesiResult.failure(String message) =>
      TransferAsesiResult(success: false, message: message);
}
