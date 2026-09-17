import 'package:material_ui/material_ui.dart';
import '../../models/digital_product_models.dart';
import '../../widgets/digital_product/digital_product_header.dart';
import '../../widgets/digital_product/digital_product_banner.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import 'digital_product_portofolio_screen.dart';
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

  // Sample data matching the designs
  final List<DigitalProductItem> _allProducts = [
    const DigitalProductItem(
      id: '1',
      title: 'Jasa Pembuatan Website Company Profil',
      price: 'Rp 400.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Jasa',
      thumbnailType: 'iot',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '2',
      title: 'Tamplate Aplikasi E-commers',
      price: 'Rp 50.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Produk',
      thumbnailType: 'ecom',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '3',
      title: 'Jasa Pembuatan Website Company Profil',
      price: 'Rp 400.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Jasa',
      thumbnailType: 'iot',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '4',
      title: 'Tamplate Aplikasi E-commers',
      price: 'Rp 50.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Produk',
      thumbnailType: 'ecom',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '5',
      title: 'Jasa Pembuatan Website Company Profil',
      price: 'Rp 400.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Jasa',
      thumbnailType: 'iot',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '6',
      title: 'Tamplate Aplikasi E-commers',
      price: 'Rp 50.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Produk',
      thumbnailType: 'ecom',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '7',
      title: 'Jasa Pembuatan Website Company Profil',
      price: 'Rp 400.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Online',
      thumbnailType: 'iot',
      isFavorite: true,
    ),
    const DigitalProductItem(
      id: '8',
      title: 'Tamplate Aplikasi E-commers',
      price: 'Rp 50.000',
      priceUnit: '/Nego',
      author: 'Adriansyah',
      status: 'Open to hire/ Freelance',
      category: 'Offline',
      thumbnailType: 'ecom',
      isFavorite: true,
    ),
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

  void _onBottomNavTap(int index) {
    if (index == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DigitalProductProfileScreen(),
        ),
      );
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
            const DigitalProductHeader(),

            // Scrollable Virtualized Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Promotional Banner (disembunyikan saat di menu Explore)
                  if (_currentBottomNavIndex != 1)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: DigitalProductBanner(),
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
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = products[index];
                          return DigitalProductCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DigitalProductPortofolioScreen(),
                                ),
                              );
                            },
                            onFavoriteTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Favorit: ${item.title}'),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
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
