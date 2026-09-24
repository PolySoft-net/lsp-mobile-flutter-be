import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/digital_product_service.dart';
import '../../utils/upload_file_validator.dart';

class DigitalProductMediaUploadScreen extends StatefulWidget {
  final String productType;
  final String productName;
  final int schemeId;
  final String category;
  final String serviceType;
  final String description;
  final int price;
  final bool negotiable;

  const DigitalProductMediaUploadScreen({
    super.key,
    this.productType = 'Produk',
    this.productName = '',
    required this.schemeId,
    required this.category,
    required this.serviceType,
    required this.description,
    required this.price,
    required this.negotiable,
  });

  @override
  State<DigitalProductMediaUploadScreen> createState() =>
      _DigitalProductMediaUploadScreenState();
}

class _DigitalProductMediaUploadScreenState
    extends State<DigitalProductMediaUploadScreen> {
  List<PlatformFile> _portfolioFiles = const [];
  List<PlatformFile> _productFiles = const [];
  bool _publishing = false;

  Future<void> _pickFiles({required bool portfolio}) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: portfolio
          ? const ['jpg', 'jpeg', 'png', 'webp', 'pdf']
          : const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted || result.isEmpty) {
      return;
    }
    final files = await UploadFileValidator.filterValid(
      messenger,
      result.where((file) => file.path != null),
      UploadFileValidator.digitalProductMaxMB,
    );
    if (!mounted || files.isEmpty) {
      return;
    }
    setState(() {
      if (portfolio) {
        _portfolioFiles = [..._portfolioFiles, ...files];
      } else {
        _productFiles = [..._productFiles, ...files];
      }
    });
  }

  void _onPublishPressed() {
    if (_productFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal satu foto produk wajib dipilih'),
        ),
      );
      return;
    }
    _showConfirmationBottomSheet();
  }

  void _showConfirmationBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Paper Plane Graphic
                _buildPaperPlaneGraphic(),
                const SizedBox(height: 18),

                // Title
                const Text(
                  'Siap Dipublikasikan',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),

                // Subtitle
                const Text(
                  'Produk/Jasa Anda akan ditampilkan',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons: Batal & Kirim
                Row(
                  children: [
                    // Batal
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF64748B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Kirim
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                            _executePublish();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF93C5FD),
                            foregroundColor: const Color(0xFF1E3A8A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Kirim',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executePublish() async {
    setState(() => _publishing = true);
    try {
      await DigitalProductService.createProduct(
        schemeId: widget.schemeId,
        productType: widget.productType,
        category: widget.category,
        serviceType: widget.serviceType,
        title: widget.productName,
        description: widget.description,
        price: widget.price,
        negotiable: widget.negotiable,
        productFiles: _productFiles.map((file) => file.path!).toList(),
        portfolioFiles: _portfolioFiles.map((file) => file.path!).toList(),
      );

      if (!mounted) return;
      _showSuccessBottomSheet();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publikasi gagal. Periksa data dan koneksi Anda.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (successContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Right Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                    onPressed: () {
                      Navigator.pop(successContext);
                      _navigateBackToDashboard();
                    },
                  ),
                ),

                // Green Outline Checkmark Circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4ADE80),
                      width: 3.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 46,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  'Publikasi Berhasil',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),

                // Subtitle
                const Text(
                  'Produk/Jasa Anda akan ditampilkan',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateBackToDashboard() {
    var popped = 0;
    Navigator.of(context).popUntil((route) => popped++ >= 3 || route.isFirst);
  }

  Widget _buildPaperPlaneGraphic() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 0.12,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.near_me_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 50,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buat ${widget.productType}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Section 1: Tambahkan Fortofolio
                  _sectionHeader(
                    title: 'Tambahkan Fortofolio',
                    subtitle:
                        'Unggah hasil kerja atau contoh proyek untuk mendukung pemasaran produk/jasa.',
                  ),
                  const SizedBox(height: 10),
                  _buildDashedUploadBox(
                    onTap: () => _pickFiles(portfolio: true),
                  ),
                  const SizedBox(height: 6),
                  _helperCaption('Pilih foto atau dokumen pendukung minimal 10gb'),

                  // Daftar Fortofolio Preview
                  if (_portfolioFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildPreviewCard(
                      title: 'Daftar Fortofolio',
                      files: _portfolioFiles,
                      onRemove: (index) =>
                          setState(() => _portfolioFiles.removeAt(index)),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Section 2: Foto Produk
                  _sectionHeader(
                    title: 'Foto ${widget.productType}',
                    subtitle: '',
                  ),
                  const SizedBox(height: 10),
                  _buildDashedUploadBox(
                    onTap: () => _pickFiles(portfolio: false),
                  ),
                  const SizedBox(height: 6),
                  _helperCaption('Pilih foto atau dokumen pendukung minimal 10gb'),

                  // Daftar Foto Produk Preview
                  if (_productFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildPreviewCard(
                      title: 'Daftar Foto ${widget.productType}',
                      files: _productFiles,
                      onRemove: (index) =>
                          setState(() => _productFiles.removeAt(index)),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom "Publis" Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _publishing ? null : _onPublishPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF93C5FD),
                    foregroundColor: const Color(0xFF1E3A8A),
                    disabledBackgroundColor:
                        const Color(0xFF93C5FD).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _publishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1E3A8A),
                            ),
                          ),
                        )
                      : const Text(
                          'Publis',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDashedUploadBox({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFF94A3B8),
          strokeWidth: 1.2,
          dashWidth: 6.0,
          dashSpace: 5.0,
          borderRadius: 8.0,
        ),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Picture frame icon
              const Icon(
                Icons.image_outlined,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 8),

              // [ ☁ Unggah ] Pill Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 6.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: Color(0xFF1E293B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Unggah',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
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

  Widget _helperCaption(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required List<PlatformFile> files,
    required ValueChanged<int> onRemove,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: files.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = files[index];
                final isImage = _isImageFile(file.name);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 110,
                        height: 84,
                        color: const Color(0xFFF1F5F9),
                        child: isImage && file.path != null
                            ? Image.file(
                                File(file.path!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _filePlaceholder(file.name),
                              )
                            : _filePlaceholder(file.name),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filePlaceholder(String fileName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.insert_drive_file_outlined,
          size: 26,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF475569)),
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp';
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    this.color = const Color(0xFF94A3B8),
    this.strokeWidth = 1.2,
    this.dashWidth = 6.0,
    this.dashSpace = 5.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}
