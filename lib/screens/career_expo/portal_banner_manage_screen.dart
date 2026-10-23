import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/portal_banner_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

class PortalBannerManageScreen extends StatefulWidget {
  final bool isMagang;

  const PortalBannerManageScreen({super.key, this.isMagang = false});

  @override
  State<PortalBannerManageScreen> createState() => _PortalBannerManageScreenState();
}

class _PortalBannerManageScreenState extends State<PortalBannerManageScreen> {
  List<PortalBanner> _banners = [];
  bool _loading = true;
  String? _error;

  bool get _isProvider => AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;

  String get _title => widget.isMagang ? 'Kelola Banner Magang' : 'Kelola Banner Career Expo';

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = widget.isMagang
          ? await MagangHubService.getMyBanners()
          : await CareerExpoService.getMyBanners();
      if (!mounted) return;
      setState(() {
        _banners = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat daftar banner. Periksa koneksi internet Anda.';
        _loading = false;
      });
    }
  }

  Future<void> _openForm({PortalBanner? banner}) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PortalBannerFormScreen(
          isMagang: widget.isMagang,
          initialBanner: banner,
        ),
      ),
    );
    if (!mounted) return;
    if (updated == true) {
      _loadBanners();
    }
  }

  Future<void> _deleteBanner(PortalBanner banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Banner', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus banner ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      if (widget.isMagang) {
        await MagangHubService.deleteBanner(banner.id);
      } else {
        await CareerExpoService.deleteBanner(banner.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banner berhasil dihapus.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadBanners();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus banner.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(title: _title),
          ),
        ),
      ),
      bottomNavigationBar: _isProvider
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                    label: const Text(
                      'Tambah Banner',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: !_isProvider
          ? const Center(child: Text('Pengelolaan banner hanya untuk penyedia.'))
          : RefreshIndicator(
              onRefresh: _loadBanners,
              color: const Color(0xFF0066F6),
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0066F6)));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadBanners,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_banners.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image_outlined, size: 36, color: Color(0xFF0066F6)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Banner',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pasang banner promosi untuk menampilkan poster lowongan atau perusahaan Anda di beranda portal.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Banner Sekarang'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      itemCount: _banners.length,
      itemBuilder: (context, index) {
        final banner = _banners[index];
        return _buildBannerCard(banner);
      },
    );
  }

  Widget _buildBannerCard(PortalBanner banner) {
    final now = DateTime.now();
    final isActive = banner.isActive;
    final isUpcoming = banner.startsAt != null && banner.startsAt!.isAfter(now);
    final isExpired = banner.expiresAt != null && banner.expiresAt!.isBefore(now);

    Color statusBg = const Color(0xFFF1F5F9);
    Color statusText = const Color(0xFF64748B);
    String statusLabel = 'Belum Dijadwalkan';

    if (isActive) {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
      statusLabel = 'Aktif Tayang';
    } else if (isUpcoming) {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF0066F6);
      statusLabel = 'Akan Datang';
    } else if (isExpired) {
      statusBg = const Color(0xFFF1F5F9);
      statusText = const Color(0xFF64748B);
      statusLabel = 'Kedaluwarsa';
    }

    final format = DateFormat('dd MMM yyyy, HH:mm');
    final periodeText = (banner.startsAt != null && banner.expiresAt != null)
        ? '${format.format(banner.startsAt!)} - ${format.format(banner.expiresAt!)}'
        : 'Tanggal belum diatur';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: AspectRatio(
              aspectRatio: 2.1,
              child: Image.network(
                UrlHelper.resolveUrl(banner.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 36, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: statusText),
                      ),
                    ),
                    const Spacer(),
                    if (banner.durationText.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.timelapse_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            banner.durationText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        periodeText,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openForm(banner: banner),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0066F6)),
                      label: const Text('Edit', style: TextStyle(fontSize: 12.5, color: Color(0xFF0066F6))),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _deleteBanner(banner),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                      label: const Text('Hapus', style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PortalBannerFormScreen extends StatefulWidget {
  final bool isMagang;
  final PortalBanner? initialBanner;

  const PortalBannerFormScreen({
    super.key,
    this.isMagang = false,
    this.initialBanner,
  });

  @override
  State<PortalBannerFormScreen> createState() => _PortalBannerFormScreenState();
}

class _PortalBannerFormScreenState extends State<PortalBannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _imagePath = '';
  DateTime? _startsAt;
  DateTime? _expiresAt;
  bool _uploading = false;
  bool _saving = false;

  bool get _isEdit => widget.initialBanner != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialBanner != null) {
      final b = widget.initialBanner!;
      _imagePath = b.imageUrl;
      _startsAt = b.startsAt;
      _expiresAt = b.expiresAt;
    } else {
      final now = DateTime.now();
      _startsAt = DateTime(now.year, now.month, now.day, now.hour, 0);
      _expiresAt = _startsAt!.add(const Duration(days: 30));
    }
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null || !end.isAfter(start)) {
      return 'Tanggal selesai harus lebih besar dari tanggal mulai';
    }
    int totalMonths = (end.year - start.year) * 12 + (end.month - start.month);
    int days = end.day - start.day;
    if (days < 0) {
      totalMonths--;
      final prevMonth = DateTime(end.year, end.month, 0);
      days += prevMonth.day;
    }

    final diff = end.difference(start);
    final totalHours = diff.inHours;

    if (totalMonths <= 0 && days <= 0) {
      if (totalHours > 0) {
        final mins = diff.inMinutes % 60;
        return mins > 0 ? '$totalHours jam $mins menit' : '$totalHours jam';
      }
      final mins = diff.inMinutes;
      return mins > 0 ? '$mins menit' : '1 menit';
    }

    final parts = <String>[];
    if (totalMonths > 0) parts.add('$totalMonths bulan');
    if (days > 0) parts.add('$days hari');
    if (totalMonths == 0 && days < 3) {
      final hours = totalHours % 24;
      if (hours > 0) parts.add('$hours jam');
    }
    return parts.join(' ');
  }

  Future<void> _pickImage() async {
    setState(() => _uploading = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      if (!mounted || file == null || file.path == null) return;
      final uploaded = widget.isMagang
          ? await MagangHubService.uploadFile(file.path!)
          : await CareerExpoService.uploadFile(file.path!);
      if (!mounted) return;
      final imagePath = Uri.parse(uploaded['file_url'] ?? '').path;
      if (imagePath.isNotEmpty) {
        setState(() => _imagePath = imagePath);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? (_startsAt ?? DateTime.now()) : (_expiresAt ?? DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0066F6)),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0066F6)),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !mounted) return;

    final result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      if (isStart) {
        _startsAt = result;
      } else {
        _expiresAt = result;
      }
    });
  }

  Future<void> _save() async {
    if (_imagePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar banner wajib diunggah.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_startsAt == null || _expiresAt == null || !_expiresAt!.isAfter(_startsAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai harus lebih besar dari tanggal mulai.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        if (widget.isMagang) {
          await MagangHubService.updateBanner(
            widget.initialBanner!.id,
            imageUrl: _imagePath,
            startsAt: _startsAt!,
            expiresAt: _expiresAt!,
          );
        } else {
          await CareerExpoService.updateBanner(
            widget.initialBanner!.id,
            imageUrl: _imagePath,
            startsAt: _startsAt!,
            expiresAt: _expiresAt!,
          );
        }
      } else {
        if (widget.isMagang) {
          await MagangHubService.createBanner(
            imageUrl: _imagePath,
            startsAt: _startsAt!,
            expiresAt: _expiresAt!,
          );
        } else {
          await CareerExpoService.createBanner(
            imageUrl: _imagePath,
            startsAt: _startsAt!,
            expiresAt: _expiresAt!,
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Banner berhasil diperbarui.' : 'Banner berhasil ditambahkan.'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      String msg = 'Gagal menyimpan banner.';
      if (e is DioException && e.response?.data is Map) {
        final d = e.response!.data as Map;
        if (d['message'] != null) msg = d['message'].toString();
        if (d['errors'] != null) msg = d['errors'].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Banner' : 'Tambah Banner';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final durationText = _formatDuration(_startsAt, _expiresAt);
    final isValidRange = _startsAt != null && _expiresAt != null && _expiresAt!.isAfter(_startsAt!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(title: title),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving || _uploading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEdit ? 'Perbarui Banner' : 'Simpan Banner',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Banner Section
              const Text(
                'Gambar Banner *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Format JPG atau PNG maksimal 10 MB. Tampil sebagai poster promosi di beranda.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (_imagePath.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                        child: AspectRatio(
                          aspectRatio: 2.1,
                          child: Image.network(
                            UrlHelper.resolveUrl(_imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined, size: 36, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _uploading ? null : _pickImage,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0066F6),
                                side: const BorderSide(color: Color(0xFFBFDBFE)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: _uploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066F6)),
                                    )
                                  : const Icon(Icons.upload_rounded, size: 18),
                              label: Text(_uploading
                                  ? 'Mengunggah...'
                                  : (_imagePath.isEmpty ? 'Pilih Gambar Banner' : 'Ganti Gambar')),
                            ),
                          ),
                          if (_imagePath.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Hapus gambar',
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                              onPressed: _uploading ? null : () => setState(() => _imagePath = ''),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rentang Jadwal Section
              const Text(
                'Rentang Jadwal Tayang *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih tanggal dan waktu mulai serta tanggal selesai penayangan banner.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // Tanggal Mulai Picker Card
              InkWell(
                onTap: () => _pickDateTime(isStart: true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF0066F6), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mulai Ditayangkan', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              _startsAt != null ? dateFormat.format(_startsAt!) : 'Pilih tanggal mulai',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tanggal Selesai Picker Card
              InkWell(
                onTap: () => _pickDateTime(isStart: false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.stop_circle_outlined, color: Color(0xFFEF4444), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selesai Ditayangkan', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              _expiresAt != null ? dateFormat.format(_expiresAt!) : 'Pilih tanggal selesai',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Durasi Hitung Otomatis Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isValidRange ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isValidRange ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isValidRange ? Icons.timer_outlined : Icons.info_outline_rounded,
                      color: isValidRange ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isValidRange ? 'Durasi Tayang Otomatis' : 'Perhatian',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isValidRange ? const Color(0xFF166534) : const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isValidRange ? durationText : 'Tanggal selesai harus lebih besar dari tanggal mulai.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isValidRange ? FontWeight.bold : FontWeight.w500,
                              color: isValidRange ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ],
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
}
