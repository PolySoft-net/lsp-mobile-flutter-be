import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/digital_product_service.dart';

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
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: portfolio
          ? const ['jpg', 'jpeg', 'png', 'webp', 'pdf']
          : const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted || result.isEmpty) return;
    final files = result.where((file) => file.path != null).toList();
    setState(() {
      if (portfolio) {
        _portfolioFiles = [..._portfolioFiles, ...files];
      } else {
        _productFiles = [..._productFiles, ...files];
      }
    });
  }

  Future<void> _publish() async {
    if (_productFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal satu foto produk wajib dipilih')),
      );
      return;
    }
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
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Publikasi Berhasil'),
          content: const Text('Produk/Jasa Anda sudah ditampilkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      var popped = 0;
      Navigator.of(context).popUntil((route) => popped++ >= 3 || route.isFirst);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Buat ${widget.productType}'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _uploadSection(
            title: 'Foto ${widget.productType}',
            subtitle: 'Wajib. JPG, PNG, atau WEBP maksimal 10MB per file.',
            files: _productFiles,
            onAdd: () => _pickFiles(portfolio: false),
            onRemove: (index) => setState(() => _productFiles.removeAt(index)),
          ),
          const SizedBox(height: 16),
          _uploadSection(
            title: 'Portofolio',
            subtitle: 'Opsional. Foto atau PDF maksimal 10MB per file.',
            files: _portfolioFiles,
            onAdd: () => _pickFiles(portfolio: true),
            onRemove: (index) =>
                setState(() => _portfolioFiles.removeAt(index)),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _publishing ? null : _publish,
            child: _publishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publikasikan'),
          ),
        ],
      ),
    );
  }

  Widget _uploadSection({
    required String title,
    required String subtitle,
    required List<PlatformFile> files,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Pilih File'),
          ),
          for (var index = 0; index < files.length; index++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined, size: 20),
              title: Text(
                files[index].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemove(index),
              ),
            ),
        ],
      ),
    );
  }
}
