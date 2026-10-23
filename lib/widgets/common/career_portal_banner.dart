import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/url_helper.dart';

class CareerPortalBanner extends StatefulWidget {
  final bool isMagang;
  final VoidCallback? onSeeMore;

  const CareerPortalBanner({
    super.key,
    this.isMagang = false,
    this.onSeeMore,
  });

  @override
  State<CareerPortalBanner> createState() => _CareerPortalBannerState();
}

class _CareerPortalBannerState extends State<CareerPortalBanner> {
  String _imageUrl = '';
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  bool get _canManage =>
      AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = widget.isMagang
          ? await MagangHubService.getBanner()
          : await CareerExpoService.getBanner();
      if (!mounted) return;
      setState(() => _imageUrl = url);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Banner gagal dimuat.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upload() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      if (!mounted || file == null) return;
      final path = file.path;
      if (path == null || path.isEmpty) {
        throw StateError('File gambar tidak dapat dibaca.');
      }
      final uploaded = widget.isMagang
          ? await MagangHubService.uploadFile(path)
          : await CareerExpoService.uploadFile(path);
      if (!mounted) return;
      final url = uploaded['file_url'] ?? '';
      if (url.isEmpty) throw StateError('Upload gambar tidak menghasilkan URL.');
      final saved = widget.isMagang
          ? await MagangHubService.updateBanner(url)
          : await CareerExpoService.updateBanner(url);
      if (!mounted) return;
      setState(() {
        _imageUrl = saved;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner berhasil diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is DioException
          ? error.response?.data is Map
              ? (error.response?.data['message'] ?? error.response?.data['errors'])?.toString()
              : null
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Gagal mengunggah banner. Gunakan gambar JPG atau PNG maksimal 10 MB.')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (_imageUrl.isEmpty && _error == null && !_canManage) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Row(
              children: [
                Expanded(child: Text(_error!)),
                TextButton(onPressed: _load, child: const Text('Muat ulang')),
              ],
            ),
          if (_imageUrl.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isMagang ? 'Magang Hub' : 'Siap Naik Level Karir\ndi Dunia Digital?',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.isMagang
                              ? 'Temukan kesempatan magang terbaik untuk membangun karirmu.'
                              : 'Dapatkan Pekerjaan Sesuai Dengan Kompetensimu.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        TextButton(
                          onPressed: widget.onSeeMore,
                          child: const Text('Lihat Lebih'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Image.network(
                          UrlHelper.resolveUrl(_imageUrl),
                          fit: BoxFit.cover,
                          semanticLabel: widget.isMagang ? 'Banner Magang Hub' : 'Banner Career Expo',
                          loadingBuilder: (context, child, progress) => progress == null
                              ? child
                              : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text('Gambar gagal dimuat', textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_canManage)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _uploading || _loading ? null : _upload,
                icon: _uploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_rounded),
                label: Text(_uploading ? 'Mengunggah...' : _imageUrl.isEmpty ? 'Upload banner asli' : 'Ganti gambar banner'),
              ),
            ),
        ],
      ),
    );
  }
}
