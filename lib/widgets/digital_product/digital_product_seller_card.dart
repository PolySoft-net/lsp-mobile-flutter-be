import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';

class DigitalProductSellerCard extends StatelessWidget {
  final DigitalProductItem item;
  final int orderCount;
  final VoidCallback? onViewOrders;
  final VoidCallback? onManageProduct;

  const DigitalProductSellerCard({
    super.key,
    required this.item,
    required this.orderCount,
    this.onViewOrders,
    this.onManageProduct,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = item.publicationStatus.toLowerCase() == 'published';

    return Container(
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
          // Thumbnail with publication status badge
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          DigitalProductService.absoluteUrl(item.thumbnailUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(
                              LucideIcons.image,
                              size: 28,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            LucideIcons.image,
                            size: 28,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (isPublished
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEA580C))
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPublished ? 'Published' : 'Draft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.priceUnit.isNotEmpty
                      ? '${item.price}${item.priceUnit}'
                      : item.price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),

                // Order Count Indicator & Action
                if (orderCount > 0)
                  InkWell(
                    onTap: onViewOrders,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.shopping_bag,
                            size: 13,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$orderCount Pesanan Masuk',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Belum ada pesanan',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Button Lihat Detail / Edit
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: OutlinedButton(
                    onPressed: onManageProduct,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Kelola Produk',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
