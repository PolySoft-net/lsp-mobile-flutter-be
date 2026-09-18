import 'package:material_ui/material_ui.dart';
import '../../models/talenta_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/common/app_notification_storage.dart';
import '../../services/talenta/talenta_service.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Halaman untuk mengirimkan tawaran pekerjaan (hire) kepada talenta/asesi bersertifikat.
/// Setelah dikirim, notifikasi akan langsung masuk ke aplikasi mobile asesi bersangkutan.
class TawarkanPekerjaanScreen extends StatefulWidget {
  final TalentaItem talenta;

  const TawarkanPekerjaanScreen({
    super.key,
    required this.talenta,
  });

  @override
  State<TawarkanPekerjaanScreen> createState() => _TawarkanPekerjaanScreenState();
}

class _TawarkanPekerjaanScreenState extends State<TawarkanPekerjaanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _posisiController = TextEditingController();
  final _perusahaanController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _gajiController = TextEditingController();
  final _kontakController = TextEditingController();
  final _emailController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _catatanController = TextEditingController();

  String _tipePekerjaan = 'Penuh Waktu (Full Time)';
  String _sistemKerja = 'WFO';
  bool _isSubmitting = false;

  final List<String> _listTipePekerjaan = [
    'Penuh Waktu (Full Time)',
    'Paruh Waktu (Part Time)',
    'Kontrak',
    'Freelance',
    'Magang (Internship)',
  ];

  final List<String> _listSistemKerja = [
    'WFO (Kerja di Kantor)',
    'WFH (Remote)',
    'Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    // Prefill kontak perekrut jika user yang sedang login memiliki data
    final user = AuthRepository.currentUserInstance;
    if (user != null && user.email != null && user.email!.isNotEmpty) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _posisiController.dispose();
    _perusahaanController.dispose();
    _lokasiController.dispose();
    _gajiController.dispose();
    _kontakController.dispose();
    _emailController.dispose();
    _deskripsiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final String lokasiFinal = _lokasiController.text.trim().isNotEmpty
        ? '$_sistemKerja - ${_lokasiController.text.trim()}'
        : _sistemKerja;

    final body = {
      'asesi_id': widget.talenta.id,
      'judul_pekerjaan': _posisiController.text.trim(),
      'nama_perusahaan': _perusahaanController.text.trim(),
      'deskripsi_pekerjaan': _deskripsiController.text.trim(),
      'tipe_pekerjaan': _tipePekerjaan,
      'lokasi_kerja': lokasiFinal,
      'rentang_gaji': _gajiController.text.trim(),
      'kontak_perekrut': _kontakController.text.trim(),
      'email_perekrut': _emailController.text.trim(),
      'catatan_tambahan': _catatanController.text.trim(),
    };

    final ok = await TalentaService.tawarkanPekerjaan(body);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      // Simpan juga salinan notifikasi lokal untuk asesi jika akun yang sama dibuka di device ini
      try {
        final notifData = {
          'type': 'tawaran_pekerjaan',
          'asesi_id': widget.talenta.id.toString(),
          'judul_pekerjaan': _posisiController.text.trim(),
          'nama_perusahaan': _perusahaanController.text.trim(),
          'deskripsi_pekerjaan': _deskripsiController.text.trim(),
          'tipe_pekerjaan': _tipePekerjaan,
          'lokasi_kerja': lokasiFinal,
          'rentang_gaji': _gajiController.text.trim(),
          'kontak_perekrut': _kontakController.text.trim(),
          'email_perekrut': _emailController.text.trim(),
          'catatan_tambahan': _catatanController.text.trim(),
        };

        await AppNotificationStorage.instance.saveNotification(
          'Tawaran Pekerjaan: ${_posisiController.text.trim()}',
          '${_perusahaanController.text.trim()} menawarkan posisi ${_posisiController.text.trim()} kepada Anda.',
          'tawaran_pekerjaan',
          notifData,
        );
      } catch (_) {}

      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal mengirimkan tawaran pekerjaan. Periksa koneksi internet Anda.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
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
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tawaran Berhasil Dikirim!',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tawaran pekerjaan untuk posisi "${_posisiController.text.trim()}" telah berhasil dikirim ke notifikasi aplikasi ${widget.talenta.pemegang}.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context, true); // Close screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight > 0 ? 4 : 8),
            const CustomAppBar(
              title: 'Tawarkan Pekerjaan',
              rightWidget: SizedBox(width: 48),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  12.0,
                  16.0,
                  MediaQuery.paddingOf(context).bottom + 24.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Candidate Card Overview
                      _buildCandidateCard(),
                      const SizedBox(height: 18),

                      // Section 1: Informasi Pekerjaan
                      const Text(
                        'Informasi Pekerjaan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'Posisi / Judul Pekerjaan',
                        controller: _posisiController,
                        hint: 'Contoh: Video Editor, Junior Web Developer',
                        isRequired: true,
                        prefixIcon: Icons.work_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Posisi pekerjaan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Nama Perusahaan / Institusi / Perekrut',
                        controller: _perusahaanController,
                        hint: 'Contoh: PT Digital Nusantara, Studio Kreatif',
                        isRequired: true,
                        prefixIcon: Icons.business_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama perusahaan/perekrut wajib diisi';
                          }
                          return null;
                        },
                      ),

                      // Tipe Pekerjaan Selector
                      _buildLabel('Tipe Pekerjaan', isRequired: true),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _listTipePekerjaan.map((tipe) {
                          final isSelected = _tipePekerjaan == tipe;
                          return ChoiceChip(
                            label: Text(
                              tipe,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFEFF6FF),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                            ),
                            onSelected: (_) {
                              setState(() => _tipePekerjaan = tipe);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Sistem Kerja Selector
                      _buildLabel('Sistem Kerja', isRequired: true),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _listSistemKerja.map((sistem) {
                          final isSelected = _sistemKerja == sistem;
                          return ChoiceChip(
                            label: Text(
                              sistem,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF475569),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFF0FDF4),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
                            ),
                            onSelected: (_) {
                              setState(() => _sistemKerja = sistem);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        label: 'Lokasi / Kota Penempatan',
                        controller: _lokasiController,
                        hint: 'Contoh: Jakarta Selatan, Surabaya (kosongkan jika Full Remote)',
                        prefixIcon: Icons.place_outlined,
                      ),

                      _buildTextField(
                        label: 'Perkiraan Gaji / Kompensasi (Opsional)',
                        controller: _gajiController,
                        hint: 'Contoh: Rp 6.000.000 - Rp 9.000.000 / bulan',
                        prefixIcon: Icons.monetization_on_outlined,
                      ),

                      const SizedBox(height: 12),

                      // Section 2: Deskripsi Pekerjaan
                      const Text(
                        'Deskripsi Pekerjaan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'Tanggung Jawab & Kualifikasi',
                        controller: _deskripsiController,
                        hint: 'Tuliskan deskripsi pekerjaan, tanggung jawab utama, persyaratan keahlian, benefit, atau kriteria yang dibutuhkan...',
                        maxLines: 5,
                        isRequired: true,
                        validator: (val) {
                          if (val == null || val.trim().length < 10) {
                            return 'Deskripsi pekerjaan minimal 10 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Section 3: Informasi Kontak Perekrut
                      const Text(
                        'Kontak Perekrut',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Informasi kontak ini akan dikirimkan ke asesi agar dapat menghubungi Anda kembali.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),

                      _buildTextField(
                        label: 'No. WhatsApp / Telepon Perekrut',
                        controller: _kontakController,
                        hint: 'Contoh: 081234567890',
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        prefixIcon: Icons.phone_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nomor kontak WhatsApp/telepon wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Email Perusahaan / HRD (Opsional)',
                        controller: _emailController,
                        hint: 'Contoh: hrd@perusahaan.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),

                      _buildTextField(
                        label: 'Catatan Tambahan (Opsional)',
                        controller: _catatanController,
                        hint: 'Contoh: Mohon sertakan link portofolio saat membalas tawaran ini.',
                        maxLines: 2,
                        prefixIcon: Icons.notes_rounded,
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            _isSubmitting ? 'Mengirimkan Tawaran...' : 'Kirim Tawaran Pekerjaan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              widget.talenta.pemegang.isNotEmpty ? widget.talenta.pemegang[0].toUpperCase() : 'A',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.talenta.pemegang,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Talenta',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.talenta.skema.isNotEmpty ? widget.talenta.skema : 'Skema belum terdaftar',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.place_rounded, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        widget.talenta.lokasi.isNotEmpty ? widget.talenta.lokasi : 'Indonesia',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildLabel(String labelText, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, isRequired: isRequired),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
