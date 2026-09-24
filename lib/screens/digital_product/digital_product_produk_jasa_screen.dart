import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_create_screen.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductProdukJasaScreen extends StatefulWidget {
  const DigitalProductProdukJasaScreen({super.key});

  @override
  State<DigitalProductProdukJasaScreen> createState() =>
      _DigitalProductProdukJasaScreenState();
}

class _DigitalProductProdukJasaScreenState
    extends State<DigitalProductProdukJasaScreen> {
  List<DigitalProductItem> _products = const [];
  String? _selectedCategory;
  bool _loading = true;
  String _error = '';
  static const int _currentBottomNavIndex = 0;

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
      final products = await DigitalProductService.getMine();
      products.sort((a, b) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      });
      if (mounted) setState(() => _products = products);
    } catch (_) {
      if (mounted) setState(() => _error = 'Produk/Jasa belum dapat dimuat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DigitalProductItem> get _filtered =>
      _products.where((item) => item.matchesFilter(_selectedCategory)).toList();

  Future<void> _onBottomNavTap(int index) async {
    if (index == 4) {
      final targetIndex = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductProfileScreen()));
      if (targetIndex != null && mounted && Navigator.canPop(context)) {
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
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                DigitalProductCategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) => setState(() {
                    if (category.isEmpty || category.toLowerCase() == 'semua') {
                      _selectedCategory = null;
                    } else {
                      _selectedCategory = _selectedCategory == category
                          ? null
                          : category;
                    }
                  }),
                ),
                const Divider(height: 1),
                Expanded(child: _buildContent()),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 16,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DigitalProductCreateScreen(),
                    ),
                  );
                  if (mounted) _load();
                },
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, color: Color(0xFF1E3A8A)),
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

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: TextButton(onPressed: _load, child: Text('$_error. Coba lagi')),
      );
    }
    final products = _filtered;
    if (products.isEmpty) {
      return const Center(child: Text('Belum ada produk/jasa'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 216,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => DigitalProductCard(
          item: products[index],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DigitalProductDetailScreen(item: products[index]),
            ),
          ),
        ),
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
                'Produk/Jasa',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
