import 'package:material_ui/material_ui.dart';

import '../../../models/career_expo_models.dart';
import '../../../utils/number_format_helper.dart';
import '../../../widgets/common/company_logo.dart';

/// Kartu lowongan magang — prioritas: judul, perusahaan, lokasi, gaji, status.
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
    final workplace =
        job.workplaceType.isNotEmpty ? job.workplaceType : 'On Site';
    final meta = job.location.isNotEmpty
        ? '$workplace · ${job.location}'
        : workplace;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDraft) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Draft',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CompanyLogo(
                      imageUrl: job.companyLogo,
                      size: 20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        salaryText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (job.postedAt.isNotEmpty)
                      Text(
                        job.postedAt,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
                if (showManageActions) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onEdit != null)
                        _ManageButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: const Color(0xFF2563EB),
                          onPressed: onEdit!,
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 8),
                      if (onDelete != null)
                        _ManageButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Hapus',
                          color: const Color(0xFFDC2626),
                          onPressed: onDelete!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol aksi kartu dengan area sentuh minimum 48px (Material tap target).
class _ManageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ManageButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
