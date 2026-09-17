import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_portofolio_cards.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductPortofolioScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductPortofolioScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<DigitalProductPortofolioScreen> createState() =>
      _DigitalProductPortofolioScreenState();
}

class _DigitalProductPortofolioScreenState
    extends State<DigitalProductPortofolioScreen> {
  static const int _currentBottomNavIndex = 0;

  Future<void> _onBottomNavTap(int index) async {
    if (index == 4) {
      final targetIndex = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => const DigitalProductProfileScreen(),
        ),
      );
      if (targetIndex != null && mounted) {
        if (targetIndex != 4 && Navigator.canPop(context)) {
          Navigator.pop(context, targetIndex);
        }
      }
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context, index);
    } else if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Highlight Card
                    const PortofolioHighlightCard(),

                    // "Hubungi Penjual" Button Card
                    _buildHubungiPenjualButton(),

                    // "Portofolio Produk Lainnya :" Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Portofolio Produk Lainnya :',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 6),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFFE2E8F0),
                          ),
                        ],
                      ),
                    ),

                    // Other Portfolio Items
                    PortofolioLainnyaCard(
                      title: 'Portofolio Design Aplikasi Motor',
                      price: 'Rp 400.000',
                      type: '/Online',
                      onTap: () {},
                    ),
                    PortofolioLainnyaCard(
                      title: 'Portofolio Prototype Aplikasi Motor',
                      price: 'Rp 400.000',
                      type: '/Online',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DigitalProductBottomBar(
        selectedIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Back arrow
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title
          const Text(
            'Portofolio',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),

          const Spacer(),

          // Sliders / Filter icon
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                LucideIcons.sliders_horizontal,
                size: 20,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubungiPenjualButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menghubungi penjual Jendela_Website...'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: const [
              Icon(
                Icons.phone,
                size: 18,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 12),
              Text(
                'Hubungi Penjual',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

