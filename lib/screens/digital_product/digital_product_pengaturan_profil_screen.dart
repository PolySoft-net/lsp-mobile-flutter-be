import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/asesi/asesi_service.dart';
import '../../services/auth/token_storage.dart';
import '../../services/digital_product_service.dart';
import '../../utils/upload_file_validator.dart';

class DigitalProductPengaturanProfilScreen extends StatefulWidget {
  const DigitalProductPengaturanProfilScreen({super.key});

  @override
  State<DigitalProductPengaturanProfilScreen> createState() =>
      _DigitalProductPengaturanProfilScreenState();
}

class _DigitalProductPengaturanProfilScreenState
    extends State<DigitalProductPengaturanProfilScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _photoUrl = '';
  String? _newPhotoPath;
  String _initialNama = '';
  String _initialNoHp = '';
  String _initialEmail = '';

  bool _loading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    String name = '';
    String email = '';
    String phone = '';
    String photo = '';

    try {
      final profile = await DigitalProductService.getProfile();
      final seller = profile.seller;
      name = seller.name;
      email = seller.email;
      phone = seller.phone;
      photo = seller.profilePhoto;
    } catch (_) {}

    if (name.isEmpty || email.isEmpty || photo.isEmpty) {
      final user = await TokenStorage.instance.getUserProfile();
      if (user != null) {
        if (name.isEmpty) name = user.name;
        if (email.isEmpty) email = user.email ?? '';
        if (photo.isEmpty) photo = user.fotoProfilUrl ?? '';
      }
    }

    if (phone.isEmpty) {
      try {
        final asesiData = await AsesiService.getProfile();
        if (asesiData != null) {
          phone = asesiData['no_hp']?.toString() ??
              asesiData['phone']?.toString() ??
              '';
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _namaController.text = name;
        _emailController.text = email;
        _noHpController.text = phone;
        _photoUrl = photo;
        _initialNama = name;
        _initialEmail = email;
        _initialNoHp = phone;
        _loading = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file != null && file.path != null) {
        final valid = await UploadFileValidator.isValid(
          messenger,
          file,
          UploadFileValidator.profilePhotoMaxMB,
        );
        if (!mounted || !valid) return;
        setState(() {
          _newPhotoPath = file.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _newPhotoPath = null;
      _namaController.text = _initialNama;
      _noHpController.text = _initialNoHp;
      _emailController.text = _initialEmail;
    });
  }

  Future<void> _saveProfile() async {
    final nama = _namaController.text.trim();
    final noHp = _noHpController.text.trim();
    final email = _emailController.text.trim();

    if (nama.isEmpty) {
      _showWarning('Nama tidak boleh kosong');
      return;
    }
    if (noHp.isEmpty) {
      _showWarning('Nomor HP tidak boleh kosong');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showWarning('Email tidak valid');
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool apiSuccess = false;
      try {
        await DigitalProductService.updateProfile(
          name: nama,
          phone: noHp,
          email: email,
          photoPath: _newPhotoPath,
        );
        apiSuccess = true;
      } catch (e) {
        debugPrint('DigitalProductService.updateProfile error: $e');
      }

      final user = await TokenStorage.instance.getUserProfile();
      if (user != null) {
        final updatedUser = user.copyWith(
          name: nama,
          email: email,
          fotoProfilUrl: _newPhotoPath != null ? _photoUrl : user.fotoProfilUrl,
        );
        await TokenStorage.instance.saveUserProfile(updatedUser);
      }

      if (!mounted) return;

      setState(() {
        _initialNama = nama;
        _initialNoHp = noHp;
        _initialEmail = email;
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  apiSuccess
                      ? 'Profil berhasil diperbarui!'
                      : 'Profil berhasil disimpan di aplikasi.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showWarning('Gagal menyimpan profil: $e');
    }
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildAvatarBanner(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _isEditing
                                    ? _buildInputField(
                                        _namaController,
                                        'Masukkan nama',
                                      )
                                    : _buildReadonlyField(
                                        _namaController.text.isNotEmpty
                                            ? _namaController.text
                                            : '-',
                                      ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No.Hp',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _isEditing
                                    ? _buildInputField(
                                        _noHpController,
                                        'Masukkan nomor HP',
                                        keyboardType: TextInputType.phone,
                                      )
                                    : _buildReadonlyField(
                                        _noHpController.text.isNotEmpty
                                            ? _noHpController.text
                                            : '-',
                                      ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _isEditing
                                    ? _buildInputField(
                                        _emailController,
                                        'Masukkan email',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      )
                                    : _buildReadonlyField(
                                        _emailController.text.isNotEmpty
                                            ? _emailController.text
                                            : '-',
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pengaturan Profil',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBanner() {
    final photo = DigitalProductService.absoluteUrl(_photoUrl);
    ImageProvider? imageProvider;
    if (_newPhotoPath != null && _newPhotoPath!.isNotEmpty) {
      imageProvider = FileImage(File(_newPhotoPath!));
    } else if (photo.isNotEmpty) {
      imageProvider = NetworkImage(photo);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: const BoxDecoration(color: Color(0xFFE0EDFB)),
      child: Center(
        child: GestureDetector(
          onTap: _isEditing ? _pickPhoto : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF94A3B8),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, color: Colors.white, size: 36)
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0284C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadonlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 11.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          icon: const Icon(
            LucideIcons.square_pen,
            size: 16,
            color: Color(0xFF0F172A),
          ),
          label: const Text(
            'Edit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE2E8F0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: _isSaving ? null : _cancelEdit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
