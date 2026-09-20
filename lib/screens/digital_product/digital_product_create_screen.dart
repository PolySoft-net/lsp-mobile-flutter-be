import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'digital_product_form_screen.dart';

class DigitalProductCreateScreen extends StatefulWidget {
  const DigitalProductCreateScreen({super.key});

  @override
  State<DigitalProductCreateScreen> createState() =>
      _DigitalProductCreateScreenState();
}

class _DigitalProductCreateScreenState
    extends State<DigitalProductCreateScreen> {
  String? _selectedType; // 'Produk' or 'Jasa'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: "< Produk/Jasa"
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Big Circular Illustration Container
                    _buildTopIllustration(),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'BUATLAH PRODUK/JASA ANDA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      'Buatlah Prduk/Jasa yang ingin anda pasarkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Option: Produk
                    _buildSelectionCard(
                      type: 'Produk',
                      title: 'Produk',
                      subtitle: 'Produk',
                      isSelected: _selectedType == 'Produk',
                      onTap: () {
                        setState(() {
                          _selectedType = 'Produk';
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Option: Jasa
                    _buildSelectionCard(
                      type: 'Jasa',
                      title: 'Jasa',
                      subtitle: 'Jasa',
                      isSelected: _selectedType == 'Jasa',
                      onTap: () {
                        setState(() {
                          _selectedType = 'Jasa';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom "Selanjutnya" Button
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 4),
              Text(
                'Produk/Jasa',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIllustration() {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFFDBEAFE),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 64,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top lid tab handle
              Positioned(
                top: 0,
                child: Container(
                  width: 44,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Main crate box
              Positioned(
                bottom: 0,
                child: Container(
                  width: 62,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String type,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE0EDFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFBFDBFE),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Open Carton Box Icon
            const Icon(
              LucideIcons.package_open,
              size: 34,
              color: Color(0xFF0F172A),
            ),
            const SizedBox(width: 14),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Radio Button Indicator
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  width: 1.5,
                ),
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final hasSelection = _selectedType != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: hasSelection
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DigitalProductFormScreen(
                        productType: _selectedType!,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasSelection
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Selanjutnya',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
