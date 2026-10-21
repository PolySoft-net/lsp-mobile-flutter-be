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
  int _currentStep = 1; // 1: Data Diri, 2: CV & Portofolio, 3: Konfirmasi

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  bool _attachLspCert = true;
  bool _attachPortfolio = false;
  bool _agreedToTerms = true;
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

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
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
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lamaran Terkirim!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lamaran Anda untuk posisi ${widget.job.title} di ${widget.job.companyName} berhasil dikirim.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context, true); // Pop back to detail/home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Status Lamaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          bottom: false,
          child: CustomAppBar(title: 'Lamar Pekerjaan', onBack: _previousStep),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company & Job Summary Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: widget.job.logoBgColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.job.logoText.isNotEmpty
                                  ? widget.job.logoText
                                  : widget.job.companyName.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.job.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.job.companyName,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${widget.job.location} • ${widget.job.employmentType}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Multi-Step Progress Stepper
                    _buildStepperIndicator(),
                    const SizedBox(height: 28),
                    // Current Step Content
                    if (_currentStep == 1) _buildStep1DataDiri(),
                    if (_currentStep == 2) _buildStep2CvPortfolio(),
                    if (_currentStep == 3) _buildStep3Konfirmasi(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Action Button with Safe Area
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting ||
                            _isUploadingCv ||
                            (_currentStep == 3 && !_agreedToTerms)
                        ? null
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066F6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF0066F6,
                      ).withValues(alpha: 0.7),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _currentStep == 3 ? 'Kirim Lamaran' : 'Lanjutkan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                _currentStep == 3
                                    ? Icons.send_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
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

  Widget _buildStepperIndicator() {
    return Row(
      children: [
        Expanded(child: _buildStepNode(1, 'Data Diri', _currentStep >= 1)),
        SizedBox(
          width: 20,
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: _currentStep >= 2
                ? const Color(0xFF0066F6)
                : const Color(0xFFE2E8F0),
          ),
        ),
        Expanded(child: _buildStepNode(2, 'CV & Portofolio', _currentStep >= 2)),
        SizedBox(
          width: 20,
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: _currentStep >= 3
                ? const Color(0xFF0066F6)
                : const Color(0xFFE2E8F0),
          ),
        ),
        Expanded(child: _buildStepNode(3, 'Konfirmasi', _currentStep >= 3)),
      ],
    );
  }

  Widget _buildStepNode(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFF0066F6)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$step',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF0066F6) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1DataDiri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Diri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nama Lengkap *',
          controller: _nameController,
          hint: 'Masukkan nama lengkap',
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Email *',
          controller: _emailController,
          hint: 'Masukkan email aktif',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'No. HP *',
          controller: _phoneController,
          hint: 'Masukkan nomor HP',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildStep2CvPortfolio() {
    final hasCv = _cvUploadedUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CV & Portofolio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Lengkapi lamaran dengan CV dan dokumen pendukung.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF0066F6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCv ? _cvFileName : 'Curriculum Vitae',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isUploadingCv
                              ? 'Mengunggah CV...'
                              : hasCv
                              ? '$_cvFileSize • Terlampir'
                              : 'Pilih dokumen dalam format PDF',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isUploadingCv ? null : _pickCvFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066F6),
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isUploadingCv
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.upload_file_rounded,
                          size: 20,
                          color: Color(0xFF0066F6),
                        ),
                  label: Text(
                    _isUploadingCv
                        ? 'Mengunggah...'
                        : hasCv
                        ? 'Ganti CV'
                        : 'Pilih CV (PDF)',
                    style: const TextStyle(
                      color: Color(0xFF0066F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dokumen pendukung',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        _buildDocumentOption(
          title: 'Sertifikat kompetensi LSP',
          subtitle: 'Sertakan sertifikat pada lamaran Anda.',
          selected: _attachLspCert,
          onTap: () => setState(() => _attachLspCert = !_attachLspCert),
        ),
        const SizedBox(height: 10),
        _buildDocumentOption(
          title: 'Link portofolio',
          subtitle: 'Figma, Behance, GitHub, atau website pribadi.',
          selected: _attachPortfolio,
          onTap: () => setState(() => _attachPortfolio = !_attachPortfolio),
        ),
        if (_attachPortfolio) ...[
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Tautan portofolio',
            controller: _portfolioController,
            hint: 'https://',
            keyboardType: TextInputType.url,
          ),
        ],
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Pesan pengantar (opsional)',
          controller: _coverLetterController,
          hint: 'Perkenalkan diri dan ceritakan ketertarikan Anda...',
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildDocumentOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      checked: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: selected
                    ? const Color(0xFF0066F6)
                    : const Color(0xFF94A3B8),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
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

  Widget _buildStep3Konfirmasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konfirmasi Pengajuan Lamaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Nama', _nameController.text),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow('Email', _emailController.text),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow('No. HP', _phoneController.text),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow('Posisi', widget.job.title),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow('Perusahaan', widget.job.companyName),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildSummaryRow(
                'Dokumen',
                [
                  if (_cvUploadedUrl.isNotEmpty) 'CV',
                  if (_attachLspCert) 'Sertifikat LSP',
                  if (_attachPortfolio &&
                      _portfolioController.text.trim().isNotEmpty)
                    'Link portofolio',
                ].join(' • '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentOption(
          title: 'Persetujuan pengajuan',
          subtitle: 'Saya menyatakan data yang diisi adalah benar dan mengizinkan perusahaan untuk meninjau profil saya.',
          selected: _agreedToTerms,
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0066F6),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
