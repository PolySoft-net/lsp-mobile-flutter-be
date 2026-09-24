import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_portofolio_cards.dart';
import 'digital_product_detail_screen.dart';

class DigitalProductPortofolioScreen extends StatefulWidget {
  final List<DigitalProductMedia> media;
  final String sellerName;
  final String sellerPhone;
  final DigitalProductItem? product;
  final DigitalProductDetail? detail;

  const DigitalProductPortofolioScreen({
    super.key,
    this.media = const [],
    this.sellerName = '',
    this.sellerPhone = '',
    this.product,
    this.detail,
  });

  @override
  State<DigitalProductPortofolioScreen> createState() =>
      _DigitalProductPortofolioScreenState();
}

class _DigitalProductPortofolioScreenState
    extends State<DigitalProductPortofolioScreen> {
  DigitalProductDetail? _detail;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _detail = widget.detail;
    if (_detail == null &&
        widget.product != null &&
        widget.product!.id.isNotEmpty) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    if (widget.product == null || widget.product!.id.isEmpty) return;
    setState(() => _loading = true);
    try {
      final detail = await DigitalProductService.getDetail(widget.product!.id);
      if (mounted) {
        setState(() => _detail = detail);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _contactSeller(BuildContext context, String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty || !await launchUrl(Uri(scheme: 'tel', path: cleaned))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor penjual belum tersedia')),
        );
      }
    }
  }

  static String _titleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSellerName = (_detail?.seller.name.trim().isNotEmpty == true)
        ? _detail!.seller.name.trim()
        : (widget.sellerName.trim().isNotEmpty
            ? widget.sellerName.trim()
            : (widget.product?.sellerName.trim().isNotEmpty == true
                ? widget.product!.sellerName.trim()
                : 'Jendela_Website'));

    final resolvedPhone = (_detail?.seller.phone.trim().isNotEmpty == true)
        ? _detail!.seller.phone.trim()
        : (widget.sellerPhone.trim().isNotEmpty
            ? widget.sellerPhone.trim()
            : (widget.product?.sellerPhone.trim().isNotEmpty == true
                ? widget.product!.sellerPhone.trim()
                : ''));

    final resolvedDescription =
        (_detail?.product.description.trim().isNotEmpty == true)
            ? _detail!.product.description.trim()
            : (widget.product?.description.trim().isNotEmpty == true
                ? widget.product!.description.trim()
                : 'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekiter 2 bulan dan secara online atau dering...');

    final resolvedTags = (_detail != null && _detail!.product.tags.isNotEmpty)
        ? _detail!.product.tags
        : (widget.product != null && widget.product!.tags.isNotEmpty
            ? widget.product!.tags
            : const ['#Software', '#Template', '#Website', '#Design']);

    final resolvedMedia = (_detail != null && _detail!.media.isNotEmpty)
        ? _detail!.media
        : widget.media;

    final fallbackThumb = _detail?.product.thumbnailUrl.isNotEmpty == true
        ? _detail!.product.thumbnailUrl
        : (widget.product?.thumbnailUrl ?? '');

    final sellerProducts =
        _detail?.sellerProducts ?? const <DigitalProductItem>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _loading && _detail == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadDetail,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Portofolio Produk'),
                            const SizedBox(height: 10),
                            PortofolioHighlightCard(
                              sellerName: resolvedSellerName,
                              description: resolvedDescription,
                              tags: resolvedTags,
                              media: resolvedMedia,
                              fallbackThumbnailUrl: fallbackThumb,
                            ),
                            const SizedBox(height: 14),
                            _buildContactSellerButton(context, resolvedPhone),
                            const SizedBox(height: 18),
                            _buildSectionHeader('Portofolio Produk Lainnya :'),
                            const SizedBox(height: 10),
                            if (sellerProducts.isNotEmpty)
                              ...sellerProducts.map((item) {
                                final typeText = item.serviceType.isNotEmpty
                                    ? '/${_titleCase(item.serviceType)}'
                                    : '/Online';
                                return PortofolioLainnyaCard(
                                  title: item.title,
                                  price: item.price,
                                  type: typeText,
                                  isFavorite: item.isFavorite,
                                  thumbnailUrl: item.thumbnailUrl,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DigitalProductDetailScreen(item: item),
                                    ),
                                  ),
                                  onFavoriteTap: (fav) async {
                                    try {
                                      await DigitalProductService.setFavorite(
                                        item.id,
                                        fav,
                                      );
                                    } catch (_) {}
                                  },
                                );
                              })
                            else ...[
                              const PortofolioLainnyaCard(
                                title: 'Portofolio Design Aplikasi Motor',
                                price: 'Rp 400.000',
                                type: '/Online',
                                isFavorite: true,
                              ),
                              const PortofolioLainnyaCard(
                                title: 'Portofolio Prototype Aplikasi Motor',
                                price: 'Rp 400.000',
                                type: '/Online',
                                isFavorite: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    LucideIcons.chevron_left,
                    size: 22,
                    color: Color(0xFF0F172A),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Fortofolio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.sliders_horizontal,
              size: 20,
              color: Color(0xFF0F172A),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(
          height: 1,
          thickness: 0.8,
          color: Color(0xFFCBD5E1),
        ),
      ],
    );
  }

  Widget _buildContactSellerButton(BuildContext context, String phone) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _contactSeller(context, phone),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Icon(
                Icons.phone,
                size: 20,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 14),
              Text(
                'Hubungi Penjual',
                style: TextStyle(
                  fontSize: 13.5,
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
