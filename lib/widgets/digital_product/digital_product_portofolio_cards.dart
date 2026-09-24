import 'dart:math';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import 'digital_product_image_viewer.dart';
import 'interactive_favorite_button.dart';

class PortofolioHighlightCard extends StatelessWidget {
  final String? sellerName;
  final String? description;
  final List<String>? tags;
  final List<DigitalProductMedia>? media;
  final String? fallbackThumbnailUrl;
  final EdgeInsetsGeometry margin;

  const PortofolioHighlightCard({
    super.key,
    this.sellerName,
    this.description,
    this.tags,
    this.media,
    this.fallbackThumbnailUrl,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final authorName = sellerName?.trim() ?? '';
    final descText = description?.trim() ?? '';
    final tagList = tags ?? const <String>[];

    // Filter media URL dari server
    final List<String> imageUrls = [];
    if (media != null) {
      for (final m in media!) {
        final url = m.url.trim();
        if (url.isNotEmpty &&
            !url.toLowerCase().endsWith('.pdf') &&
            !imageUrls.contains(url)) {
          imageUrls.add(url);
        }
      }
    }
    if (imageUrls.isEmpty &&
        fallbackThumbnailUrl != null &&
        fallbackThumbnailUrl!.trim().isNotEmpty) {
      imageUrls.add(fallbackThumbnailUrl!.trim());
    }

    // Jika tidak ada data sama sekali dari server, jangan tampilkan card kosong
    final hasImages = imageUrls.isNotEmpty;
    final hasDesc = descText.isNotEmpty;
    final hasTags = tagList.isNotEmpty;
    final hasAuthor = authorName.isNotEmpty;

    if (!hasImages && !hasDesc && !hasTags && !hasAuthor) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12.0),
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
          // Author / Creator Row (hanya jika ada dari server)
          if (hasAuthor) ...[
            Row(
              children: [
                const Icon(
                  LucideIcons.circle_user_round,
                  size: 20,
                  color: Color(0xFF334155),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Showcase Images (Hanya jika benar-benar ada gambar dari server)
          if (hasImages) ...[
            _buildShowcaseImages(imageUrls),
            const SizedBox(height: 10),
          ],

          // Deskripsi (Hanya jika ada dari server)
          if (hasDesc) ...[
            const Text(
              'Deskripsi :',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              descText,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Kategori (Hanya jika ada dari server)
          if (hasTags) ...[
            const Text(
              'Kategori :',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tagList.map((tag) => _CategoryTag(tag: tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowcaseImages(List<String> imageUrls) {
    if (imageUrls.length == 1) {
      final url = DigitalProductService.absoluteUrl(imageUrls[0]);
      return Builder(
        builder: (ctx) => InkWell(
          onTap: () => DigitalProductImageViewer.show(ctx, imageUrl: url),
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFF1F5F9),
                  child: Center(
                    child: Icon(
                      LucideIcons.image,
                      size: 28,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Jika 2 gambar atau lebih
    final dotCount = min(imageUrls.length, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final url = DigitalProductService.absoluteUrl(imageUrls[index]);
              return InkWell(
                onTap: () =>
                    DigitalProductImageViewer.show(context, imageUrl: url),
                borderRadius: BorderRadius.circular(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Color(0xFFF1F5F9),
                        child: Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 24,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: Row(
                children: List.generate(dotCount, (index) {
                  return Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String tag;

  const _CategoryTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFDFEDFA),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }
}

class PortofolioLainnyaCard extends StatefulWidget {
  final String title;
  final String price;
  final String type;
  final bool isFavorite;
  final String? thumbnailUrl;
  final String? secondImageUrl;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteTap;
  final EdgeInsetsGeometry? margin;

  const PortofolioLainnyaCard({
    super.key,
    required this.title,
    this.price = '',
    this.type = '',
    this.isFavorite = false,
    this.thumbnailUrl,
    this.secondImageUrl,
    this.onTap,
    this.onFavoriteTap,
    this.margin,
  });

  @override
  State<PortofolioLainnyaCard> createState() => _PortofolioLainnyaCardState();
}

class _PortofolioLainnyaCardState extends State<PortofolioLainnyaCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant PortofolioLainnyaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasThumb = widget.thumbnailUrl != null &&
        widget.thumbnailUrl!.trim().isNotEmpty;
    final hasSecond = widget.secondImageUrl != null &&
        widget.secondImageUrl!.trim().isNotEmpty;

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(10.0),
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
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // Preview images (hanya render jika ada dari server)
            if (hasThumb || hasSecond) ...[
              if (hasThumb && hasSecond)
                Row(
                  children: [
                    Expanded(child: _buildImageItem(widget.thumbnailUrl!)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildImageItem(widget.secondImageUrl!)),
                  ],
                )
              else if (hasThumb)
                _buildImageItem(widget.thumbnailUrl!, width: double.infinity),
              const SizedBox(height: 8),
            ],

            // Info bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (widget.price.isNotEmpty || widget.type.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${widget.price}  ${widget.type}'.trim(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                InteractiveFavoriteButton(
                  initialIsFavorite: _isFavorite,
                  size: 18,
                  onFavoriteChanged: (isFav) {
                    setState(() => _isFavorite = isFav);
                    widget.onFavoriteTap?.call(isFav);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String url, {double? width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: 92,
        child: Image.network(
          DigitalProductService.absoluteUrl(url),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Color(0xFFF1F5F9),
            child: Center(
              child: Icon(LucideIcons.image, size: 24, color: Color(0xFF94A3B8)),
            ),
          ),
        ),
      ),
    );
  }
}
