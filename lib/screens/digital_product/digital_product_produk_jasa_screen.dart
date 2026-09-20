import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/digital_product_models.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_create_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductProdukJasaScreen extends StatefulWidget {
  const DigitalProductProdukJasaScreen({super.key});

  @override
  State<DigitalProductProdukJasaScreen> createState() =>
      _DigitalProductProdukJasaScreenState();
}

class _DigitalProductProdukJasaScreenState
    extends State<DigitalProductProdukJasaScreen> {
  String? _selectedCategory;
  static const int _currentBottomNavIndex = 0;

  static const List<String> _categories = [
    'Online',
    'Offline',
    'Jasa',
    'Produk',
  ];

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

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
    }
  }

  List<DigitalProductItem> get _filteredProducts {
    List<DigitalProductItem> list = digitalProductMockList;

    if (_selectedCategory != null) {
      list = list.where((item) {
        return item.category.toLowerCase() == _selectedCategory!.toLowerCase();
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top App Bar: "< Produk/Jasa"
                _buildAppBar(context, 'Produk/Jasa'),

                // Category Tabs Bar with Divider
                _buildCategoryChips(),

                // Product Grid (Virtual scrollable)
                Expanded(
                  child: products.isEmpty
                      ? _buildEmptyState()
                      : CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                16.0,
                                80.0,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                  mainAxisExtent: 216.0,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final item = products[index];
                                    return DigitalProductCard(
                                      item: item,
                                      onTap: () async {
                                        final targetIndex =
                                            await Navigator.of(context)
                                                .push<int>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DigitalProductDetailScreen(
                                              item: item,
                                            ),
                                          ),
                                        );
                                        if (targetIndex != null && mounted) {
                                          _onBottomNavTap(targetIndex);
                                        }
                                      },
                                    );
                                  },
                                  childCount: products.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // Floating Action Button (+) for creating Produk/Jasa
            Positioned(
              right: 20,
              bottom: 16,
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DigitalProductCreateScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.plus,
                        size: 26,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
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

  Widget _buildAppBar(BuildContext context, String title) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
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

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => _onCategorySelected(category),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFFE0EDFB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            LucideIcons.package,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

