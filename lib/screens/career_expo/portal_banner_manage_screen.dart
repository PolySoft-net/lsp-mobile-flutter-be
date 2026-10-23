import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/portal_banner_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/url_helper.dart';

class PortalBannerManageScreen extends StatefulWidget {
  final bool isMagang;

  const PortalBannerManageScreen({super.key, this.isMagang = false});

  @override
  State<PortalBannerManageScreen> createState() => _PortalBannerManageScreenState();
}

class _PortalBannerManageScreenState extends State<PortalBannerManageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  PortalBanner _banner = const PortalBanner();
  String _imagePath = '';
  String _durationUnit = 'days';
  bool _loading = true;
  bool _uploading = false;
  bool _saving = false;
  String? _error;

  bool get _isProvider => AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;
  bool get _busy => _loading || _uploading || _saving;

  @override
  void initState() {
    super.initState();
    if (_isProvider) _load();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final banner = widget.isMagang
          ? await MagangHubService.getMyBanner()
          : await CareerExpoService.getMyBanner();
      if (!mounted) return;
      setState(() {
        _banner = banner;
        _imagePath = banner.imageUrl;
        _durationController.text = banner.durationValue > 0 ? '${banner.durationValue}' : '';
        _durationUnit = const ['hours', 'days', 'months'].contains(banner.durationUnit)
            ? banner.durationUnit
            : 'days';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat banner milik Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error, String fallback) {
    String? message;
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      message = (data['message'] ?? data['errors'])?.toString();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? fallback)));
  }

  Future<void> _pickImage() async {
    if (_busy) return;
    setState(() => _uploading = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      if (!mounted || file == null) return;
      final path = file.path;
      if (path == null || path.isEmpty) throw StateError('File tidak dapat dibaca.');
      final uploaded = widget.isMagang
          ? await MagangHubService.uploadFile(path)
          : await CareerExpoService.uploadFile(path);
      if (!mounted) return;
      final imagePath = Uri.parse(uploaded['file_url'] ?? '').path;
      if (imagePath.isEmpty) throw StateError('URL gambar kosong.');
      setState(() => _imagePath = imagePath);
    } catch (error) {
      if (mounted) _showError(error, 'Gagal mengunggah gambar. Gunakan JPG/PNG maksimal 10 MB.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final duration = int.parse(_durationController.text.trim());
      final banner = widget.isMagang
          ? await MagangHubService.updateBanner(_imagePath, durationValue: duration, durationUnit: _durationUnit)
          : await CareerExpoService.updateBanner(_imagePath, durationValue: duration, durationUnit: _durationUnit);
      if (!mounted) return;
      setState(() => _banner = banner);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner Anda berhasil ditayangkan.')),
      );
    } catch (error) {
      if (mounted) _showError(error, 'Gagal menyimpan banner.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMagang ? 'Banner Magang Hub Saya' : 'Banner Career Expo Saya';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: !_isProvider
          ? const Center(child: Text('Pengelolaan banner hanya untuk penyedia.'))
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_error!),
              TextButton(onPressed: _load, child: const Text('Muat ulang')),
            ]))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Banner milik Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Gunakan gambar asli. Banner Anda tidak mengganti banner milik asesor lain.'),
                  const SizedBox(height: 16),
                  FormField<String>(
                    validator: (_) => _imagePath.isEmpty ? 'Gambar banner wajib diunggah.' : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_imagePath.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                UrlHelper.resolveUrl(_imagePath),
                                fit: BoxFit.contain,
                                semanticLabel: title,
                                errorBuilder: (context, error, stackTrace) => const Center(child: Text('Gambar gagal dimuat.')),
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _pickImage,
                          icon: _uploading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.upload_rounded),
                          label: Text(_uploading ? 'Mengunggah...' : _imagePath.isEmpty ? 'Upload banner asli' : 'Ganti gambar banner'),
                        ),
                        if (field.hasError)
                          Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Durasi tayang wajib diisi', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: TextFormField(
                        controller: _durationController,
                        enabled: !_busy,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Jumlah', border: OutlineInputBorder()),
                        validator: (value) {
                          final duration = int.tryParse(value?.trim() ?? '');
                          return duration == null || duration <= 0 ? 'Isi angka lebih dari 0.' : null;
                        },
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: DropdownButtonFormField<String>(
                        initialValue: _durationUnit,
                        decoration: const InputDecoration(labelText: 'Satuan', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'hours', child: Text('Jam')),
                          DropdownMenuItem(value: 'days', child: Text('Hari')),
                          DropdownMenuItem(value: 'months', child: Text('Bulan')),
                        ],
                        onChanged: _busy ? null : (value) => setState(() => _durationUnit = value!),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Durasi dimulai saat disimpan. Sistem memprioritaskan banner aktif yang paling baru; setelah habis, banner aktif berikutnya ditampilkan.'),
                  if (_banner.imageUrl.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(_banner.isActive ? 'Status: aktif' : _banner.expiresAt == null ? 'Status: belum dijadwalkan' : 'Status: masa tayang berakhir'),
                    if (_banner.expiresAt != null)
                      Text('Berakhir: ${DateFormat('dd/MM/yyyy HH:mm').format(_banner.expiresAt!.toLocal())} (waktu setempat)'),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_saving ? 'Menyimpan...' : 'Tayangkan Banner Saya'),
                  ),
                ],
              ),
            ),
    );
  }
}
