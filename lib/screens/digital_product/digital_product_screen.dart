import 'package:material_ui/material_ui.dart';
import '../../models/digital_product_models.dart';
import '../../widgets/digital_product/digital_product_header.dart';
import '../../widgets/digital_product/digital_product_banner.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_favorit_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<DigitalProductScreen> createState() => _DigitalProductScreenState();
}

class _DigitalProductScreenState extends State<DigitalProductScreen> {
  String? _selectedCategory;
  int _currentBottomNavIndex = 0;

  final List<DigitalProductItem> _allProducts = digitalProductMockList;

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
    if (index == 3) {
      final targetIndex = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => const DigitalProductFavoritScreen(),
        ),
      );
      if (targetIndex != null && mounted) {
        setState(() {
          _currentBottomNavIndex = targetIndex;
        });
      }
      return;
    }
    if (index == 4) {
      final targetIndex = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => const DigitalProductProfileScreen(),
        ),
      );
      if (targetIndex != null && mounted) {
        setState(() {
          _currentBottomNavIndex = targetIndex;
        });
      }
      return;
    }
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  List<DigitalProductItem> get _filteredProducts {
    if (_selectedCategory == null) {
      return _allProducts;
    }
    return _allProducts.where((item) {
      return item.category.toLowerCase() == _selectedCategory!.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Pinned Top Header
            DigitalProductHeader(
              onFavoriteTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DigitalProductFavoritScreen(),
                  ),
                );
              },
            ),

            // Scrollable Virtualized Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Promotional Banner (disembunyikan saat di menu Explore)
                  if (_currentBottomNavIndex != 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: DigitalProductBanner(
                          onTap: () async {
                            if (products.isNotEmpty) {
                              final targetIndex =
                                  await Navigator.of(context).push<int>(
                                MaterialPageRoute(
                                  builder: (_) => DigitalProductDetailScreen(
                                    item: products.first,
                                  ),
                                ),
                              );
                              if (targetIndex != null && mounted) {
                                _onBottomNavTap(targetIndex);
                              }
                            }
                          },
                        ),
                      ),
                    ),

                  // Category Tabs (Online, Offline, Jasa, Produk)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: _currentBottomNavIndex == 1 ? 4.0 : 8.0,
                        bottom: 12.0,
                      ),
                      child: DigitalProductCategoryChips(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                    ),
                  ),

                  // Virtual Scrolling Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  await Navigator.of(context).push<int>(
                                MaterialPageRoute(
                                  builder: (_) => DigitalProductDetailScreen(
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

                  // Bottom padding for scroll clearance
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24.0),
                  ),
                ],
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
}
