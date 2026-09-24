import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductFavoritScreen extends StatefulWidget {
  const DigitalProductFavoritScreen({super.key});

  @override
  State<DigitalProductFavoritScreen> createState() =>
      _DigitalProductFavoritScreenState();
}

class _DigitalProductFavoritScreenState
    extends State<DigitalProductFavoritScreen> {
  List<DigitalProductItem> _products = const [];
  String? _selectedCategory;
  bool _loading = true;
  String _error = '';
  static const int _currentBottomNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final categoryFilter = (_selectedCategory == null ||
              _selectedCategory!.trim().isEmpty ||
              _selectedCategory!.trim().toLowerCase() == 'semua')
          ? ''
          : _selectedCategory!.trim();

      final products = await DigitalProductService.getFavorites(
        filter: categoryFilter,
      );
      products.sort((a, b) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      });
      if (mounted) setState(() => _products = products);
    } catch (_) {
      if (mounted) setState(() => _error = 'Favorit belum dapat dimuat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCategory(String category) {
    setState(() {
      if (category.isEmpty || category.toLowerCase() == 'semua') {
        _selectedCategory = null;
      } else {
        _selectedCategory = _selectedCategory == category ? null : category;
      }
    });
    _load();
  }

  Future<void> _removeFavorite(DigitalProductItem item) async {
    final previous = _products;
    setState(
      () => _products = _products.where((p) => p.id != item.id).toList(),
    );
    try {
      await DigitalProductService.setFavorite(item.id, false);
    } catch (_) {
      if (mounted) setState(() => _products = previous);
    }
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 3) return;
    if (index == 4) {
      final targetIndex = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductProfileScreen()));
      if (targetIndex != null && mounted && targetIndex != 3) {
        Navigator.pop(context, targetIndex);
      }
      return;
    }
    if (Navigator.canPop(context)) Navigator.pop(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            DigitalProductCategoryChips(
              selectedCategory: _selectedCategory,
              onCategorySelected: _selectCategory,
            ),
            const Divider(height: 1),
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
        child: TextButton(onPressed: _load, child: Text('$_error. Coba lagi')),
      );
    }
    if (_products.isEmpty) {
      return const Center(child: Text('Belum ada produk favorit'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 216,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final item = _products[index];
          return DigitalProductCard(
            item: item,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DigitalProductDetailScreen(item: item),
                ),
              );
              if (mounted) _load();
            },
            onFavoriteChanged: (favorite) {
              if (!favorite) _removeFavorite(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded, size: 24),
              SizedBox(width: 4),
              Text(
                'Favorit',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
