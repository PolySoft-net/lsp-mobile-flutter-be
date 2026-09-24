import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/digital_product_models.dart';
import '../../widgets/digital_product/digital_product_portofolio_cards.dart';

class DigitalProductPortofolioScreen extends StatelessWidget {
  final List<DigitalProductMedia> media;
  final String sellerName;
  final String sellerPhone;
  final DigitalProductItem? product;

  const DigitalProductPortofolioScreen({
    super.key,
    this.media = const [],
    this.sellerName = '',
    this.sellerPhone = '',
    this.product,
  });

  Future<void> _contactSeller(BuildContext context) async {
    final phone = (sellerPhone.trim().isNotEmpty
            ? sellerPhone
            : (product?.sellerPhone ?? ''))
        .trim();
    if (phone.isEmpty || !await launchUrl(Uri(scheme: 'tel', path: phone))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor penjual belum tersedia')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSellerName = sellerName.trim().isNotEmpty
        ? sellerName.trim()
        : (product?.sellerName.trim().isNotEmpty == true
            ? product!.sellerName.trim()
            : 'Jendela_Website');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Portofolio Produk'),
                    const SizedBox(height: 10),
                    PortofolioHighlightCard(
                      sellerName: resolvedSellerName,
                      description: product?.description,
                      tags: (product != null && product!.tags.isNotEmpty)
                          ? product!.tags
                          : null,
                      media: media,
                    ),
                    const SizedBox(height: 14),
                    _buildContactSellerButton(context),
                    const SizedBox(height: 18),
                    _buildSectionHeader('Portofolio Produk Lainnya :'),
                    const SizedBox(height: 10),
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

  Widget _buildContactSellerButton(BuildContext context) {
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
        onTap: () => _contactSeller(context),
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
