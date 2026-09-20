import 'package:material_ui/material_ui.dart';
import '../../models/digital_product_models.dart';
import 'interactive_favorite_button.dart';

class DigitalProductCard extends StatelessWidget {
  final DigitalProductItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final ValueChanged<bool>? onFavoriteChanged;

  const DigitalProductCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteTap,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
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
          // Thumbnail Image
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: _buildThumbnail(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Heart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InteractiveFavoriteButton(
                      initialIsFavorite: item.isFavorite,
                      size: 18,
                      onFavoriteChanged: (isFav) {
                        onFavoriteChanged?.call(isFav);
                        onFavoriteTap?.call();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Harga
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    children: [
                      const TextSpan(text: 'Harga : '),
                      TextSpan(
                        text: item.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      TextSpan(text: item.priceUnit),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // By
                Text(
                  'By : ${item.author}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),

                // Status
                Text(
                  'Status :  ${item.status}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Divider
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFE2E8F0),
          ),

          // "Lihat" Action Button
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: const SizedBox(
              width: double.infinity,
              height: 30,
              child: Center(
                child: Text(
                  'Lihat',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.thumbnailType == 'ecom') {
      return Container(
        color: const Color(0xFFFFFBEB),
        child: Row(
          children: [
            // Dark sidebar
            Container(
              width: 28,
              color: const Color(0xFF332D42),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE68A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 18, height: 2, color: Colors.white24),
                  const SizedBox(height: 4),
                  Container(width: 18, height: 2, color: Colors.white24),
                  const SizedBox(height: 4),
                  Container(width: 18, height: 2, color: Colors.white24),
                ],
              ),
            ),
            // Dashboard panels
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top banner card
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB7185),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Stat cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFECDD3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED7AA),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Bottom card
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(3),
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

    // Default: IoT sketch thumbnail
    return Container(
      color: const Color(0xFFA5C0DC),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            left: 6,
            child: Icon(
              Icons.visibility_outlined,
              size: 11,
              color: const Color(0xFF1E293B).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            top: 4,
            right: 6,
            child: Icon(
              Icons.cloud_outlined,
              size: 11,
              color: const Color(0xFF1E293B).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 6,
            child: Icon(
              Icons.laptop_chromebook_rounded,
              size: 11,
              color: const Color(0xFF1E293B).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 6,
            child: Icon(
              Icons.build_outlined,
              size: 11,
              color: const Color(0xFF1E293B).withValues(alpha: 0.35),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'INTERNET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '• OF •',
                style: TextStyle(
                  fontSize: 7,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                'THINGS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

