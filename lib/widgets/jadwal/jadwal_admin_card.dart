// ============================================================================
// Kartu jadwal untuk role Admin.
//
// Diekstrak dari jadwal_role_cards.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/jadwal_models.dart';
import 'jadwal_format_helpers.dart';

/// Kartu jadwal untuk role Admin.
class JadwalAdminCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;
  final bool showCreatedDate;

  const JadwalAdminCard({
    super.key,
    required this.item,
    required this.onTap,
    this.showCreatedDate = false,
  });

  String get _displayAsesi {
    final kuota = item.kuota ?? 0;
    return 'Kuota: $kuota';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.isSjj
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.file_text,
                      color: item.isSjj
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF2C6C9C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.map_pin,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.tuk,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.isSjj) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                                ),
                                child: const Text(
                                  'SJJ',
                                  style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              jadwalFormatDateRange(item.tanggalMulai, item.tanggalSelesai),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        // Tanggal dibuat (created_when) - hanya tampil di tab Draft admin
                        if (showCreatedDate) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tanggal dibuat: ${jadwalFormatIndonesianDateOnly(item.createdWhen)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Jumlah Asesi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.users,
                                    size: 12,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _displayAsesi,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Asesor dikosongkan (admin) — Jumlah Asesi tetap
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (jadwalShouldShowWarning(item))
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.circle_exclamation_point,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Terlambat',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: jadwalStatusColor(item).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.displayStatusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: jadwalStatusColor(item),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (jadwalShouldShowWarning(item))
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                LucideIcons.clock,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          Text(
                            jadwalStatusText(item),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: jadwalShouldShowWarning(item)
                                  ? const Color(0xFFFF6B6B)
                                  : jadwalStatusColor(item),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom action — hide for completed / canceled / pelaporan
            if (item.status != 'completed' &&
                item.status != 'canceled' &&
                item.status != 'pelaporan')
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: 16,
                            color: const Color(0xFF5B9FD8),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B9FD8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
