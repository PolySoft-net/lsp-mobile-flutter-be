import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'investment_payment_screen.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final InvestmentStartupItem startup;

  const InvestmentDetailScreen({
    super.key,
    required this.startup,
  });

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  late InvestmentStartupItem _startup;
  bool _isTogglingFavorite = false;
  bool _hasChanged = false;
  bool _isExpandedDescription = false;

  @override
  void initState() {
    super.initState();
    _startup = widget.startup;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    try {
      final updated = await InvestmentService.getStartupDetail(_startup.id);
      if (mounted) {
        setState(() => _startup = updated);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isTogglingFavorite = true);
    final nextState = !_startup.isFavorite;
    try {
      await InvestmentService.toggleFavorite(_startup.id, _startup.isFavorite);
      if (!mounted) return;
      setState(() {
        _startup = _startup.copyWith(isFavorite: nextState);
        _hasChanged = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status favorit')),
      );
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetFundingStr =
        NumberFormatHelper.formatWithDots(_startup.targetFunding);
    final valuationStr = _startup.valuation > 0
        ? 'Rp ${NumberFormatHelper.formatWithDots(_startup.valuation)}'
        : 'Rp 1.500.000.000';

    final double rawProgress = _startup.targetFunding > 0
        ? (_startup.collectedFunding / _startup.targetFunding)
        : 0.0;
    final double progress = rawProgress > 0
        ? rawProgress.clamp(0.05, 1.0)
        : ((_startup.nama.hashCode.abs() % 40 + 50) / 100.0);
    final int percentInt = (progress * 100).toInt();

    final Color themeColor = _resolveCategoryColor(_startup.kategori);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ColoredBox(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: CustomAppBar(
                title: '',
                onBack: () => Navigator.pop(context, _hasChanged),
                rightWidget: IconButton(
                  icon: Icon(
                    _startup.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _startup.isFavorite
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF0F172A),
                    size: 22,
                  ),
                  onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Graphic Illustration Banner with Floating Inset Logo (Image 2)
              _buildBannerWithLogo(themeColor),

              const SizedBox(height: 38),

              // 2. Startup Title & Subtitle
              Text(
                _startup.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatSubtitle(_startup.kategori),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Progress Section (Image 2)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$percentInt% Terkumpul ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066F6),
                      ),
                    ),
                    TextSpan(
                      text: 'dari Rp $targetFundingStr',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF0066F6),
                ),
              ),

              const SizedBox(height: 22),

              // 4. 3 Info Tiles in Column (Image 2)
              _buildInfoTile(
                icon: Icons.track_changes_rounded,
                label: 'Target Dana',
                value: 'Rp $targetFundingStr',
              ),
              _buildInfoTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Valuasi',
                value: valuationStr,
              ),
              _buildInfoTile(
                icon: Icons.trending_up_rounded,
                label: 'Estimasi ROI',
                value: _startup.estimasiRoi.isNotEmpty
                    ? _startup.estimasiRoi
                    : '-',
              ),

              const SizedBox(height: 14),

              // 5. Section: Tentang Startup (Image 2)
              const Text(
                'Tentang Startup',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _startup.deskripsi.isNotEmpty
                    ? _startup.deskripsi
                    : '${_startup.nama} adalah platform teknologi digital inovatif yang berfokus pada solusi terintegrasi untuk akselerasi ekosistem industri lokal.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                maxLines: _isExpandedDescription ? null : 3,
                overflow:
                    _isExpandedDescription ? null : TextOverflow.ellipsis,
              ),
              if (_startup.deskripsi.length > 100) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandedDescription = !_isExpandedDescription;
                    });
                  },
                  child: Text(
                    _isExpandedDescription ? 'Tutup' : 'Lihat Selengkapnya',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066F6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerWithLogo(Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rounded Graphic Banner
        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Inset Logo (bottom left overlapping banner)
        Positioned(
          left: 16,
          bottom: -26,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _buildAvatarCircle(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle(Color color) {
    final initials = _startup.nama.trim().isNotEmpty
        ? (_startup.nama.trim().split(' ').length > 1
            ? '${_startup.nama.trim().split(' ')[0][0]}${_startup.nama.trim().split(' ')[1][0]}'
            : (_startup.nama.trim().length >= 2
                ? _startup.nama.trim().substring(0, 2)
                : _startup.nama.trim()))
        : 'ST';

    final icon = _resolveCategoryIcon(_startup.kategori);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 24)
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0066F6), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
          child: ElevatedButton(
            onPressed: () async {
              final res = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => InvestmentPaymentScreen(startup: _startup),
                ),
              );
              if (res == true) {
                _hasChanged = true;
                _refreshDetail();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Investasi Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
          ),
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
