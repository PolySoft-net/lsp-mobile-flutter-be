// ============================================================================
// Asesor Dashboard Cards
//
// Kartu & dialog statistik asesor. Diekstrak dari rangkuman_asesor.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../screens/jadwal/jadwal_detail_screen.dart';
import '../../models/dashboard_models.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../utils/date_format_helper.dart';

/// Header section (judul + "Lihat semua").
class AsesorSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapLihatSemua;

  const AsesorSectionHeader({
    super.key,
    required this.title,
    required this.onTapLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: onTapLihatSemua,
          borderRadius: BorderRadius.circular(4),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat semua',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2563EB),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu jadwal asesmen hari ini.
class AsesorJadwalHariIniCard extends StatelessWidget {
  final AsesorDashboardJadwal item;

  const AsesorJadwalHariIniCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBgColor) = JadwalItem.statusColorsFor(item.status);
    final statusLabel = item.statusLabel;
    final displayName = item.namaJadwal.isNotEmpty ? item.namaJadwal : item.skema;
    final formattedDate = DateFormatHelper.formatToIndonesian(item.tanggal);
    final hasTime = item.waktu.isNotEmpty && item.waktu != '0';
    final kuotaText = item.kuota > 0
        ? '${item.totalAsesi > 0 ? '${item.totalAsesi} / ' : ''}${item.kuota} Peserta'
        : (item.totalAsesi > 0 ? '${item.totalAsesi} Peserta' : '-');

    return InkWell(
      onTap: () {
        final user = AuthRepository.currentUserInstance;
        final userRole = UserRole(
          role: user?.role ?? 'asesor',
          name: user?.name ?? '',
          email: user?.email ?? '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JadwalDetailScreen(
              jadwal: item.toJadwalItem(),
              userRole: userRole,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title (Nama Jadwal) + Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.isAJJ
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFE2F0FD),
                    borderRadius: BorderRadius.circular(10),
                    border: item.isAJJ
                        ? Border.all(color: const Color(0xFFBFDBFE), width: 1.2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: const Color(0xFF3F8CFF),
                        size: item.isAJJ ? 20 : 24,
                      ),
                      if (item.isAJJ) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'AJJ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.isAJJ
                            ? 'Asesmen Jarak Jauh (AJJ)'
                            : 'Asesmen Mandiri / Luring',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Metadata: TUK, Tanggal Asesmen, Kuota
            // 1. TUK
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                const Text(
                  'TUK : ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.tuk.isNotEmpty ? item.tuk : '-',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 2. Tanggal Asesmen & Waktu
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Tanggal : ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    hasTime ? '$formattedDate (${item.waktu})' : formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 3. Kuota
            Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Kuota : ',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    kuotaText,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu tugas jadwal yang belum lengkap.
class AsesorJadwalBelumLengkapCard extends StatelessWidget {
  final AsesorDashboardTugas task;

  const AsesorJadwalBelumLengkapCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.assignment_outlined;
    Color iconColor = const Color(0xFF2563EB);
    Color iconBgColor = const Color(0xFFEFF6FF);
    String badgeText = task.title;
    Color badgeTextColor = const Color(0xFF2563EB);
    Color badgeBgColor = const Color(0xFFEFF6FF);

    switch (task.type) {
      case 'asesmen_berlangsung':
        final isLate = task.title.toLowerCase().startsWith('lewat');
        icon = Icons.play_circle_outline_rounded;
        iconColor = isLate ? const Color(0xFFDC2626) : const Color(0xFF2563EB);
        iconBgColor = isLate ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF);
        badgeText = task.title.isNotEmpty ? task.title : 'Asesmen berlangsung';
        badgeTextColor = isLate ? const Color(0xFFDC2626) : const Color(0xFF2563EB);
        badgeBgColor = isLate ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF);
        break;
      case 'menunggu_verifikasi':
        icon = Icons.hourglass_top_rounded;
        iconColor = const Color(0xFFD97706);
        iconBgColor = const Color(0xFFFEF3C7);
        badgeText =
            task.title.isNotEmpty ? task.title : 'Laporan menunggu verifikasi';
        badgeTextColor = const Color(0xFFB45309);
        badgeBgColor = const Color(0xFFFEF3C7);
        break;
      case 'penugasan_baru':
        icon = Icons.assignment_outlined;
        iconColor = const Color(0xFF3FA8F8);
        iconBgColor = const Color(0xFFE8F5FF);
        badgeText = task.title.isNotEmpty ? task.title : 'Penugasan Baru';
        badgeTextColor = const Color(0xFF0284C7);
        badgeBgColor = const Color(0xFFE0F2FE);
        break;
      case 'asesmen_selesai':
        icon = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFFECFDF5);
        badgeText = task.title.isNotEmpty ? task.title : 'Asesmen Selesai';
        badgeTextColor = const Color(0xFF059669);
        badgeBgColor = const Color(0xFFD1FAE5);
        break;
      default:
        badgeText = task.title.isNotEmpty ? task.title : 'Jadwal Asesmen';
        break;
    }

    final displayText = task.subtitle.isNotEmpty ? task.subtitle : task.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final user = AuthRepository.currentUserInstance;
          final userRole = UserRole(
            role: user?.role ?? 'asesor',
            name: user?.name ?? '',
            email: user?.email ?? '',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JadwalDetailScreen(
                jadwal: task.toJadwalItem(),
                userRole: userRole,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (task.isAJJ) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'AJJ',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayText,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu kategori statistik (SPT / MUK / Mitra).
class AsesorCategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const AsesorCategoryCard({
    super.key,
    required this.title,
    required this.count,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Box & Arrow indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Texts
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      count,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu header "Dashboard Asesor" (gradien biru) + banner kompetensi + stats.
class AsesorDashboardHeaderCard extends StatelessWidget {
  final String formattedExp;
  final bool isKompeten;
  final int totalSpt;
  final AsesorDashboardData? data;
  final VoidCallback onTapSpt;
  final VoidCallback onTapMuk;
  final VoidCallback onTapMitra;

  const AsesorDashboardHeaderCard({
    super.key,
    required this.formattedExp,
    required this.isKompeten,
    required this.totalSpt,
    required this.data,
    required this.onTapSpt,
    required this.onTapMuk,
    required this.onTapMitra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF559AD4), Color(0xFF2C6C9C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000), // black with 0.15 opacity
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title
          const Text(
            'Dashboard Asesor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Deskripsi Pemeliharaan Kompetensi / RCC Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isKompeten
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isKompeten
                    ? const Color(0xFF34D399).withValues(alpha: 0.8)
                    : const Color(0xFFFBBF24).withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isKompeten
                      ? Icons.verified_rounded
                      : Icons.info_outline_rounded,
                  color: isKompeten
                      ? const Color(0xFF6EE7B7)
                      : const Color(0xFFFDE68A),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKompeten
                            ? 'Asesor Telah Memelihara Kompetensi'
                            : 'Minimal 6 SPT untuk proses Perpanjangan Sertifikat Asesor / RCC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isKompeten
                            ? 'Telah menyelesaikan $totalSpt SPT dalam 3 tahun (memenuhi syarat perpanjangan sertifikat asesor)'
                            : 'Saat ini tercatat $totalSpt SPT. Selesaikan minimal 6 penugasan asesmen dalam 3 tahun masa berlaku',
                        style: const TextStyle(
                          color: Color(0xE0FFFFFF),
                          fontSize: 11,
                        ),
                      ),
                      if (formattedExp.isNotEmpty && formattedExp != '-') ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: Color(0xFF6EE7B7),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Masa Aktif: $formattedExp',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Alert banner inside card
          if (data?.alertBanner.hasAlert == true) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD97706),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFFBBF24),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data!.alertBanner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data!.alertBanner.subtitle,
                          style: const TextStyle(
                            color: Color(0xE0FFFFFF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Row of 3 Stat Cards (Jumlah SPT 2026, Jumlah MUK 2026, Jumlah Mitra)
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: AsesorCategoryCard(
                    title: 'Jumlah SPT 2026',
                    count: (data?.summary.jumlahSpt2026 ?? 0).toString(),
                    unit: 'SPT',
                    icon: Icons.assignment_turned_in_rounded,
                    iconColor: const Color(0xFF3F8CFF),
                    iconBgColor: const Color(0xFFEFF6FF),
                    onTap: onTapSpt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AsesorCategoryCard(
                    title: 'Jumlah MUK 2026',
                    count: (data?.summary.jumlahMuk2026 ?? 0).toString(),
                    unit: 'Perangkat',
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBgColor: const Color(0xFFFEF3C7),
                    onTap: onTapMuk,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AsesorCategoryCard(
                    title: 'Jumlah Mitra',
                    count: (data?.summary.jumlahMitra ?? 0).toString(),
                    unit: 'Mitra',
                    icon: Icons.handshake_rounded,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    onTap: onTapMitra,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet detail statistik (SPT / MUK / Mitra).
void showAsesorStatDetailDialog({
  required BuildContext context,
  required String title,
  required int count,
  required String unit,
  required String description,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count $unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F8CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}
