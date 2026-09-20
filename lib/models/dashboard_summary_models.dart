// ============================================================================
// Dashboard Summary Models
// ============================================================================

class DashboardSummary {
  final int totalAsesmen;
  final int totalPemegangSertifikat;
  final int totalAsesor;
  final int totalTuk;
  final String trendAsesmen;
  final String trendPemegangSertifikat;
  final String trendAsesor;
  final String trendTuk;
  final bool isCurrentMonth;
  final String? note;
  
  // New fields - format "bulan_lalu > bulan_ini"
  final String jadwalAsesmen;
  final String sertifikatPerSkema;
  final String sebaranAsesor;
  final String tempatUjiKompetensi;

  // Real API fields for Admin summary grid 2x2
  final int totalAsesi;
  final int jadwalBelumTerkonfirmasi;
  final int suratTugasMenungguPengiriman;
  final int pendaftaranAsesiBaru;
  final int honorAsesorBelumDibayar;
  final int pengajuanBlankoBelumSelesai;
  final int pengajuanBlankoPending;
  final int totalJadwal;

  const DashboardSummary({
    required this.totalAsesmen,
    required this.totalPemegangSertifikat,
    required this.totalAsesor,
    required this.totalTuk,
    this.totalAsesi = 0,
    this.jadwalBelumTerkonfirmasi = 0,
    this.suratTugasMenungguPengiriman = 0,
    this.pendaftaranAsesiBaru = 0,
    this.honorAsesorBelumDibayar = 0,
    this.pengajuanBlankoBelumSelesai = 0,
    this.pengajuanBlankoPending = 0,
    this.totalJadwal = 0,
    this.trendAsesmen = '+0%',
    this.trendPemegangSertifikat = '+0%',
    this.trendAsesor = '+0%',
    this.trendTuk = '+0%',
    this.isCurrentMonth = false,
    this.note,
    this.jadwalAsesmen = '0 > 0',
    this.sertifikatPerSkema = '0 > 0',
    this.sebaranAsesor = '0 > 0',
    this.tempatUjiKompetensi = '0 > 0',
  });

  /// Empty shell when API fails — zeros only, never demo numbers.
  factory DashboardSummary.fallback() {
    return const DashboardSummary(
      totalAsesmen: 0,
      totalPemegangSertifikat: 0,
      totalAsesor: 0,
      totalTuk: 0,
      totalJadwal: 0,
      jadwalBelumTerkonfirmasi: 0,
      suratTugasMenungguPengiriman: 0,
      pendaftaranAsesiBaru: 0,
      honorAsesorBelumDibayar: 0,
      pengajuanBlankoBelumSelesai: 0,
      pengajuanBlankoPending: 0,
      trendAsesmen: '+0%',
      trendPemegangSertifikat: '+0%',
      trendAsesor: '+0%',
      trendTuk: '+0%',
      isCurrentMonth: false,
      jadwalAsesmen: '0 > 0',
      sertifikatPerSkema: '0 > 0',
      sebaranAsesor: '0 > 0',
      tempatUjiKompetensi: '0 > 0',
    );
  }
}

// ============= MASA TENGGANG SERTIFIKAT =============

class MasaTenggangSertifikatSkemaItem {
  final int skemaId;
  final String namaSkema;
  final int jumlahAsesi;

  const MasaTenggangSertifikatSkemaItem({
    required this.skemaId,
    required this.namaSkema,
    required this.jumlahAsesi,
  });

  factory MasaTenggangSertifikatSkemaItem.fromJson(Map<String, dynamic> json) {
    return MasaTenggangSertifikatSkemaItem(
      skemaId: json['skema_id'] ?? 0,
      namaSkema: json['nama_skema']?.toString() ?? '',
      jumlahAsesi: json['jumlah_asesi'] ?? 0,
    );
  }
}

class MasaTenggangSertifikatBulanItem {
  final String bulan;
  final String tahunBulan;
  final int totalExpired;
  final List<MasaTenggangSertifikatSkemaItem> skemaDetail;

  const MasaTenggangSertifikatBulanItem({
    required this.bulan,
    required this.tahunBulan,
    required this.totalExpired,
    required this.skemaDetail,
  });

  factory MasaTenggangSertifikatBulanItem.fromJson(Map<String, dynamic> json) {
    final List skemaList = json['skema_detail'] ?? [];
    return MasaTenggangSertifikatBulanItem(
      bulan: json['bulan']?.toString() ?? '',
      tahunBulan: json['tahun_bulan']?.toString() ?? '',
      totalExpired: json['total_expired'] ?? 0,
      skemaDetail: skemaList.map((e) => MasaTenggangSertifikatSkemaItem.fromJson(e)).toList(),
    );
  }
}

class MasaTenggangSertifikatData {
  final List<MasaTenggangSertifikatBulanItem> data;
  final int totalSertifikatAkanExpired;
  final String periodeAwal;
  final String periodeAkhir;

  const MasaTenggangSertifikatData({
    required this.data,
    required this.totalSertifikatAkanExpired,
    required this.periodeAwal,
    required this.periodeAkhir,
  });

  factory MasaTenggangSertifikatData.fromJson(Map<String, dynamic> json) {
    final List dataList = json['data'] ?? [];
    final meta = json['meta'] ?? {};
    return MasaTenggangSertifikatData(
      data: dataList.map((e) => MasaTenggangSertifikatBulanItem.fromJson(e)).toList(),
      totalSertifikatAkanExpired: meta['total_sertifikat_akan_expired'] ?? 0,
      periodeAwal: meta['periode_awal']?.toString() ?? '',
      periodeAkhir: meta['periode_akhir']?.toString() ?? '',
    );
  }

  // Helper method to parse "bulan_lalu > bulan_ini" format
  static Map<String, int> parseComparison(String value) {
    final parts = value.split('>');
    if (parts.length == 2) {
      return {
        'previous': int.tryParse(parts[0].trim()) ?? 0,
        'current': int.tryParse(parts[1].trim()) ?? 0,
      };
    }
    return {'previous': 0, 'current': 0};
  }
}

class MonthlyAssessment {
  final String label;
  final int total;
  final double heightPercentage;
  final int? kompeten;
  final int? belumKompeten;
  final bool isCurrentMonth;

  const MonthlyAssessment({
    required this.label,
    required this.total,
    required this.heightPercentage,
    this.kompeten,
    this.belumKompeten,
    this.isCurrentMonth = false,
  });
}

class JadwalOverdue {
  final int id;
  final String jadwal;
  final String tanggal;
  final String tuk;
  final int daysOverdue;
  final String statusLabel;

  const JadwalOverdue({
    required this.id,
    required this.jadwal,
    required this.tanggal,
    required this.tuk,
    required this.daysOverdue,
    required this.statusLabel,
  });

  factory JadwalOverdue.fromJson(Map<String, dynamic> json) {
    return JadwalOverdue(
      id: json['id'] ?? 0,
      jadwal: json['jadwal'] ?? 'Jadwal Asesmen',
      tanggal: json['tanggal'] ?? '',
      tuk: json['tuk'] ?? 'TUK Pusat',
      daysOverdue: json['days_overdue'] ?? 0,
      statusLabel: json['status_label'] ?? 'Terjadwal',
    );
  }
}

class AsesorStats {
  final int totalAsesor;
  final int asesorAktif;
  final int asesorInternal;
  final int asesorExternal;
  final int totalTuk;
  final int onlineAsesmen;
  final int offlineAsesmen;
  final int wilayahTercover;
  final String trendTotalAsesor;

  const AsesorStats({
    required this.totalAsesor,
    required this.asesorAktif,
    required this.asesorInternal,
    required this.asesorExternal,
    required this.totalTuk,
    required this.onlineAsesmen,
    required this.offlineAsesmen,
    required this.wilayahTercover,
    this.trendTotalAsesor = '+15,7%',
  });

  factory AsesorStats.fallback() {
    return const AsesorStats(
      totalAsesor: 0,
      asesorAktif: 0,
      asesorInternal: 0,
      asesorExternal: 0,
      totalTuk: 0,
      onlineAsesmen: 0,
      offlineAsesmen: 0,
      wilayahTercover: 0,
      trendTotalAsesor: '+0%',
    );
  }
}

class TopProvinsi {
  final String name;
  final int value;
  final String percentage;

  const TopProvinsi({
    required this.name,
    required this.value,
    required this.percentage,
  });
}


class TUKKabupaten {
  final String kabupaten;
  final int jumlah;
  final List<String> detail;

  const TUKKabupaten({
    required this.kabupaten,
    required this.jumlah,
    this.detail = const [],
  });
}
