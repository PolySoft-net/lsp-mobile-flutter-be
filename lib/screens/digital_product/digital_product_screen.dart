import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_banner.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_header.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_create_screen.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_favorit_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductScreen({super.key, this.onBackToHome});

  @override
  State<DigitalProductScreen> createState() => _DigitalProductScreenState();
}

class _DigitalProductScreenState extends State<DigitalProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DigitalProductItem> _products = const [];
  List<DigitalProductItem> _popularProducts = const [];
  String? _selectedCategory;
  Timer? _searchDebounce;
  bool _loading = true;
  String _error = '';
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        DigitalProductService.getProducts(
          search: _searchController.text,
          filter: _selectedCategory ?? '',
        ),
        DigitalProductService.getPopularProducts(limit: 10),
      ]);
      if (mounted) {
        setState(() {
          _products = results[0];
          _popularProducts = results[1];
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Produk belum dapat dimuat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadProducts);
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
    _loadProducts();
  }

  Future<void> _setFavorite(int index, bool favorite) async {
    final item = _products[index];
    setState(() => _products[index] = item.copyWith(isFavorite: favorite));
    try {
      await DigitalProductService.setFavorite(item.id, favorite);
    } catch (_) {
      if (mounted) {
        setState(() => _products[index] = item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan login sebagai asesi untuk menyimpan favorit',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openDetail(DigitalProductItem item) async {
    final targetIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => DigitalProductDetailScreen(item: item)),
    );
    if (targetIndex != null && mounted) {
      await _onBottomNavTap(targetIndex);
    } else if (mounted) {
      await _loadProducts();
    }
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 3) {
      final targetIndex = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductFavoritScreen()));
      if (targetIndex != null && mounted) {
        setState(() => _currentBottomNavIndex = targetIndex);
      }
      return;
    }
    if (index == 4) {
      final targetIndex = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductProfileScreen()));
      if (targetIndex != null && mounted) {
        setState(() => _currentBottomNavIndex = targetIndex);
      }
      return;
    }
    setState(() => _currentBottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DigitalProductHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onFavoriteTap: () => Navigator.of(
                context,
              ).push(FadePageRoute(page: const DigitalProductFavoritScreen())),
              onAddProductTap: () async {
                await Navigator.of(context).push(
                  FadePageRoute(page: const DigitalProductCreateScreen()),
                );
                if (mounted) _loadProducts();
              },
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: DigitalProductBottomBar(
        selectedIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: _loadProducts,
          child: Text('$_error. Coba lagi'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (_currentBottomNavIndex != 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: DigitalProductBanner(
                  products: _popularProducts.isNotEmpty
                      ? _popularProducts
                      : _products,
                  onProductTap: _openDetail,
                  onTap: _popularProducts.isNotEmpty
                      ? () => _openDetail(_popularProducts.first)
                      : (_products.isNotEmpty
                          ? () => _openDetail(_products.first)
                          : null),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: _currentBottomNavIndex == 1 ? 4 : 8,
                bottom: 12,
              ),
              child: DigitalProductCategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
            ),
          ),
          if (_products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Belum ada produk pada skema ini')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 216,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DigitalProductCard(
                    item: _products[index],
                    onTap: () => _openDetail(_products[index]),
                    onFavoriteChanged: (favorite) =>
                        _setFavorite(index, favorite),
                  ),
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
