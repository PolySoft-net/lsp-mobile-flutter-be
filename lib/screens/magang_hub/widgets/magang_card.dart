import 'package:material_ui/material_ui.dart';

import '../../../models/career_expo_models.dart';
import '../../../utils/number_format_helper.dart';

/// Kartu lowongan magang dengan desain khas Magang Hub (warna aksen ungu #7C3AED).
class MagangJobCard extends StatelessWidget {
  final CareerJobItem job;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showManageActions;

  const MagangJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showManageActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSalary = job.salaryMin > 0 || job.salaryMax > 0;
    final salaryText = hasSalary
        ? (job.salaryMin > 0 && job.salaryMax > 0
            ? 'Rp ${NumberFormatHelper.formatWithDots(job.salaryMin)} - ${NumberFormatHelper.formatWithDots(job.salaryMax)} / bln'
            : (job.salaryMin > 0
                ? 'Rp ${NumberFormatHelper.formatWithDots(job.salaryMin)} / bln'
                : 'Rp ${NumberFormatHelper.formatWithDots(job.salaryMax)} / bln'))
        : 'Uang saku kompetitif';

    final isDraft = job.statusLowongan.toLowerCase() == 'draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Company Logo + Title + Status/Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: job.logoBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        job.logoText.isNotEmpty
                            ? job.logoText
                            : (job.companyName.isNotEmpty
                                ? job.companyName.substring(0, 1).toUpperCase()
                                : 'M'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.companyName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isDraft)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Draft',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Magang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips Row: Workplace Type, Location, Education
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTagChip(
                      icon: Icons.business_outlined,
                      text: job.workplaceType.isNotEmpty ? job.workplaceType : 'On Site',
                      bg: const Color(0xFFF8FAFC),
                      fg: const Color(0xFF475569),
                    ),
                    if (job.location.isNotEmpty)
                      _buildTagChip(
                        icon: Icons.location_on_outlined,
                        text: job.location,
                        bg: const Color(0xFFF8FAFC),
                        fg: const Color(0xFF475569),
                      ),
                    if (job.education.isNotEmpty)
                      _buildTagChip(
                        icon: Icons.school_outlined,
                        text: job.education,
                        bg: const Color(0xFFF8FAFC),
                        fg: const Color(0xFF475569),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                // Bottom Row: Salary + Actions or Posted At
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              salaryText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7C3AED),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showManageActions)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onEdit,
                              tooltip: 'Edit',
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 14),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onDelete,
                              tooltip: 'Hapus',
                            ),
                          ],
                        ],
                      )
                    else if (job.postedAt.isNotEmpty)
                      Text(
                        job.postedAt,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
