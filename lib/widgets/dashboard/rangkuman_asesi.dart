import 'package:material_ui/material_ui.dart';
import '../../models/dashboard_models.dart';
import '../../utils/number_format_helper.dart';
import '../../services/api_service.dart';
import '../../screens/asesi/asesi_portofolio_screen.dart';
import '../../screens/digital_product/digital_product_screen.dart';

class RangkumanAsesi extends StatefulWidget {
  final AsesiDashboardSummary? data;
  final bool? isLoading;
  final Function(int tabIndex)? onNavigateToTab;

  const RangkumanAsesi({
    super.key,
    this.data,
    this.isLoading,
    this.onNavigateToTab,
  });

  @override
  State<RangkumanAsesi> createState() => _RangkumanAsesiState();
}

class _RangkumanAsesiState extends State<RangkumanAsesi> {
  late Future<AsesiDashboardSummary>? _summaryFuture;

  String get _currentDayMonth {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }


  @override
  void initState() {
    super.initState();
    // Standalone fallback: Only load if not provided by parent
    if (widget.data == null) {
      _summaryFuture = DashboardService.getAsesiSummary();
    } else {
      _summaryFuture = null;
    }
  }

  @override
  void didUpdateWidget(RangkumanAsesi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      setState(() {
        _summaryFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      return _buildContent(widget.data!, widget.isLoading ?? false);
    }

    return FutureBuilder<AsesiDashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? AsesiDashboardSummary.empty();
        return _buildContent(data, isLoading);
      },
    );
  }

  Widget _buildContent(AsesiDashboardSummary data, bool isLoading) {
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
            color: Color(0x26000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0x99FFFFFF),
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
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _AsesiSummaryCard(
                title: 'Sertifikat',
                value: isLoading
                    ? '...'
                    : NumberFormatHelper.formatWithDots(data.totalSertifikat),
                subtitle: 'Sertifikat dimiliki',
                icon: Icons.workspace_premium_rounded,
                iconColor: const Color(0xFFFF9800),
                iconBgColor: const Color(0xFFFFF3E0),
                onTap: () => widget.onNavigateToTab?.call(3),
              ),
              _AsesiSummaryCard(
                title: 'Asesmen',
                value: isLoading
                    ? '...'
                    : NumberFormatHelper.formatWithDots(
                        data.asesmenAktif,
                      ),
                subtitle: 'Uji sedang diikuti',
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF1976D2),
                iconBgColor: const Color(0xFFE3F2FD),
                onTap: () => widget.onNavigateToTab?.call(2),
              ),
              _AsesiSummaryCard(
                title: 'Product Digital',
                value: 'Katalog',
                subtitle: 'Produk & Jasa asesi',
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFF0D9488),
                iconBgColor: const Color(0xFFCCFBF1),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DigitalProductScreen(),
                  ),
                ),
              ),
              _AsesiSummaryCard(
                title: 'Portofolio',
                value: 'Karya',
                subtitle: 'Bukti pengalaman kerja',
                icon: Icons.folder_shared_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFFF3E8FF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AsesiPortofolioScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AsesiSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const _AsesiSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
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
                      maxLines: 1,
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
        ),
      ),
    );
  }
}
