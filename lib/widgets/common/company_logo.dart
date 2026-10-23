import 'package:material_ui/material_ui.dart';

import '../../utils/url_helper.dart';

/// Logo perusahaan asli dari URL hasil upload.
///
/// Tidak pernah menggambar logo buatan: URL kosong, sedang dimuat, atau gagal
/// dimuat hanya menampilkan ikon status netral.
class CompanyLogo extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const CompanyLogo({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = UrlHelper.resolveUrl(imageUrl);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: url.isEmpty
          ? _placeholder()
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _placeholder(),
            ),
    );
  }

  Widget _placeholder() => Icon(
    Icons.image_not_supported_outlined,
    size: size * 0.5,
    color: const Color(0xFF94A3B8),
  );
}
