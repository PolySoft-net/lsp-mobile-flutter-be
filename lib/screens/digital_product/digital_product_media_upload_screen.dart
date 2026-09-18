import 'dart:ui';
import 'package:material_ui/material_ui.dart';

class DigitalProductMediaUploadScreen extends StatefulWidget {
  final String productType;
  final String productName;

  const DigitalProductMediaUploadScreen({
    super.key,
    this.productType = 'Produk',
    this.productName = '',
  });

  @override
  State<DigitalProductMediaUploadScreen> createState() =>
      _DigitalProductMediaUploadScreenState();
}

class _DigitalProductMediaUploadScreenState
    extends State<DigitalProductMediaUploadScreen> {
  @override
  Widget build(BuildContext context) {
    final title = 'Buat ${widget.productType}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: "< Buat Produk"
            _buildAppBar(context, title),

            // Scrollable Upload Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Tambahkan Fortofolio
                    const Text(
                      'Tambahkan Fortofolio',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Unggah hasil kerja atau contoh proyek untuk mendukung pemasaran produk/jasa.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Dashed Dropzone 1
                    _buildDashedUploadBox(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih foto/dokumen portofolio'),
                            duration: Duration(milliseconds: 700),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih foto atau dokumen pendukung minimal 10gb',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Section 2: Daftar Fortofolio
                    const Text(
                      'Daftar Fortofolio',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPortfolioPreviewRow(),

                    const SizedBox(height: 16),

                    // Section 3: Foto Produk
                    Text(
                      'Foto ${widget.productType}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Dashed Dropzone 2
                    _buildDashedUploadBox(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pilih foto ${widget.productType}'),
                            duration: const Duration(milliseconds: 700),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih foto atau dokumen pendukung minimal 10gb',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Section 4: Daftar Foto Produk
                    Text(
                      'Daftar Foto ${widget.productType}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProductPhotoPreviewRow(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom "Publis" Button
            _buildPublisButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
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
            children: [
              const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
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

  Widget _buildDashedUploadBox({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: const Color(0xFF94A3B8),
          strokeWidth: 1.2,
          gap: 5.0,
        ),
        child: Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                size: 44,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 15,
                      color: Color(0xFF0F172A),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Unggah',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioPreviewRow() {
    return Row(
      children: [
        // Portfolio Thumbnail 1: Retro Art / Web
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 32,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCD34D),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 28,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 60,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93C5FD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.web,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Portfolio Thumbnail 2: Typographic Portofolio Card
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'portofolio',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'DESIGN • PROTOTYPE',
                      style: TextStyle(
                        fontSize: 6.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductPhotoPreviewRow() {
    return Row(
      children: [
        // Photo 1: Collaboration / Team
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.diversity_3_outlined,
                      size: 26,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'TEAM & TECH',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A8A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Photo 2: IoT Doodle Banner
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFA5C0DC),
                borderRadius: BorderRadius.circular(6),
              ),
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
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '• OF •',
                        style: TextStyle(
                          fontSize: 6.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        'THINGS',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublisButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.productType} "${widget.productName.isNotEmpty ? widget.productName : 'Baru'}" berhasil dipublikasikan!',
                ),
                duration: const Duration(seconds: 2),
              ),
            );

            // Pop back to the Produk/Jasa list screen
            int count = 0;
            Navigator.of(context).popUntil((route) {
              return count++ >= 3 || route.isFirst;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5E7EB),
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Publis',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    final Path dashPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = gap;
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

