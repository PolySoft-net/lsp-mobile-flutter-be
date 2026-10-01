import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../models/digital_product_models.dart';
import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_cart_service.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_contract_viewer.dart';
import '../../widgets/digital_product/digital_product_order_card.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductFavoritScreen extends StatefulWidget {
  final int initialTab; // 0: Pesanan, 1: Favorit
  const DigitalProductFavoritScreen({super.key, this.initialTab = 0});

  @override
  State<DigitalProductFavoritScreen> createState() =>
      _DigitalProductFavoritScreenState();
}

class _DigitalProductFavoritScreenState
    extends State<DigitalProductFavoritScreen> {
  static const int _pageSize = 20;
  static const int _currentBottomNavIndex = 3;
  int _activeTabIndex = 0;
  String _role = 'buyer';
  List<DigitalProductItem> _favoriteProducts = const [];
  List<DigitalProductOrder> _orders = const [];
  String? _selectedCategory;
  bool _loadingFavorites = true;
  bool _loadingOrders = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _favoritesError;
  String? _ordersError;
  int _ordersGeneration = 0;
  final Set<String> _respondingOrderIds = {};

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTab;
    _loadFavorites();
    _loadOrders(reset: true);
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loadingFavorites = true;
      _favoritesError = null;
    });
    try {
      final category = _selectedCategory?.trim() ?? '';
      final favs = await DigitalProductService.getFavorites(
        filter: category.isEmpty || category.toLowerCase() == 'semua'
            ? ''
            : category,
      );
      favs.sort(
        (a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0),
      );
      if (mounted) setState(() => _favoriteProducts = favs);
    } catch (_) {
      if (mounted) {
        setState(() => _favoritesError = 'Favorit belum dapat dimuat');
      }
    } finally {
      if (mounted) setState(() => _loadingFavorites = false);
    }
  }

  Future<void> _loadOrders({bool reset = false}) async {
    if (!reset && (_loadingMore || !_hasMore)) return;
    final generation = reset ? ++_ordersGeneration : _ordersGeneration;
    final role = _role;
    final offset = reset ? 0 : _orders.length;
    setState(() {
      if (reset) {
        _loadingOrders = true;
        _loadingMore = false;
        _ordersError = null;
        _orders = const [];
        _hasMore = true;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final page = await DigitalProductCartService.getOrders(
        role: role,
        limit: _pageSize,
        offset: offset,
      );
      if (mounted && generation == _ordersGeneration && role == _role) {
        setState(() {
          _ordersError = null;
          _orders = reset ? page : [..._orders, ...page];
          _hasMore = page.length == _pageSize;
        });
      }
    } catch (error) {
      if (mounted && generation == _ordersGeneration && role == _role) {
        setState(
          () => _ordersError = DigitalProductCartService.errorMessage(error),
        );
      }
    } finally {
      if (mounted && generation == _ordersGeneration && role == _role) {
        setState(() {
          _loadingOrders = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _selectRole(String role) async {
    if (_role == role) return;
    setState(() => _role = role);
    await _loadOrders(reset: true);
  }

  Future<void> _selectCategory(String category) async {
    setState(() {
      _selectedCategory = category.isEmpty || category.toLowerCase() == 'semua'
          ? null
          : (_selectedCategory == category ? null : category);
    });
    await _loadFavorites();
  }

  Future<void> _removeFavorite(DigitalProductItem item) async {
    final previous = _favoriteProducts;
    setState(
      () => _favoriteProducts = _favoriteProducts
          .where((p) => p.id != item.id)
          .toList(),
    );
    try {
      await DigitalProductService.setFavorite(item.id, false);
    } catch (_) {
      if (mounted) setState(() => _favoriteProducts = previous);
    }
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
      await _loadOrders(reset: true);
      if (!mounted) return;
      await DigitalProductContractViewer.show(context, orderId: order.id);
      if (mounted) await _loadOrders(reset: true);
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
    if (mounted) await _loadOrders(reset: true);
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index <= 2) {
      Navigator.of(context).pop(index);
      return;
    }
    if (index == 3) return;
    if (index == 4) {
      final target = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductProfileScreen()));
      if (target != null && mounted) Navigator.pop(context, target);
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
            _buildAppBar(),
            _buildTabSelector(),
            if (_activeTabIndex == 1) ...[
              DigitalProductCategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: _selectCategory,
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: _activeTabIndex == 0
                  ? _buildOrdersContent()
                  : _buildFavoritesContent(),
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

  Widget _buildAppBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Pesanan & Favorit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    ),
  );

  Widget _buildTabSelector() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: _buildTabButton(
            0,
            'Pesanan (${_orders.length})',
            LucideIcons.file_text,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabButton(
            1,
            'Favorit (${_favoriteProducts.length})',
            LucideIcons.bookmark,
          ),
        ),
      ],
    ),
  );

  Widget _buildTabButton(int index, String title, IconData icon) {
    final selected = _activeTabIndex == index;
    return TextButton.icon(
      onPressed: () => setState(() => _activeTabIndex = index),
      icon: Icon(icon, size: 15),
      label: Text(title, overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFF2563EB)
            : const Color(0xFF64748B),
        backgroundColor: selected
            ? const Color(0xFFEFF6FF)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildOrdersContent() {
    if (_loadingOrders) return const Center(child: CircularProgressIndicator());
    if (_ordersError != null && _orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_ordersError!, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => _loadOrders(reset: true),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Expanded(child: _roleButton('buyer', 'Pembelian')),
              Expanded(child: _roleButton('seller', 'Penjualan')),
            ],
          ),
        ),
        Expanded(
          child: _orders.isEmpty
              ? RefreshIndicator(
                  onRefresh: () => _loadOrders(reset: true),
                  child: ListView(
                    children: const [
                      SizedBox(height: 130),
                      Center(child: Text('Belum ada riwayat pesanan.')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadOrders(reset: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _orders.length +
                        (_hasMore || _loadingMore || _ordersError != null
                            ? 1
                            : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _orders.length) {
                        if (_ordersError != null) {
                          return TextButton(
                            onPressed: () => _loadOrders(),
                            child: Text('Gagal memuat. Coba lagi'),
                          );
                        }
                        if (_loadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return TextButton(
                          onPressed: () => _loadOrders(),
                          child: const Text('Muat pesanan lainnya'),
                        );
                      }
                      final order = _orders[index];
                      return DigitalProductOrderCard(
                        order: order,
                        role: _role,
                        responding: _respondingOrderIds.contains(order.id),
                        onRespond: (action) => _respondToOrder(order, action),
                        onOpenContract: () => _openContract(order),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _roleButton(String role, String title) {
    final selected = _role == role;
    return TextButton(
      onPressed: () => _selectRole(role),
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFF2563EB)
            : const Color(0xFF64748B),
        backgroundColor: selected
            ? const Color(0xFFEFF6FF)
            : Colors.transparent,
      ),
      child: Text(title),
    );
  }


  Widget _buildFavoritesContent() {
    if (_loadingFavorites) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_favoritesError != null) {
      return Center(
        child: TextButton(
          onPressed: _loadFavorites,
          child: Text('$_favoritesError. Coba lagi'),
        ),
      );
    }
    if (_favoriteProducts.isEmpty) {
      return const Center(child: Text('Belum ada produk favorit'));
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 268,
        ),
        itemCount: _favoriteProducts.length,
        itemBuilder: (context, index) {
          final item = _favoriteProducts[index];
          return DigitalProductCard(
            item: item,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DigitalProductDetailScreen(item: item),
                ),
              );
              if (mounted) _loadFavorites();
            },
            onFavoriteChanged: (favorite) {
              if (!favorite) _removeFavorite(item);
            },
          );
        },
      ),
    );
  }
}
