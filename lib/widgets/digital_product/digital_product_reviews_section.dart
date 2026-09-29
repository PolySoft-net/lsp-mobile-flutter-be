import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../utils/date_format_helper.dart';
import '../../utils/upload_file_validator.dart';
import 'digital_product_image_viewer.dart';

class DigitalProductReviewsSection extends StatelessWidget {
  final String productId;
  final bool isOwner;
  final DigitalProductReviewsData? reviewsData;
  final bool isLoading;
  final VoidCallback? onReviewSubmitted;

  const DigitalProductReviewsSection({
    super.key,
    required this.productId,
    required this.isOwner,
    this.reviewsData,
    this.isLoading = false,
    this.onReviewSubmitted,
  });

  void _openReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                          avgRating > 0
                              ? avgRating.toStringAsFixed(1)
                              : '0.0',
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
          else
            ...reviews.map((review) => _buildReviewItem(context, review)),
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

class DigitalProductReviewSheet extends StatefulWidget {
  final String productId;
  final VoidCallback? onSuccess;

  const DigitalProductReviewSheet({
    super.key,
    required this.productId,
    this.onSuccess,
  });

  @override
  State<DigitalProductReviewSheet> createState() =>
      _DigitalProductReviewSheetState();
}

class _DigitalProductReviewSheetState extends State<DigitalProductReviewSheet> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _isSubmitting = false;

  static const _ratingLabels = {
    1: 'Sangat Buruk',
    2: 'Buruk',
    3: 'Cukup',
    4: 'Bagus',
    5: 'Sangat Bagus!',
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 5 - _selectedFiles.length;
    if (remaining <= 0) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (!mounted || result.isEmpty) return;

    final validFiles = await UploadFileValidator.filterValid(
      messenger,
      result.where((f) => f.path != null),
      50, // backend allows max 50MB per file
    );

    if (!mounted || validFiles.isEmpty) return;

    setState(() {
      _selectedFiles = [
        ..._selectedFiles,
        ...validFiles.take(remaining),
      ];
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating bintang 1 hingga 5.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await DigitalProductService.submitReview(
        widget.productId,
        rating: _rating,
        comment: _commentController.text.trim(),
        imagePaths: _selectedFiles
            .map((f) => f.path ?? '')
            .where((p) => p.isNotEmpty)
            .toList(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Ulasan Anda berhasil dikirim.'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
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

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tulis Ulasan Produk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Star Rating Picker
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = starValue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starValue <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 38,
                            color: starValue <= _rating
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _ratingLabels[_rating] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Comment Field
            const Text(
              'Komentar (Opsional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Bagikan pengalaman Anda mengenai kualitas produk atau jasa ini...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Photos Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foto Produk (Maks 5 Foto)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                Text(
                  '${_selectedFiles.length}/5',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: file.path != null
                            ? Image.file(
                                File(file.path!),
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 62,
                                height: 62,
                                color: const Color(0xFFE2E8F0),
                              ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_selectedFiles.length < 5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
