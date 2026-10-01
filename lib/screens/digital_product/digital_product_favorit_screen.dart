import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/digital_product_models.dart';
import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_cart_service.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_detail_screen.dart';
import 'digital_product_profile_screen.dart';

class DigitalProductFavoritScreen extends StatefulWidget {
  final int initialTab; // 0: Pesanan & Kontrak, 1: Favorit
  const DigitalProductFavoritScreen({super.key, this.initialTab = 0});

  @override
  State<DigitalProductFavoritScreen> createState() =>
      _DigitalProductFavoritScreenState();
}

class _DigitalProductFavoritScreenState
    extends State<DigitalProductFavoritScreen> {
  int _activeTabIndex = 0; // 0: Pesanan & Kontrak, 1: Favorit
  List<DigitalProductItem> _favoriteProducts = const [];
  List<DigitalProductOrder> _orders = const [];
  String? _selectedCategory;
  bool _loading = true;
  String _error = '';
  static const int _currentBottomNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTab;
    _loadAll();
  }

  Future<void> _loadAll() async {
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

      final results = await Future.wait([
        DigitalProductService.getFavorites(filter: categoryFilter),
        DigitalProductCartService.getOrders(),
      ]);

      final favs = List<DigitalProductItem>.from(results[0] as List);
      favs.sort((a, b) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      });

      if (mounted) {
        setState(() {
          _favoriteProducts = favs;
          _orders = results[1] as List<DigitalProductOrder>;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Data belum dapat dimuat');
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
    _loadAll();
  }

  Future<void> _removeFavorite(DigitalProductItem item) async {
    final previous = _favoriteProducts;
    setState(
      () => _favoriteProducts =
          _favoriteProducts.where((p) => p.id != item.id).toList(),
    );
    try {
      await DigitalProductService.setFavorite(item.id, false);
    } catch (_) {
      if (mounted) setState(() => _favoriteProducts = previous);
    }
  }

  Future<void> _removeOrder(String orderId) async {
    await DigitalProductCartService.removeOrder(orderId);
    await _loadAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dihapus')),
      );
    }
  }

  void _showContractDialog(DigitalProductOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.file_text,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Draf Kontrak Kerjasama Digital',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              order.contractNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: SelectableText(
                          order.contractTerms.isNotEmpty
                              ? order.contractTerms
                              : 'Klausul kontrak belum tersedia.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF334155),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tutup Kontrak',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _contactSellerWithContract(DigitalProductOrder order) async {
    final phone = order.product.sellerPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor penjual tidak tersedia')),
      );
      return;
    }

    var waPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (waPhone.startsWith('0')) {
      waPhone = '62${waPhone.substring(1)}';
    }

    final message =
        'Halo ${order.sellerName.isNotEmpty ? order.sellerName : 'Penjual'}, saya telah membuat pesanan untuk "${order.product.title}" dengan Nomor Kontrak ${order.contractNumber} senilai ${order.formattedOfferedPrice}. Mohon konfirmasi tindak lanjut transaksinya. Terima kasih!';

    final uri = Uri.parse(
      'https://wa.me/$waPhone?text=${Uri.encodeComponent(message)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final telUri = Uri(scheme: 'tel', path: phone);
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 0) {
      // Home: Balik ke Beranda Utama aplikasi LSP
      if (Navigator.canPop(context)) Navigator.of(context).pop(0);
      return;
    }
    if (index == 1) {
      // Explore: Beranda Katalog Produk Digital
      if (Navigator.canPop(context)) Navigator.of(context).pop(1);
      return;
    }
    if (index == 2) {
      // Search
      if (Navigator.canPop(context)) Navigator.of(context).pop(2);
      return;
    }
    if (index == 3) {
      // Current tab
      return;
    }
    if (index == 4) {
      final targetIndex = await Navigator.of(
        context,
      ).push<int>(FadePageRoute(page: const DigitalProductProfileScreen()));
      if (targetIndex != null && mounted) {
        Navigator.pop(context, targetIndex);
      }
      return;
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

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Keranjang & Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                index: 0,
                title: 'Pesanan & Kontrak (${_orders.length})',
                icon: LucideIcons.file_text,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                index: 1,
                title: 'Favorit (${_favoriteProducts.length})',
                icon: LucideIcons.bookmark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.shopping_bag,
                  size: 32,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keranjang Pesanan Kosong',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih produk/jasa digital yang Anda minati lalu buat draf kontrak atau ajukan negosiasi harga.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(DigitalProductOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 58,
                  height: 58,
                  color: const Color(0xFFF1F5F9),
                  child: order.product.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          DigitalProductService.absoluteUrl(
                            order.product.thumbnailUrl,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            LucideIcons.package,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      : const Icon(
                          LucideIcons.package,
                          color: Color(0xFF94A3B8),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Penyedia: ${order.sellerName.isNotEmpty ? order.sellerName : '-'}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          order.formattedOfferedPrice,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        if (order.isNegotiated &&
                            order.offeredPrice != order.originalPrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            order.formattedOriginalPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: const Color(0xFFEF4444),
                tooltip: 'Hapus Pesanan',
                onPressed: () => _removeOrder(order.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isNegotiated
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.isNegotiated ? 'Menunggu Negosiasi' : 'Kontrak Dibuat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: order.isNegotiated
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.contractNumber,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContractDialog(order),
                  icon: const Icon(LucideIcons.file_text, size: 14),
                  label: const Text(
                    'Lihat Kontrak',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactSellerWithContract(order),
                  icon: const Icon(Icons.chat_rounded, size: 14),
                  label: const Text(
                    'Hubungi Penjual',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: _loadAll,
          child: Text('$_error. Coba lagi'),
        ),
      );
    }
    if (_favoriteProducts.isEmpty) {
      return const Center(child: Text('Belum ada produk favorit'));
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
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
              if (mounted) _loadAll();
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
