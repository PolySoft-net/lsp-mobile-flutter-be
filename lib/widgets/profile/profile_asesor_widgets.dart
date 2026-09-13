// ============================================================================
// Profile Asesor Widgets
//
// Kartu ringkasan, honor, dan menu profil. Diekstrak dari
// profile_asesor_screen.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import '../../utils/date_format_helper.dart';

/// Kartu ringkasan kecil (nilai + label + sublabel).
class ProfileRingkasanCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const ProfileRingkasanCard({
    super.key,
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Sublabel
          Text(
            sublabel,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Row 3 kartu ringkasan (Penugasan / Laporan / Terkonfirmasi).
class ProfileRingkasanCards extends StatelessWidget {
  final int totalPenugasan;
  final int totalLaporan;
  final int totalLaporanSukses;

  const ProfileRingkasanCards({
    super.key,
    required this.totalPenugasan,
    required this.totalLaporan,
    required this.totalLaporanSukses,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProfileRingkasanCard(
            value: totalPenugasan.toString(),
            label: 'Penugasan',
            sublabel: 'Yang diterima',
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFFF97316),
            iconBgColor: const Color(0xFFFFF3E0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ProfileRingkasanCard(
            value: totalLaporan.toString(),
            label: 'Laporan',
            sublabel: 'Terkirim ke LSP',
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF378CE7),
            iconBgColor: const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ProfileRingkasanCard(
            value: totalLaporanSukses.toString(),
            label: 'Laporan',
            sublabel: 'Terkonfirmasi',
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF4CAF50),
            iconBgColor: const Color(0xFFE8F5E9),
          ),
        ),
      ],
    );
  }
}

/// Kartu honor bulan ini.
class ProfileHonorCard extends StatelessWidget {
  final Map<String, dynamic>? honorData;
  final VoidCallback onTapLihatSemua;

  const ProfileHonorCard({
    super.key,
    required this.honorData,
    required this.onTapLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Honor Bulan Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: onTapLihatSemua,
              child: const Row(
                children: [
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF378CE7),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF378CE7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Honor (${honorData?["periode"] ?? DateFormatHelper.formatCurrentMonthPeriod()})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    honorData?['total_honor'] ?? 'Rp. 0',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    honorData?['jumlah_asesmen_selesai'] ?? '0 Asesmen selesai',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF378CE7),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu menu profil (Data Diri, Honor, Keamanan, dst).
class ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final Color textColor;

  const ProfileMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.textColor = const Color(0xFF1E293B),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF378CE7),
            size: 22,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet pilihan ubah foto profil (Galeri / Kamera).
void showProfilePhotoPicker({
  required BuildContext context,
  required VoidCallback onPickPhoto,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF378CE7),
                  ),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  onPickPhoto();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF378CE7),
                  ),
                ),
                title: const Text('Ambil Foto / Pilih Berkas'),
                onTap: () {
                  Navigator.pop(context);
                  onPickPhoto();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
