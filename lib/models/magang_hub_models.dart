import 'package:material_ui/material_ui.dart';

export 'career_expo_models.dart' show CareerJobItem;
/// Model untuk profil perusahaan mitra di Magang Hub.
class MagangPerusahaanItem {
  final String namaPerusahaan;
  final String kategoriPerusahaan;
  final String tentangPerusahaan;
  final String lokasi;
  final String logoText;
  final Color logoColor;
  final int totalLowongan;

  const MagangPerusahaanItem({
    required this.namaPerusahaan,
    required this.kategoriPerusahaan,
    required this.tentangPerusahaan,
    required this.lokasi,
    required this.logoText,
    required this.logoColor,
    required this.totalLowongan,
  });

  factory MagangPerusahaanItem.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF7C3AED);
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return const Color(0xFF7C3AED);
    }

    return MagangPerusahaanItem(
      namaPerusahaan: json['nama_perusahaan']?.toString() ?? '',
      kategoriPerusahaan: json['kategori_perusahaan']?.toString() ?? '',
      tentangPerusahaan: json['tentang_perusahaan']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      logoText: json['logo_text']?.toString() ?? '',
      logoColor: parseColor(json['logo_color']?.toString()),
      totalLowongan: json['total_lowongan_magang'] is int
          ? json['total_lowongan_magang'] as int
          : int.tryParse(json['total_lowongan_magang']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Model statistik ringkasan di dashboard Magang Hub.
class MagangStats {
  final int totalLowonganMagang;
  final int totalPerusahaan;
  final int totalKota;

  const MagangStats({
    this.totalLowonganMagang = 0,
    this.totalPerusahaan = 0,
    this.totalKota = 0,
  });

  factory MagangStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return MagangStats(
      totalLowonganMagang: toInt(json['total_lowongan_magang']),
      totalPerusahaan: toInt(json['total_perusahaan']),
      totalKota: toInt(json['total_kota']),
    );
  }
}
