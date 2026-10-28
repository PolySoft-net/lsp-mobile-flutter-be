import 'package:material_ui/material_ui.dart';

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


  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Blue Card "Total Nilai Investasi" (Image 1)
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
                    const Text(
                      'Rp 0',
                      style: TextStyle(
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_drop_up_rounded,
                                color: Color(0xFF4ADE80),
                                size: 16,
                              ),
                              Text(
                                '0%',
                                style: TextStyle(
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
                          '(7 hari terakhir)',
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

            // 2. Filter Pills: Semua / Aktif / Selesai (Image 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterTab(0, 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterTab(1, 'Aktif'),
                  const SizedBox(width: 8),
                  _buildFilterTab(2, 'Selesai'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Clean Empty State (zeros only, never demo numbers)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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
            ),
          ],
        ),
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
