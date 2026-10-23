import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Halaman Multi-Step Lamar Pekerjaan sesuai Screen 1
class CareerExpoApplyScreen extends StatefulWidget {
  final CareerJobItem job;

  const CareerExpoApplyScreen({super.key, required this.job});

  @override
  State<CareerExpoApplyScreen> createState() => _CareerExpoApplyScreenState();
}

class _CareerExpoApplyScreenState extends State<CareerExpoApplyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  String _selectedEducation = 'S1';
  final List<String> _educationOptions = const ['SMA/SMK', 'D3', 'D4', 'S1', 'S2', 'Lainnya'];

  final bool _attachLspCert = true;
  final bool _attachPortfolio = false;
  bool _isSubmitting = false;
  bool _isUploadingCv = false;
  String _cvFileName = '';
  String _cvFileSize = '';
  String _cvUploadedUrl = '';
  @override
  void initState() {
    super.initState();
    _prefillFromUser();
  }

  /// Prefill data diri dari profil user yang sedang login (kalau ada).
  void _prefillFromUser() {
    final user = AuthRepository.currentUserInstance;
    if (user == null) return;
    if (user.name.isNotEmpty) _nameController.text = user.name;
    final email = user.email;
    if (email != null && email.isNotEmpty) _emailController.text = email;
  }
  Future<void> _pickCvFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file != null && file.path != null) {
        final path = file.path!;
        final name = file.name;
        final bytes = await File(path).length();
        if (bytes > 2 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran file melebihi 2 MB. Silakan pilih file yang lebih kecil.'),
              backgroundColor: Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final sizeStr = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        setState(() {
          _cvFileName = name;
          _cvFileSize = sizeStr;
          _isUploadingCv = true;
        });
        final res = await CareerExpoService.uploadFile(path);
        if (!mounted) return;
        setState(() {
          _cvUploadedUrl = res['file_url'] ?? '';
          _isUploadingCv = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV berhasil diunggah!'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingCv = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih berkas CV: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coverLetterController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }
  Future<void> _submitApplication() async {
    final nama = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (nama.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, email, dan nomor HP wajib diisi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // POST /api/career-expo/lowongan/:id/lamar
      await CareerExpoService.lamar(
        widget.job.id,
        namaLengkap: nama,
        email: email,
        noHp: phone,
        pendidikan: _selectedEducation,
        coverLetter: _coverLetterController.text.trim(),
        linkPortofolio: _attachPortfolio
            ? _portfolioController.text.trim()
            : '',
        fileCv: _cvUploadedUrl,
        namaFileCv: _cvUploadedUrl.isNotEmpty ? _cvFileName : '',
        sertakanSertifikat: _attachLspCert,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      var message = 'Gagal mengirim lamaran. Coba lagi ya.';
      if (e is DioException) {
        final code = e.response?.statusCode;
        if (code == 401) {
          message = 'Silakan login terlebih dahulu.';
        } else if (code == 409) {
          message = 'Kamu sudah pernah melamar lowongan ini.';
        } else if (e.response?.data is Map &&
            (e.response?.data as Map)['errors'] != null) {
          message = (e.response?.data as Map)['errors'].toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: InkWell(
            onTap: () => Navigator.of(ctx).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Paper airplane illustration with shadow
                  SizedBox(
                    width: 72,
                    height: 68,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 38,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFF94A3B8).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          child: Transform.rotate(
                            angle: -0.35,
                            child: const Icon(
                              Icons.send_rounded,
                              size: 48,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lamaran Anda sudah terkirim',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          bottom: false,
          child: CustomAppBar(
            title: 'Buat Lamaran',
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Biodata Diri
              const Text(
                'Biodata Diri :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      label: 'Nama',
                      controller: _nameController,
                      hint: 'Nama Lengkap',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pendidikan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEducation,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF0F172A),
                          ),
                          items: _educationOptions.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedEducation = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Email aktif',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'No. Handphone',
                      controller: _phoneController,
                      hint: 'Nomor WhatsApp / HP',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Dokumen Terkait
              const Text(
                'Dokumen Terkait :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Posisi Pekerjaan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Portofolio/CV/Surat Lamaran Kerja',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _isUploadingCv ? null : _pickCvFile,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _isUploadingCv
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Mengunggah berkas...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _cvUploadedUrl.isNotEmpty
                                          ? '$_cvFileName ($_cvFileSize)'
                                          : 'Unggah Dokumen Terkait',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _cvUploadedUrl.isNotEmpty
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    _cvUploadedUrl.isNotEmpty
                                        ? Icons.check_circle_rounded
                                        : Icons.cloud_upload_outlined,
                                    color: _cvUploadedUrl.isNotEmpty
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF0F172A),
                                    size: 24,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ukuran file tidak boleh lebih dari 2mb',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons: Kirim & Batal
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _isUploadingCv ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kirim',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.send_rounded,
                              size: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}
