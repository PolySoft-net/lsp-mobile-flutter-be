import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../utils/date_format_helper.dart';
import 'digital_product_image_viewer.dart';
import 'digital_product_review_sheet.dart';

class DigitalProductReviewsSection extends StatelessWidget {
  final String productId;
  final bool isOwner;
  final DigitalProductReviewsData? reviewsData;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;
  final VoidCallback? onReviewSubmitted;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  const DigitalProductReviewsSection({
    super.key,
    required this.productId,
    required this.isOwner,
    this.reviewsData,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    this.onReviewSubmitted,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  void _openReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DigitalProductReviewSheet(
        productId: productId,
        onSuccess: onReviewSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgRating = reviewsData?.averageRating ?? 0.0;
    final totalCount = reviewsData?.totalReviews ?? 0;
    final reviews = reviewsData?.reviews ?? const <DigitalProductReviewItem>[];
    final canLoadMore = onLoadMore != null && reviews.length < totalCount;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Rating Summary + "Tulis Ulasan" button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ulasan Pembeli',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          avgRating > 0 ? avgRating.toStringAsFixed(1) : '0.0',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($totalCount ulasan)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isOwner)
                OutlinedButton.icon(
                  onPressed: () => _openReviewModal(context),
                  icon: const Icon(
                    LucideIcons.pencil,
                    size: 13,
                    color: Color(0xFF2563EB),
                  ),
                  label: const Text(
                    'Tulis Ulasan',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Content
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          else if (hasError)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gagal memuat ulasan.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    InkWell(
                      onTap: onRetry,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: const [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Belum ada ulasan untuk produk ini.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ...reviews.map((review) => _buildReviewItem(context, review)),
            if (canLoadMore)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: isLoadingMore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: onLoadMore,
                          child: Text(
                            'Tampilkan Ulasan Lainnya (${reviews.length}/$totalCount)',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, DigitalProductReviewItem review) {
    final photoUrl = review.user.photo.trim();
    final userName = review.user.name.trim().isNotEmpty
        ? review.user.name.trim()
        : 'Pengguna';
    final dateText = review.createdAt.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(review.createdAt)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(DigitalProductService.absoluteUrl(photoUrl))
                    : null,
                child: photoUrl.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),

              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (dateText.isNotEmpty)
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),

              // Star Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: index < review.rating
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ),

          // Comment
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment.trim(),
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ],

          // Images gallery
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.images.map((img) {
                final fullUrl = DigitalProductService.absoluteUrl(img);
                return GestureDetector(
                  onTap: () {
                    DigitalProductImageViewer.show(
                      context,
                      imageUrl: fullUrl,
                      title: 'Foto Ulasan',
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      fullUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.6, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}
