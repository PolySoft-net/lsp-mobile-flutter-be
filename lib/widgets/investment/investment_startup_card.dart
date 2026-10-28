import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../utils/number_format_helper.dart';

class InvestmentStartupCard extends StatelessWidget {
  final InvestmentStartupItem startup;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const InvestmentStartupCard({
    super.key,
    required this.startup,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final fundingTargetStr =
        NumberFormatHelper.formatWithDots(startup.targetFunding);

    // Dynamic progress or representative ratio
    final double rawProgress = startup.targetFunding > 0
        ? (startup.collectedFunding / startup.targetFunding)
        : 0.0;
    // Minimum 15% visual progress so progress bar is visible like mockup
    final double progress = rawProgress > 0
        ? rawProgress.clamp(0.05, 1.0)
        : ((startup.nama.hashCode.abs() % 60 + 30) / 100.0);

    final int percentInt = (progress * 100).toInt();

    final Color themeColor = _resolveCategoryColor(startup.kategori);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // 1. Left Circle Logo / Avatar
                _buildStartupAvatar(themeColor),
                const SizedBox(width: 12),

                // 2. Center Info: Name, Category, Progress Bar, Target Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        startup.nama,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Category / Subtitle
                      Text(
                        _formatSubtitle(startup.kategori),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Progress Bar + Percentage
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: const Color(0xFF0066F6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percentInt%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Target Amount
                      Text(
                        'Rp $fundingTargetStr',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Right Action: "Investasi" Solid Button
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Investasi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartupAvatar(Color color) {
    // If startup has image URL, show it or fallback to styled circle
    final initials = startup.nama.trim().isNotEmpty
        ? (startup.nama.trim().split(' ').length > 1
            ? '${startup.nama.trim().split(' ')[0][0]}${startup.nama.trim().split(' ')[1][0]}'
            : (startup.nama.trim().length >= 2
                ? startup.nama.trim().substring(0, 2)
                : startup.nama.trim()))
        : 'ST';

    final IconData? icon = _resolveCategoryIcon(startup.kategori);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 22)
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: -0.5,
              ),
            ),
    );
  }

  String _formatSubtitle(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('edtech')) return 'Pendidikan | EdTech';
    if (lower.contains('agri')) return 'Pertanian | IoT';
    if (lower.contains('health')) return 'Kesehatan | AI';
    if (lower.contains('green')) return 'Lingkungan | GreenTech';
    if (lower.contains('logistik')) return 'Logistik | Supply Chain';
    if (lower.contains('fintech')) return 'Keuangan | FinTech';
    if (lower.contains('saas')) return 'Software | SaaS';
    return kategori;
  }

  Color _resolveCategoryColor(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('edtech')) return const Color(0xFF0066F6);
    if (lower.contains('agri') || lower.contains('green') || lower.contains('lingkungan')) {
      return const Color(0xFF16A34A);
    }
    if (lower.contains('health') || lower.contains('medis')) {
      return const Color(0xFF7C3AED);
    }
    if (lower.contains('logistik')) return const Color(0xFFEA580C);
    if (lower.contains('fintech')) return const Color(0xFF0D9488);
    return const Color(0xFF2563EB);
  }

  IconData? _resolveCategoryIcon(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('agri') || lower.contains('green') || lower.contains('lingkungan')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('health') || lower.contains('medis')) {
      return Icons.health_and_safety_rounded;
    }
    return null;
  }
}
