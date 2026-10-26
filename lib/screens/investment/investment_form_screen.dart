import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/investment/investment_filter_sheet.dart';

class InvestmentFormScreen extends StatefulWidget {
  const InvestmentFormScreen({super.key});

  @override
  State<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends State<InvestmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _taglineController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _targetFundingController = TextEditingController();
  final _minTicketController = TextEditingController();
  final _valuationController = TextEditingController();
  final _equityController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tractionController = TextEditingController();
  final _founderNameController = TextEditingController();
  final _founderRoleController = TextEditingController(text: 'Founder & CEO');
  final _founderPhoneController = TextEditingController();
  final _founderEmailController = TextEditingController();
  final _pitchDeckController = TextEditingController();
  final _websiteController = TextEditingController();

  String _kategori = 'EdTech & AI';
  String _stage = 'Seed';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _taglineController.dispose();
    _lokasiController.dispose();
    _targetFundingController.dispose();
    _minTicketController.dispose();
    _valuationController.dispose();
    _equityController.dispose();
    _deskripsiController.dispose();
    _tractionController.dispose();
    _founderNameController.dispose();
    _founderRoleController.dispose();
    _founderPhoneController.dispose();
    _founderEmailController.dispose();
    _pitchDeckController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  int _parseAmount(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final startup = InvestmentStartupItem(
      id: '',
      nama: _namaController.text.trim(),
      tagline: _taglineController.text.trim(),
      kategori: _kategori,
      stage: _stage,
      lokasi: _lokasiController.text.trim(),
      targetFunding: _parseAmount(_targetFundingController.text),
      minimumTicket: _parseAmount(_minTicketController.text),
      valuation: _parseAmount(_valuationController.text),
      equityOffered: double.tryParse(_equityController.text.replaceAll(',', '.')) ?? 0.0,
      deskripsi: _deskripsiController.text.trim(),
      traction: _tractionController.text.trim(),
      founderName: _founderNameController.text.trim(),
      founderRole: _founderRoleController.text.trim(),
      founderPhone: _founderPhoneController.text.trim(),
      founderEmail: _founderEmailController.text.trim(),
      pitchDeckUrl: _pitchDeckController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
    );

    try {
      await InvestmentService.createStartup(startup);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Startup berhasil didaftarkan ke katalog investasi!'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendaftarkan startup. Pastikan data sudah sesuai.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = InvestmentFilterSheet.categories
        .where((c) => c != 'Semua')
        .toList();
    final stages = InvestmentFilterSheet.stages
        .where((s) => s != 'Semua')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Daftarkan Startup',
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Simpan & Publikasikan Startup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Profil Startup',
                icon: Icons.business_rounded,
                children: [
                  _buildTextField(
                    controller: _namaController,
                    label: 'Nama Startup *',
                    hint: 'Contoh: EduTech Nusantara',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama startup wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _taglineController,
                    label: 'Tagline / Slogan Ringkas',
                    hint: 'Deskripsi satu kalimat tentang keunggulan startup Anda',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<String>(
                          label: 'Sektor / Kategori *',
                          value: _kategori,
                          items: categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _kategori = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField<String>(
                          label: 'Tahapan (Stage) *',
                          value: _stage,
                          items: stages
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _stage = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _lokasiController,
                    label: 'Kota / Domisili Operasional',
                    hint: 'Contoh: Jakarta Selatan, Bandung, Yogyakarta',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                title: 'Kebutuhan Investasi & Ekuitas',
                icon: Icons.payments_outlined,
                children: [
                  _buildTextField(
                    controller: _targetFundingController,
                    label: 'Target Dana yang Dibutuhkan (Rp) *',
                    hint: 'Contoh: 500.000.000',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Target dana wajib diisi';
                      final val = _parseAmount(v);
                      if (val <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _minTicketController,
                          label: 'Min. Tiket Investasi (Rp)',
                          hint: 'Contoh: 25.000.000',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _equityController,
                          label: 'Ekuitas Ditawarkan (%)',
                          hint: 'Contoh: 10',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _valuationController,
                    label: 'Valuasi Pra-Investasi (Rp)',
                    hint: 'Contoh: 5.000.000.000 (opsional)',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                title: 'Bisnis & Traksi',
                icon: Icons.auto_graph_rounded,
                children: [
                  _buildTextField(
                    controller: _deskripsiController,
                    label: 'Deskripsi Masalah & Solusi *',
                    hint: 'Jelaskan masalah pasar yang diselesaikan, solusi yang ditawarkan, dan model bisnis Anda...',
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Deskripsi bisnis wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _tractionController,
                    label: 'Traksi & Pencapaian Utama',
                    hint: 'Contoh: 25 Mitra Institusi, 50.000+ pengguna aktif, ARR Rp 800 Jt...',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                title: 'Data Founder & Kontak',
                icon: Icons.person_outline_rounded,
                children: [
                  _buildTextField(
                    controller: _founderNameController,
                    label: 'Nama Founder *',
                    hint: 'Contoh: Budi Pratama, S.Kom',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama founder wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _founderRoleController,
                    label: 'Jabatan / Peran di Startup',
                    hint: 'Contoh: Founder & CEO / Co-Founder & CTO',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _founderPhoneController,
                          label: 'No WhatsApp / HP *',
                          hint: 'Contoh: 081234567890',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nomor HP wajib diisi'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _founderEmailController,
                          label: 'Email Resmi',
                          hint: 'Contoh: founder@startup.id',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                title: 'Dokumen & Tautan (Opsional)',
                icon: Icons.link_rounded,
                children: [
                  _buildTextField(
                    controller: _pitchDeckController,
                    label: 'Tautan Pitch Deck (PDF / Drive)',
                    hint: 'https://drive.google.com/... atau https://startup.id/deck.pdf',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Tautan Website Resmi',
                    hint: 'https://startup.id',
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
