import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

class InvestmentPortfolioScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToCatalog;

  const InvestmentPortfolioScreen({
    super.key,
    this.onBack,
    this.onNavigateToCatalog,
  });

  @override
  State<InvestmentPortfolioScreen> createState() =>
      _InvestmentPortfolioScreenState();
}

class _InvestmentPortfolioScreenState extends State<InvestmentPortfolioScreen> {
  int _selectedFilter = 0; // 0: Semua, 1: Aktif, 2: Selesai
  bool _isLoading = true;
  InvestmentPortfolioResponse? _portfolio;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    try {
      final res = await InvestmentService.getPortfolio();
      if (!mounted) return;
      setState(() {
        _portfolio = res;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<InvestmentPortfolioItem> get _filteredItems {
    final items = _portfolio?.items ?? const [];
    if (_selectedFilter == 1) {
      return items
          .where((e) => e.status.toLowerCase().contains('aktif'))
          .toList();
    }
    if (_selectedFilter == 2) {
      return items
          .where((e) => e.status.toLowerCase().contains('menunggu'))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final totalInvested = _portfolio?.totalInvested ?? 0;
    final returnPct = _portfolio?.totalReturnPct ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Portofolio Investasi',
              onBack: widget.onBack ?? () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPortfolio,
        color: const Color(0xFF0066F6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Blue Card "Total Nilai Investasi"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066F6), Color(0xFF0049B7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066F6).withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Nilai Investasi',
                        style: TextStyle(
                          color: Color(0xD9FFFFFF),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormatHelper.formatWithDots(totalInvested)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_drop_up_rounded,
                                  color: Color(0xFF4ADE80),
                                  size: 16,
                                ),
                                Text(
                                  '${returnPct.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '(estimasi imbal hasil)',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Filter Pills: Semua / Aktif / Selesai
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'Semua'),
                    const SizedBox(width: 8),
                    _buildFilterTab(1, 'Aktif'),
                    const SizedBox(width: 8),
                    _buildFilterTab(2, 'Menunggu'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Items or Empty State
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF0066F6)),
                  ),
                )
              else if (_filteredItems.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 54,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum Ada Portofolio Investasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Mulai jelajahi startup pilihan dan lakukan investasi pertama Anda untuk melihat portofolio kepemilikan di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        if (widget.onNavigateToCatalog != null) ...[
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: widget.onNavigateToCatalog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066F6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 11),
                            ),
                            child: const Text(
                              'Jelajahi Startup',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return _buildPortfolioCard(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(InvestmentPortfolioItem item) {
    final statusLower = item.status.toLowerCase();
    final isAktif = statusLower.contains('aktif');
    final isPending = statusLower.contains('menunggu');

    Color statusBg = const Color(0xFFF1F5F9);
    Color statusFg = const Color(0xFF64748B);

    if (isAktif) {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF16A34A);
    } else if (isPending) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFD97706);
    } else if (statusLower.contains('gagal') ||
        statusLower.contains('kedaluwarsa')) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFEF4444);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.startupName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nilai Investasi',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${NumberFormatHelper.formatWithDots(item.investedAmount)}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Estimasi Imbal Hasil',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.returnPct > 0
                        ? '+Rp ${NumberFormatHelper.formatWithDots(item.returnAmount)} (${item.returnPct.toStringAsFixed(1)}%)'
                        : '0%',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: item.returnPct > 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final isSelected = _selectedFilter == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
