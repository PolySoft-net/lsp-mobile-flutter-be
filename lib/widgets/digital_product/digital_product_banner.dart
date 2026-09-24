import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';

class DigitalProductBanner extends StatelessWidget {
  final List<DigitalProductItem> products;
  final ValueChanged<DigitalProductItem>? onProductTap;
  final VoidCallback? onTap;

  const DigitalProductBanner({
    super.key,
    this.products = const [],
    this.onProductTap,
    this.onTap,
  });

  static const List<DigitalProductItem> _fallbackProducts = [
    DigitalProductItem(
      id: 'mock_1',
      title: 'Promosi Jasa Content Creator',
      schemeName: 'Content Creator',
      category: 'Jasa',
      serviceType: 'Online',
    ),
    DigitalProductItem(
      id: 'mock_2',
      title: 'Template Desain Website Online',
      schemeName: 'Web Developer',
      category: 'Produk',
      serviceType: 'Online',
    ),
  ];

  List<DigitalProductItem> get _effectiveItems {
    if (products.isEmpty) {
      return _fallbackProducts;
    }
    if (products.length == 1) {
      return [products.first, _fallbackProducts[1]];
    }
    return products.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE0EDFB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header: Title with Flame Emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 6),
                Text(
                  'Produk Yang Paling Sering Dibeli',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2552),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Pilihan favorit pelanggan selalu menjadi yang teratas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5E7395),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal Products List
            SizedBox(
              height: 134,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                itemCount: _effectiveItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _effectiveItems[index];
                  return _buildProductCard(context, item, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    DigitalProductItem item,
    int index,
  ) {
    return Container(
      width: 295,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!item.id.startsWith('mock_') && onProductTap != null) {
              onProductTap!(item);
            } else if (onTap != null) {
              onTap!();
            } else if (onProductTap != null && products.isNotEmpty) {
              onProductTap!(products.first);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 96,
                    height: 114,
                    child: _buildThumbnail(item, index),
                  ),
                ),
                const SizedBox(width: 12),

                // Right Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge: "🔥 Paling Laris"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E60E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('🔥', style: TextStyle(fontSize: 10)),
                            SizedBox(width: 3),
                            Text(
                              'Paling Laris',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Skema Sertifikasi
                      Text(
                        'Skema Sertifikasi : ${item.displayScheme}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),

                      const Spacer(),

                      // "Lihat Produk →" Pill Button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF90C2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Lihat Produk',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '→',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(DigitalProductItem item, int index) {
    if (item.thumbnailUrl.isNotEmpty) {
      return Image.network(
        DigitalProductService.absoluteUrl(item.thumbnailUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildGraphicPlaceholder(index),
      );
    }
    return _buildGraphicPlaceholder(index);
  }

  Widget _buildGraphicPlaceholder(int index) {
    if (index % 2 == 0) {
      return _buildCreatorCardThumbnail();
    } else {
      return _buildDesignCardThumbnail();
    }
  }

  Widget _buildCreatorCardThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
      ),
      child: Stack(
        children: [
          // Sparkle accent
          Positioned(
            top: 6,
            left: 6,
            child: Icon(
              Icons.auto_awesome,
              size: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          // Bell accent
          Positioned(
            top: 8,
            right: 22,
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 12,
              color: Color(0xFFFDE047),
            ),
          ),
          // Tiny badge: "WE'RE OPEN"
          Positioned(
            top: 18,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "WE'RE OPEN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          // Smartphone outline
          Positioned(
            right: 4,
            top: 14,
            bottom: 4,
            width: 44,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Container(
                    height: 3,
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.photo_camera_front_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const Spacer(),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Center(
                      child: Text(
                        'POST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Laptop / Creator icon
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.laptop_mac_rounded,
                size: 15,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignCardThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5), Color(0xFFFED7AA)],
        ),
      ),
      child: Stack(
        children: [
          // Star doodle
          Positioned(
            top: 6,
            left: 6,
            child: const Text(
              '✳',
              style: TextStyle(
                color: Color(0xFFFB7185),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // "BRAND DESIGN"
          Positioned(
            top: 8,
            left: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'BRAND',
                  style: TextStyle(
                    color: Color(0xFFC2410C),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                Text(
                  'DESIGN',
                  style: TextStyle(
                    color: Color(0xFFEA580C),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Avatar circle with brush
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFDBA74),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.palette_rounded,
                size: 15,
                color: Color(0xFF9A3412),
              ),
            ),
          ),
          // Mini Web layout cards
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7AA),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(
                      Icons.web,
                      size: 11,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 3,
                          width: double.infinity,
                          color: const Color(0xFFFDBA74),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 2,
                          width: 24,
                          color: const Color(0xFFFED7AA),
                        ),
                      ],
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
}
