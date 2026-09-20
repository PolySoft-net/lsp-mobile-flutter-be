import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../utils/number_format_helper.dart';
import '../../screens/jadwal/pelaporan_screen.dart';

class RangkumanUtama extends StatefulWidget {
  final DashboardSummary? data;
  final bool? isLoading;
  final VoidCallback? onNavigateToJadwal;

  const RangkumanUtama({
    super.key,
    this.data,
    this.isLoading,
    this.onNavigateToJadwal,
  });

  @override
  State<RangkumanUtama> createState() => _RangkumanUtamaState();
}

class _RangkumanUtamaState extends State<RangkumanUtama> {
  late Future<DashboardSummary>? _summaryFuture;

  String get _currentDayMonth {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika data tidak disediakan dari parent
    if (widget.data == null) {
      _summaryFuture = ApiService.getSummary();
    } else {
      _summaryFuture = null;
    }
  }

  @override
  void didUpdateWidget(RangkumanUtama oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update ketika data dari parent berubah
    if (widget.data != oldWidget.data) {
      setState(() {
        _summaryFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari parent jika ada
    if (widget.data != null) {
      return _buildContent(widget.data!, widget.isLoading ?? false);
    }

    // Fallback: Gunakan FutureBuilder jika standalone
    return FutureBuilder<DashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? DashboardSummary.fallback();
        return _buildContent(data, isLoading);
      },
    );
  }

  Widget _buildContent(DashboardSummary data, bool isLoading) {
    final asesiValue = isLoading
        ? '...'
        : NumberFormatHelper.formatWithDots(data.totalAsesi);
            
    final int rawTotalJadwal = data.totalJadwal > 0
        ? data.totalJadwal
        : (data.totalAsesmen > 0 ? data.totalAsesmen : data.jadwalBelumTerkonfirmasi);
    final jadwalValue = isLoading
        ? '...'
        : NumberFormatHelper.formatWithDots(rawTotalJadwal);
            
    final asesorValue = isLoading
        ? '...'
        : NumberFormatHelper.formatWithDots(data.totalAsesor);

    final tukValue = isLoading
        ? '...'
        : NumberFormatHelper.formatWithDots(data.totalTuk);
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
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Dynamic Day/Month Dropdown Pill
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0x99FFFFFF), // white with 0.6 opacity
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentDayMonth,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Summary Cards
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              NewSummaryCard(
                title: 'Asessi',
                value: asesiValue,
                subtitle: 'Asessi Terdaftar',
                icon: Icons.people_outline_rounded,
              ),
              NewSummaryCard(
                title: 'Jadwal',
                value: jadwalValue,
                subtitle: 'Jadwal Terdaftar',
                icon: Icons.event_note_rounded,
                onTap: widget.onNavigateToJadwal,
              ),
              NewSummaryCard(
                title: 'Asessor',
                value: asesorValue,
                subtitle: 'Asessor Aktif',
                icon: Icons.person_search_rounded,
              ),
              NewSummaryCard(
                title: 'TUK',
                value: tukValue,
                subtitle: 'TUK Terdaftar',
                icon: Icons.apartment_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const NewSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

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
            color: Color(0x0A000000), // black with 0.04 opacity
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            icon,
            size: 38,
            color: const Color(0xFF4A9EDF),
          ),
        ],
      ),
    ),
  );
}
}

/*
// Custom widget for summary card
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String subtitle;
  final String comparison;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.subtitle,
    required this.comparison,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    // Parse comparison "bulan_lalu > bulan_ini"
    final comparisonData = DashboardSummary.parseComparison(comparison);
    final previous = comparisonData['previous'] ?? 0;
    final current = comparisonData['current'] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // black with 0.04 opacity
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          // Left Column for text information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Comparison display - replaces trend indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$previous → $current',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Right Column for visual icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    );
  }
}
*/
