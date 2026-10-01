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

  Future<void> _contactSeller(
    BuildContext context, {
    required String phone,
    required String sellerName,
    required String productTitle,
  }) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor penjual belum tersedia')),
        );
      }
      return;
    }

    var waPhone = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    if (waPhone.startsWith('0')) {
      waPhone = '62${waPhone.substring(1)}';
    }

    final greeting = sellerName.trim().isNotEmpty ? 'Halo $sellerName' : 'Halo';
    final productText =
        productTitle.trim().isNotEmpty ? ' mengenai "$productTitle"' : '';
    final defaultMessage =
        '$greeting, saya tertarik dengan produk/jasa Anda$productText di LSP Digital Mobile. Apakah masih tersedia?';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Hubungi Penjual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nomor Layanan: $cleaned',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactOptionTile(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF22C55E),
                  iconBgColor: const Color(0xFFDCFCE7),
                  title: 'WhatsApp',
                  subtitle: 'Kirim pesan langsung via WhatsApp',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final waUri = Uri.parse(
                      'https://wa.me/$waPhone?text=${Uri.encodeComponent(defaultMessage)}',
                    );
                    if (!await launchUrl(waUri,
                        mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tidak dapat membuka WhatsApp')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                _buildContactOptionTile(
                  icon: Icons.phone_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBgColor: const Color(0xFFDBEAFE),
                  title: 'Panggilan Telepon',
                  subtitle: 'Panggilan suara ke nomor layanan',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final telUri = Uri(scheme: 'tel', path: cleaned);
                    if (!await launchUrl(telUri,
                        mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Tidak dapat melakukan panggilan telepon')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                _buildContactOptionTile(
                  icon: Icons.sms_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFEF3C7),
                  title: 'Kirim SMS',
                  subtitle: 'Kirim pesan teks reguler (SMS)',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final smsUri = Uri(
                      scheme: 'sms',
                      path: cleaned,
                      queryParameters: {'body': defaultMessage},
                    );
                    if (!await launchUrl(smsUri,
                        mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Tidak dapat membuka aplikasi SMS')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Color(0xFF94A3B8),
          size: 13,
        ),
      ),
    );
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
                : ''));

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
                : '');

    final resolvedTags = (_detail != null && _detail!.product.tags.isNotEmpty)
        ? _detail!.product.tags
        : (widget.product != null && widget.product!.tags.isNotEmpty
            ? widget.product!.tags
            : const <String>[]);

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
                            _buildContactSellerButton(
                              context,
                              phone: resolvedPhone,
                              sellerName: resolvedSellerName,
                              productTitle: widget.product?.title ??
                                  _detail?.product.title ??
                                  '',
                            ),

                            // Hanya tampilkan jika sellerProducts benar-benar ada dari server
                            if (sellerProducts.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              _buildSectionHeader('Portofolio Produk Lainnya :'),
                              const SizedBox(height: 10),
                              ...sellerProducts.map((item) {
                                final typeText = item.serviceType.isNotEmpty
                                    ? '/${_titleCase(item.serviceType)}'
                                    : '';
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
                              }),
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

  Widget _buildContactSellerButton(
    BuildContext context, {
    required String phone,
    required String sellerName,
    required String productTitle,
  }) {
    final isPhoneVisible =
        _detail?.product.showPhone ?? widget.product?.showPhone ?? true;
    if (!isPhoneVisible || phone.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
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
        onTap: () => _contactSeller(
          context,
          phone: phone,
          sellerName: sellerName,
          productTitle: productTitle,
        ),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: const [
              Icon(
                Icons.phone_in_talk_rounded,
                size: 20,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hubungi Penjual',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'WhatsApp, Telepon & SMS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
