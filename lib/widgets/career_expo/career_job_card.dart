import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../utils/number_format_helper.dart';

/// Kartu lowongan pekerjaan Career Expo sesuai desain UI
class CareerJobCard extends StatelessWidget {
  final CareerJobItem job;
  final VoidCallback onTap;
  final ValueChanged<bool>? onBookmarkToggle;
  final bool isHorizontalCompact;

  const CareerJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onBookmarkToggle,
    this.isHorizontalCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final salaryText =
        'Rp ${NumberFormatHelper.formatWithDots(job.salaryMin)} - ${NumberFormatHelper.formatWithDots(job.salaryMax)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isHorizontalCompact ? 280 : double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Avatar, Company Name, Job Title, Bookmark Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: job.logoBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: job.logoBgColor.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      job.logoText.isNotEmpty ? job.logoText : job.companyName.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.companyName,
                          style: const TextStyle(
                            fontSize: 13,
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
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Bookmark button
                  IconButton(
                    onPressed: () => onBookmarkToggle?.call(!job.isBookmarked),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      job.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: job.isBookmarked ? const Color(0xFF0066F6) : const Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags Row (Full Time, Remote)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTagBadge(job.employmentType),
                  _buildTagBadge(job.workplaceType),
                ],
              ),
              const SizedBox(height: 12),
              // Location row
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job.location,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Salary row & posted time
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Color(0xFF0066F6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      salaryText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066F6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.postedAt.isNotEmpty && !isHorizontalCompact) ...[
                    const SizedBox(width: 8),
                    Text(
                      job.postedAt,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
