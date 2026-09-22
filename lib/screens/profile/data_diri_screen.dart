import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/upload_file_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/location_service.dart';
import '../../utils/url_helper.dart';
import '../../widgets/profile/profile_asesor_widgets.dart';
import '../../models/auth_models.dart';
import 'edit_data_diri_screen.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noRegController;
  late TextEditingController _npwpController;
  late TextEditingController _noRekeningController;
  late TextEditingController _bankController;
  late TextEditingController _atasNamaController;
  late TextEditingController _linkCvController;
  late TextEditingController _homebaseController;
  late TextEditingController _domisiliController;

  String? _fotoProfilUrl;
  double? _latitude;
  double? _longitude;
  String? _locationName;
  bool _isResolvingLocation = false;
  int _statusPencariKerja = 1;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  void _resolveLocationName(double lat, double lng) async {
    if (_isResolvingLocation) return;
    _isResolvingLocation = true;
    try {
      final name = await LocationService.getRealLocationName(lat, lng);
      if (mounted && name.isNotEmpty) {
        setState(() {
          _locationName = name;
        });
      }
    } catch (_) {
    } finally {
      _isResolvingLocation = false;
    }
  }

  @override
  void initState() {
    super.initState();
    final user = AuthRepository.currentUserInstance;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
    _noRegController = TextEditingController(text: '');
    _npwpController = TextEditingController(text: '');
    _noRekeningController = TextEditingController(text: '');
    _bankController = TextEditingController(text: '');
    _atasNamaController = TextEditingController(text: '');
    _linkCvController = TextEditingController(text: '');
    _homebaseController = TextEditingController(text: '');
    _domisiliController = TextEditingController(text: '');
    _fotoProfilUrl = user?.fotoProfilUrl;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    final user = AuthRepository.currentUserInstance;
    final bool isAsesi = user?.isAsesi ?? false;

    try {
      if (isAsesi) {
        final profile = await AsesiService.getProfile();
        if (profile != null && mounted) {
          setState(() {
            _nameController.text =
                profile['nama_lengkap']?.toString() ??
                profile['nama']?.toString() ??
                user?.name ??
                '';
            _emailController.text =
                profile['email']?.toString() ?? user?.email ?? '';
            _phoneController.text =
                profile['telp']?.toString() ??
                profile['no_telepon']?.toString() ??
                '';
            _addressController.text = profile['alamat']?.toString() ?? '';
            _domisiliController.text = profile['alamat']?.toString() ?? '';
            _noRegController.text = profile['nik']?.toString() ?? '';
            _latitude = (profile['latitude'] as num?)?.toDouble();
            _longitude = (profile['longitude'] as num?)?.toDouble();
            _statusPencariKerja =
                (profile['status_pencari_kerja'] as num?)?.toInt() ?? 1;
            if (profile['foto_profil_url'] != null &&
                profile['foto_profil_url'].toString().isNotEmpty) {
              _fotoProfilUrl = profile['foto_profil_url'].toString();
            }
          });
          if (_latitude != null && _longitude != null) {
            _resolveLocationName(_latitude!, _longitude!);
          }
        }
      } else {
        final profile = await AsesorService.getProfile();
        if (profile != null && mounted) {
          setState(() {
            _nameController.text =
                profile['nama_lengkap']?.toString() ??
                profile['nama']?.toString() ??
                '';
            _emailController.text = profile['email']?.toString() ?? '';
            _phoneController.text =
                profile['no_telepon']?.toString() ??
                profile['telepon']?.toString() ??
                profile['phone']?.toString() ??
                '';
            _addressController.text = profile['alamat']?.toString() ?? '';
            _noRegController.text =
                profile['no_reg']?.toString() ??
                profile['id_asesor']?.toString() ??
                profile['nik']?.toString() ??
                '';
            _npwpController.text = profile['npwp']?.toString() ?? '';
            _noRekeningController.text =
                profile['no_rekening']?.toString() ?? '';
            _bankController.text = profile['bank']?.toString() ?? '';
            _atasNamaController.text =
                profile['atas_nama_rekening']?.toString() ??
                profile['atas_nama']?.toString() ??
                '';
            _linkCvController.text = profile['link_cv']?.toString() ?? '';
            _homebaseController.text = profile['homebase']?.toString() ?? '';
            _domisiliController.text =
                profile['domisili']?.toString() ??
                profile['alamat']?.toString() ??
                '';
            if (profile['foto_profil_url'] != null &&
                profile['foto_profil_url'].toString().isNotEmpty) {
              _fotoProfilUrl = profile['foto_profil_url'].toString();
            }
          });
        }
        try {
          final asesiProf = await AsesiService.getProfile();
          if (asesiProf != null && mounted && asesiProf['latitude'] != null) {
            setState(() {
              _latitude = (asesiProf['latitude'] as num?)?.toDouble();
              _longitude = (asesiProf['longitude'] as num?)?.toDouble();
              _statusPencariKerja =
                  (asesiProf['status_pencari_kerja'] as num?)?.toInt() ?? 1;
            });
            if (_latitude != null && _longitude != null) {
              _resolveLocationName(_latitude!, _longitude!);
            }
          }
        } catch (_) {}
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file != null) {
        final valid = await UploadFileValidator.isValid(
          messenger,
          file,
          UploadFileValidator.profilePhotoMaxMB,
        );
        if (!mounted) {
          return;
        }
        if (!valid) {
          return;
        }
        final filePath = file.path!;
        setState(() => _isUploadingPhoto = true);
        final uploaded = await AuthRepository.uploadProfilePhoto(filePath);
        if (!mounted) return;
        if (uploaded != null && uploaded['foto_profil_url'] != null) {
          final photoUrl = uploaded['foto_profil_url'].toString();
          setState(() {
            _fotoProfilUrl = photoUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Foto profil berhasil diperbarui!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah foto profil'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoPicker() {
    showProfilePhotoPicker(context: context, onPickPhoto: _pickAndUploadPhoto);
  }

  void _copyToClipboard(String text, String label) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openCvLink(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;
    String url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          _copyToClipboard(rawUrl, 'Link CV');
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noRegController.dispose();
    _npwpController.dispose();
    _noRekeningController.dispose();
    _bankController.dispose();
    _atasNamaController.dispose();
    _linkCvController.dispose();
    _homebaseController.dispose();
    _domisiliController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final blueColor = const Color(0xFF5B9FD8);
    final user = AuthRepository.currentUserInstance;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Blue Header Container
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B9FD8), Color(0xFF4FA8E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: statusBarHeight + 12,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // Top navigation: "< Data Diri" aligned left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1E293B),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF1E293B),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Data Diri',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Avatar Photo Stack
                  Builder(
                    builder: (context) {
                      final rawPhoto = _fotoProfilUrl ?? user?.fotoProfilUrl;
                      final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
                          ? UrlHelper.resolveUrl(rawPhoto)
                          : null;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: _showPhotoPicker,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _isUploadingPhoto
                                    ? const Center(
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5B9FD8),
                                                ),
                                          ),
                                        ),
                                      )
                                    : (photoUrl != null && photoUrl.isNotEmpty)
                                    ? Image.network(
                                        photoUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    size: 75,
                                                    color: Color(0xFF94A3B8),
                                                  ),
                                                ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 75,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showPhotoPicker,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  color: blueColor,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Badge Role
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role == 'asesor' ? 'Aktif' : 'Peserta',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
              ),

            // Form Fields Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  20.0,
                  MediaQuery.paddingOf(context).bottom + 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Section Data Pribadi
                    _buildSectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: 'Data Pribadi & Asesor',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildField(
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            hint: 'Belum diatur',
                          ),
                          if (_noRegController.text.isNotEmpty)
                            _buildField(
                              label: 'No. Registrasi / NIK Asesor',
                              controller: _noRegController,
                              hint: 'Belum ada No. Reg',
                              showCopyButton: true,
                            ),
                          _buildField(
                            label: 'Email',
                            controller: _emailController,
                            hint: 'Belum diatur',
                          ),
                          _buildField(
                            label: 'No. Handphone',
                            controller: _phoneController,
                            hint: 'Belum diatur',
                          ),
                          _buildField(
                            label: 'Domisili / Alamat',
                            controller: _domisiliController.text.isNotEmpty
                                ? _domisiliController
                                : _addressController,
                            hint: 'Belum diatur',
                            maxLines: 2,
                          ),
                          if ((user?.isAsesi ?? false) ||
                              _latitude != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Titik Koordinat Lokasi (GPS)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _latitude != null
                                          ? const Color(0xFFF0FDF4)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _latitude != null
                                            ? const Color(0xFFBBF7D0)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            size: 18,
                                            color: _latitude != null
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (_locationName != null &&
                                                  _locationName!
                                                      .isNotEmpty) ...[
                                                Text(
                                                  _locationName!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                              ],
                                              Text(
                                                _latitude != null
                                                    ? 'Koordinat: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                                                    : 'Titik koordinat belum terpasang',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: _latitude != null
                                                      ? const Color(0xFF16A34A)
                                                      : const Color(0xFF64748B),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status Pencari Kerja',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      _statusPencariKerja == 1
                                          ? 'Sedang aktif mencari kerja (Open to Work)'
                                          : _statusPencariKerja == 2
                                          ? 'Bekerja, tapi terbuka untuk peluang baru'
                                          : 'Tidak sedang mencari kerja',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: _statusPencariKerja == 1
                                            ? const Color(0xFF16A34A)
                                            : _statusPencariKerja == 2
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_homebaseController.text.isNotEmpty)
                            _buildField(
                              label: 'Homebase',
                              controller: _homebaseController,
                              hint: 'Belum diatur',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!(user?.isAsesi ?? false)) ...[
                      // 2. Section Rekening & Pajak
                      _buildSectionHeader(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Rekening Bank & Pajak (Honorarium)',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildField(
                              label: 'No. NPWP',
                              controller: _npwpController,
                              hint: 'Belum diisi',
                              showCopyButton: _npwpController.text.isNotEmpty,
                            ),
                            _buildField(
                              label: 'Nama Bank',
                              controller: _bankController,
                              hint: 'Belum diisi (Contoh: BCA, Mandiri, BRI)',
                            ),
                            _buildField(
                              label: 'No. Rekening',
                              controller: _noRekeningController,
                              hint: 'Belum diisi',
                              showCopyButton:
                                  _noRekeningController.text.isNotEmpty,
                            ),
                            _buildField(
                              label: 'Atas Nama Rekening',
                              controller: _atasNamaController,
                              hint: 'Belum diisi',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Section Dokumen & CV
                      _buildSectionHeader(
                        icon: Icons.description_outlined,
                        title: 'Dokumen & Portofolio',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildField(
                              label: 'Link CV / Dokumen Asesor',
                              controller: _linkCvController,
                              hint:
                                  'Belum diisi (Contoh: Link Google Drive CV)',
                              showCopyButton: _linkCvController.text.isNotEmpty,
                              actionWidget: _linkCvController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton.icon(
                                          onPressed: () => _openCvLink(
                                            _linkCvController.text,
                                          ),
                                          icon: const Icon(
                                            Icons.open_in_new_rounded,
                                            size: 15,
                                          ),
                                          label: const Text(
                                            'Buka Link Dokumen CV',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF3B82F6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Bottom Button (Edit Data Diri)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDataDiriScreen(
                                currentName: _nameController.text,
                                currentPhone: _phoneController.text,
                                currentEmail: _emailController.text,
                                currentAddress:
                                    _addressController.text.isNotEmpty
                                    ? _addressController.text
                                    : _domisiliController.text,
                                currentNPWP: _npwpController.text,
                                currentNoRekening: _noRekeningController.text,
                                currentBank: _bankController.text,
                                currentAtasNama: _atasNamaController.text,
                                currentLinkCV: _linkCvController.text,
                                currentHomebase: _homebaseController.text,
                                currentLatitude: _latitude,
                                currentLongitude: _longitude,
                                currentStatusPencariKerja: _statusPencariKerja,
                                onSave:
                                    (
                                      name,
                                      phone,
                                      email,
                                      address,
                                      npwp,
                                      noRekening,
                                      bank,
                                      atasNama,
                                      linkCv,
                                      homebase, {
                                      lat,
                                      lng,
                                      statusPencariKerja,
                                    }) {
                                      setState(() {
                                        _nameController.text = name;
                                        _emailController.text = email;
                                        _phoneController.text = phone;
                                        _addressController.text = address;
                                        _npwpController.text = npwp;
                                        _noRekeningController.text = noRekening;
                                        _bankController.text = bank;
                                        _atasNamaController.text = atasNama;
                                        _linkCvController.text = linkCv;
                                        _homebaseController.text = homebase;
                                        _domisiliController.text =
                                            address.isNotEmpty
                                            ? address
                                            : homebase;
                                        if (lat != null && lng != null) {
                                          _latitude = lat;
                                          _longitude = lng;
                                          _resolveLocationName(lat, lng);
                                        }
                                        if (statusPencariKerja != null) {
                                          _statusPencariKerja =
                                              statusPencariKerja;
                                        }
                                      });
                                      final user =
                                          AuthRepository.currentUserInstance;
                                      if (user != null) {
                                        AuthRepository.currentUserInstance =
                                            AuthUser(
                                              id: user.id,
                                              account: user.account,
                                              name: name,
                                              role: user.role,
                                              roles: user.roles,
                                              email: email,
                                              fotoProfil: user.fotoProfil,
                                              fotoProfilUrl:
                                                  _fotoProfilUrl ??
                                                  user.fotoProfilUrl,
                                            );
                                      }
                                    },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Edit Data Diri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool showCopyButton = false,
    Widget? actionWidget,
  }) {
    final hasValue = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              if (showCopyButton && hasValue)
                GestureDetector(
                  onTap: () => _copyToClipboard(controller.text, label),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: Color(0xFF3B82F6),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Salin',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: hasValue
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF94A3B8),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
            ),
          ),
          ?actionWidget,
        ],
      ),
    );
  }
}
