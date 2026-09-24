import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/digital_product_models.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/digital_product_service.dart';
import 'digital_product_portofolio_screen.dart';
import '../../widgets/digital_product/digital_product_card.dart';
import '../../widgets/digital_product/interactive_favorite_button.dart';

class DigitalProductDetailScreen extends StatefulWidget {
  final DigitalProductItem item;

  const DigitalProductDetailScreen({super.key, required this.item});

  @override
  State<DigitalProductDetailScreen> createState() =>
      _DigitalProductDetailScreenState();
}

class _DigitalProductDetailScreenState
    extends State<DigitalProductDetailScreen> {
  late bool _isFavorite;
  DigitalProductDetail? _detail;

  DigitalProductItem get _item => _detail?.product ?? widget.item;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await DigitalProductService.getDetail(widget.item.id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isFavorite = detail.product.isFavorite;
        });
      }
    } catch (_) {
      // Initial list item remains usable when detail refresh fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations =
        _detail?.sellerProducts ?? const <DigitalProductItem>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: "< Detail"
            _buildAppBar(context),

            // Scrollable Detail Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Product Card
                    _buildMainProductCard(context),

                    // Portofolio Produk Card
                    _buildPortfolioCard(context),
                    _buildSellerCompetencyCard(),

                    // "Hubungi Penjual" Button Card
                    _buildHubungiPenjualButton(context),

                    // "Rekomendasi Produk Serupa" Section
                    _buildRekomendasiSection(context, recommendations),
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
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 4),
              Text(
                'Detail',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainProductCard(BuildContext context) {
    final tags = _item.tags;
    final description = _item.description.isNotEmpty
        ? _item.description
        : 'Belum ada deskripsi produk.';

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Header Row
          Row(
            children: [
              const Icon(
                LucideIcons.circle_user,
                size: 18,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              Text(
                _item.sellerName.isNotEmpty ? _item.sellerName : _item.author,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Illustration Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: _buildBannerIllustration(),
            ),
          ),
          const SizedBox(height: 12),

          // Title and Favorite Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InteractiveFavoriteButton(
                initialIsFavorite: _isFavorite,
                size: 22,
                onFavoriteChanged: (isFav) async {
                  final previous = _isFavorite;
                  setState(() => _isFavorite = isFav);
                  try {
                    await DigitalProductService.setFavorite(_item.id, isFav);
                  } catch (_) {
                    if (mounted) setState(() => _isFavorite = previous);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Price
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A)),
              children: [
                TextSpan(
                  text: _item.price,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: _item.priceUnit,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // By Author
          Text(
            'By : ${_item.author}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),

          // Skema Sertifikasi
          Text(
            'Skema Sertifikasi : ${_item.displayScheme}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          if (_item.salesCount > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Terjual : ${_item.salesCount} produk',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Kategori
          const Text(
            'Kategori :',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF94A3B8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Deskripsi
          const Text(
            'Deskripsi :',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom pill indicator handle
          Center(
            child: Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerIllustration() {
    if (_item.thumbnailUrl.isNotEmpty) {
      return Image.network(
        DigitalProductService.absoluteUrl(_item.thumbnailUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFE2E8F0),
          child: Icon(Icons.image_not_supported_outlined),
        ),
      );
    }
    if (_item.thumbnailType == 'ecom') {
      return Container(
        color: const Color(0xFFFFF7ED),
        child: Row(
          children: [
            Container(
              width: 40,
              color: const Color(0xFF332D42),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE68A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 24, height: 3, color: Colors.white24),
                  const SizedBox(height: 6),
                  Container(width: 24, height: 3, color: Colors.white24),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB7185),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFECDD3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED7AA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default: IoT Doodle illustration banner
    return Container(
      color: const Color(0xFFA5C0DC),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Doodles & icons in corners
          Positioned(
            top: 10,
            left: 12,
            child: Icon(
              Icons.file_download_outlined,
              size: 20,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: 12,
            right: 14,
            child: Icon(
              Icons.phone_android_rounded,
              size: 18,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            left: 10,
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            right: 12,
            child: Icon(
              Icons.dns_outlined,
              size: 18,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 14,
            child: Icon(
              Icons.laptop_chromebook_rounded,
              size: 18,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 14,
            child: Icon(
              Icons.build_outlined,
              size: 18,
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            ),
          ),

          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'INTERNET',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_left, size: 14, color: Color(0xFF334155)),
                  Text(
                    ' OF ',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Icon(Icons.arrow_right, size: 14, color: Color(0xFF334155)),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'THINGS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context) {
    final media =
        _detail?.media.where((item) => item.type == 'portofolio').toList() ??
        const <DigitalProductMedia>[];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: media.isEmpty
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DigitalProductPortofolioScreen(
                    media: media,
                    sellerName: _item.sellerName,
                    sellerPhone: _item.sellerPhone,
                  ),
                ),
              ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Portofolio Produk',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              if (media.isEmpty)
                const Text(
                  'Belum ada portofolio yang diunggah.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                )
              else
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: media.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final item = media[index];
                      final isPdf = item.fileName.toLowerCase().endsWith(
                        '.pdf',
                      );
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 132,
                          child: isPdf
                              ? const ColoredBox(
                                  color: Color(0xFFF1F5F9),
                                  child: Icon(Icons.picture_as_pdf_outlined),
                                )
                              : Image.network(
                                  DigitalProductService.absoluteUrl(item.url),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const ColoredBox(
                                    color: Color(0xFFF1F5F9),
                                    child: Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCompetencyCard() {
    final certificates =
        _detail?.certificates ?? const <DigitalProductCertificate>[];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kompetensi Penjual',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (certificates.isEmpty)
            const Text(
              'Belum ada data sertifikasi kompetensi.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            )
          else
            ...certificates
                .take(4)
                .map(
                  (certificate) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_outlined, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            certificate.schemeCode.isEmpty
                                ? certificate.schemeName
                                : '${certificate.schemeCode} - ${certificate.schemeName}',
                            style: const TextStyle(fontSize: 11.5),
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

  Widget _buildHubungiPenjualButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final phone = _item.sellerPhone.trim();
          if (phone.isEmpty ||
              !await launchUrl(Uri(scheme: 'tel', path: phone))) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor penjual belum tersedia')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: const [
              Icon(Icons.phone, size: 18, color: Color(0xFF0F172A)),
              SizedBox(width: 12),
              Text(
                'Hubungi Penjual',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRekomendasiSection(
    BuildContext context,
    List<DigitalProductItem> recommendations,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: const [
              Text(
                'Rekomendasi Produk Serupa',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF0F172A),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Grid
          GridView.builder(
            itemCount: recommendations.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              mainAxisExtent: 216.0,
            ),
            itemBuilder: (context, index) {
              final recItem = recommendations[index];
              return DigitalProductCard(
                item: recItem,
                onTap: () async {
                  final targetIndex = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (_) => DigitalProductDetailScreen(item: recItem),
                    ),
                  );
                  if (targetIndex != null && context.mounted) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, targetIndex);
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
