import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_cart_service.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_contract_viewer.dart';
import '../../widgets/digital_product/digital_product_order_card.dart';
import '../../widgets/digital_product/digital_product_seller_card.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_create_screen.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductProdukJasaScreen extends StatefulWidget {
  final int initialTab; // 0: Produk Saya, 1: Pesanan Masuk
  final int? initialProductId;

  const DigitalProductProdukJasaScreen({
    super.key,
    this.initialTab = 0,
    this.initialProductId,
  });

  @override
  State<DigitalProductProdukJasaScreen> createState() =>
      _DigitalProductProdukJasaScreenState();
}

class _DigitalProductProdukJasaScreenState
    extends State<DigitalProductProdukJasaScreen> {
  int _activeTabIndex = 0;
  List<DigitalProductItem> _products = const [];
  List<DigitalProductOrder> _orders = const [];
  int? _filterProductId;
  String? _filterProductTitle;
  String? _selectedCategory;
  bool _loadingProducts = true;
  bool _loadingOrders = true;
  String _productsError = '';
  String? _ordersError;
  final Set<String> _respondingOrderIds = {};
  static const int _currentBottomNavIndex = 4; // Profil sub-screen

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTab;
    _filterProductId = widget.initialProductId;
    _loadProducts();
    _loadOrders();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _productsError = '';
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
      if (mounted) setState(() => _productsError = 'Produk belum dapat dimuat');
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loadingOrders = true;
      _ordersError = null;
    });
    try {
      final orders = await DigitalProductCartService.getOrders(
        role: 'seller',
        limit: 100,
      );
      if (mounted) {
        setState(() {
          _orders = orders;
          _ordersError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _ordersError = DigitalProductCartService.errorMessage(error);
        });
      }
    } finally {
      if (mounted) setState(() => _loadingOrders = false);
    }
  }

  List<DigitalProductItem> get _filteredProducts =>
      _products.where((item) => item.matchesFilter(_selectedCategory)).toList();

  List<DigitalProductOrder> get _displayedOrders => _filterProductId == null
      ? _orders
      : _orders
          .where((o) => int.tryParse(o.product.id) == _filterProductId)
          .toList();

  int _orderCountForProduct(String productId) {
    return _orders.where((order) => order.product.id == productId).length;
  }

  Future<void> _respondToOrder(DigitalProductOrder order, String action) async {
    if (_respondingOrderIds.contains(order.id)) return;
    setState(() => _respondingOrderIds.add(order.id));
    try {
      int? counterPrice;
      if (action == 'counter') {
        final controller = TextEditingController();
        try {
          counterPrice = await showDialog<int>(
            context: context,
            builder: (dialogContext) {
              String? validationError;
              return StatefulBuilder(
                builder: (context, setDialogState) => AlertDialog(
                  title: const Text('Ajukan harga balasan'),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Harga (Rp)',
                      errorText: validationError,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        final value = int.tryParse(controller.text);
                        if (value != null && value > 0) {
                          Navigator.pop(dialogContext, value);
                        } else {
                          setDialogState(
                            () => validationError =
                                'Masukkan harga lebih dari nol.',
                          );
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              );
            },
          );
        } finally {
          controller.dispose();
        }
        if (counterPrice == null) return;
      }

      await DigitalProductCartService.negotiateOrder(
        order.id,
        action: action,
        counterPrice: counterPrice,
      );
      await _loadOrders();
      if (!mounted) return;
      await DigitalProductContractViewer.show(context, orderId: order.id);
      if (mounted) await _loadOrders();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(DigitalProductCartService.errorMessage(error)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _respondingOrderIds.remove(order.id));
    }
  }

  Future<void> _openContract(DigitalProductOrder order) async {
    await DigitalProductContractViewer.show(context, orderId: order.id);
    if (mounted) await _loadOrders();
  }

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
                _buildTabBar(),
                if (_activeTabIndex == 0) ...[
                  DigitalProductCategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) => setState(() {
                      if (category.isEmpty ||
                          category.toLowerCase() == 'semua') {
                        _selectedCategory = null;
                      } else {
                        _selectedCategory = _selectedCategory == category
                            ? null
                            : category;
                      }
                    }),
                  ),
                  const Divider(height: 1),
                  Expanded(child: _buildProductsContent()),
                ] else ...[
                  Expanded(child: _buildOrdersContent()),
                ],
              ],
            ),
            if (_activeTabIndex == 0)
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
                    if (mounted) _loadProducts();
                  },
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3D2563EB),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.plus, color: Colors.white),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Produk & Jasa Saya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DigitalProductCreateScreen(),
                ),
              );
              if (mounted) _loadProducts();
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plus, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 4),
                  Text(
                    'Tambah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _tabButton(
                index: 0,
                title: 'Produk Saya',
                count: _products.length,
              ),
            ),
            Expanded(
              child: _tabButton(
                index: 1,
                title: 'Pesanan Masuk',
                count: _orders.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String title,
    int? count,
  }) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeTabIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsContent() {
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_productsError.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: _loadProducts,
          child: Text('$_productsError. Coba lagi'),
        ),
      );
    }
    final products = _filteredProducts;
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada produk/jasa yang di-upload.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadProducts(), _loadOrders()]);
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 268,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final orderCount = _orderCountForProduct(product.id);
          return DigitalProductSellerCard(
            item: product,
            orderCount: orderCount,
            onViewOrders: () {
              setState(() {
                _filterProductId = int.tryParse(product.id);
                _filterProductTitle = product.title;
                _activeTabIndex = 1;
              });
            },
            onManageProduct: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DigitalProductDetailScreen(
                    item: product,
                    isFromProfile: true,
                  ),
                ),
              );
              if (mounted) _loadProducts();
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdersContent() {
    final displayedOrders = _displayedOrders;

    return Column(
      children: [
        if (_filterProductId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFEFF6FF),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sliders_horizontal,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pesanan untuk: ${_filterProductTitle ?? "Produk #$_filterProductId"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _filterProductId = null;
                      _filterProductTitle = null;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loadingOrders
              ? const Center(child: CircularProgressIndicator())
              : _ordersError != null
                  ? Center(
                      child: TextButton(
                        onPressed: _loadOrders,
                        child: Text('$_ordersError. Coba lagi'),
                      ),
                    )
                  : displayedOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.inbox,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _filterProductId != null
                                      ? 'Belum ada pesanan untuk produk ini'
                                      : 'Belum ada pesanan masuk',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _filterProductId != null
                                      ? 'Pesanan pembeli untuk produk ini akan muncul di sini.'
                                      : 'Pesanan dari pembeli untuk produk digital Anda akan muncul di sini.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: displayedOrders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = displayedOrders[index];
                              return DigitalProductOrderCard(
                                order: order,
                                role: 'seller',
                                responding:
                                    _respondingOrderIds.contains(order.id),
                                onRespond: (action) =>
                                    _respondToOrder(order, action),
                                onOpenContract: () => _openContract(order),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
