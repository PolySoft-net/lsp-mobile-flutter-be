import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

class InvestmentPaymentScreen extends StatefulWidget {
  final InvestmentStartupItem startup;

  const InvestmentPaymentScreen({
    super.key,
    required this.startup,
  });

  @override
  State<InvestmentPaymentScreen> createState() =>
      _InvestmentPaymentScreenState();
}

class _InvestmentPaymentScreenState extends State<InvestmentPaymentScreen> {
  late final List<int> _nominals;
  late int _selectedNominal;
  int _selectedPaymentMethod = 0; // 0: Transfer Bank, 1: E-wallet, 2: Virtual Account
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final min = widget.startup.minimumTicket > 0
        ? widget.startup.minimumTicket
        : 1000000;
    _nominals = [
      min,
      min * 2,
      min * 5,
      min * 10,
    ];
    _selectedNominal = _nominals[0];
  }

  double _calculateEquityShare(int nominal) {
    if (widget.startup.valuation > 0) {
      return (nominal / widget.startup.valuation * 100.0);
    }
    if (widget.startup.targetFunding > 0) {
      final equity = widget.startup.equityOffered > 0 ? widget.startup.equityOffered : 10.0;
      return (nominal / widget.startup.targetFunding * equity);
    }
    return (nominal / 200000000.0 * 10.0);
  }

  Future<void> _handlePayment() async {
    if (widget.startup.minimumTicket > 0 &&
        _selectedNominal < widget.startup.minimumTicket) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Nominal minimal investasi adalah Rp ${NumberFormatHelper.formatWithDots(widget.startup.minimumTicket)}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final paymentMethods = const ['Transfer Bank', 'E-wallet', 'Virtual Account'];
    final selectedMethod = paymentMethods[_selectedPaymentMethod];
    final user = AuthRepository.currentUserInstance;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Investor';
    final userEmail = user?.email ?? '';

    final submission = InvestmentInterestSubmission(
      startupId: int.tryParse(widget.startup.id) ?? 0,
      investorName: userName,
      investorEmail: userEmail,
      offeredAmount: _selectedNominal,
      notes: 'Checkout Investasi via $selectedMethod (Simulasi Payment Gateway)',
    );

    try {
      await InvestmentService.submitInterest(submission);
      if (!mounted) return;
      _showSuccessBottomSheet();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses transaksi investasi. Silakan coba lagi.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessBottomSheet() {
    final nominalStr = NumberFormatHelper.formatWithDots(_selectedNominal);
    final equityShare = _calculateEquityShare(_selectedNominal);
    final equityStr = equityShare.toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.paddingOf(ctx).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0066F6),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Investasi Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selamat! Anda telah resmi berinvestasi sebesar Rp $nominalStr (estimasi $equityStr% saham) pada ${widget.startup.nama}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close sheet
                  Navigator.pop(context, true); // Return to detail / catalog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              title: 'Investasi',
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Pembayaran aman dan terpercaya',
                    style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Pilih Nominal Investasi
            const Text(
              'Pilih Nominal Investasi',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Grid of Nominal Cards (Image 3)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
              ),
              itemCount: _nominals.length,
              itemBuilder: (context, index) {
                final nominal = _nominals[index];
                final isSelected = _selectedNominal == nominal;
                final nominalStr = NumberFormatHelper.formatWithDots(nominal);
                final equity = _calculateEquityShare(nominal);
                final equityStr = equity.toStringAsFixed(1).replaceAll('.', ',');

                return GestureDetector(
                  onTap: () => setState(() => _selectedNominal = nominal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0066F6)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF0066F6),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rp $nominalStr',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF0066F6)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '(≈ $equityStr% saham)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? const Color(0xFF0066F6)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Section 2: Metode Pembayaran
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            _buildPaymentMethodTile(
              index: 0,
              icon: Icons.account_balance_rounded,
              iconBgColor: const Color(0xFF0066F6),
              title: 'Transfer Bank',
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              index: 1,
              icon: Icons.account_balance_wallet_rounded,
              iconBgColor: const Color(0xFF334155),
              title: 'E-wallet',
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              index: 2,
              icon: Icons.receipt_long_rounded,
              iconBgColor: const Color(0xFF0284C7),
              title: 'Virtual Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required int index,
    required IconData icon,
    required Color iconBgColor,
    required String title,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
