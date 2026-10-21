import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../models/master_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/common/master_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Form Input & Edit Lowongan Magang di Perusahaan Mitra yang di-input oleh Asesor.
class MagangFormScreen extends StatefulWidget {
  final CareerJobItem? initialJob;

  const MagangFormScreen({
    super.key,
    this.initialJob,
  });

  @override
  State<MagangFormScreen> createState() => _MagangFormScreenState();
}

class _MagangFormScreenState extends State<MagangFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _aboutCompanyController;
  late TextEditingController _descriptionController;

  String _workplaceType = 'On Site';
  String _education = 'S1';
  String _experience = 'Fresh Graduate';

  final List<TextEditingController> _descItemControllers = [];
  final List<TextEditingController> _reqItemControllers = [];
  final List<TextEditingController> _benefitItemControllers = [];

  List<MasterSkema> _skemaList = [];
  MasterSkema? _selectedSkema;
  bool _isLoadingSkema = true;
  bool _skemaLoadFailed = false;

  String _filePdfUrl = '';
  String _filePdfName = '';
  bool _isUploadingPdf = false;
  bool _isSubmitting = false;

  List<String> _workplaceTypes = ['On Site', 'Remote', 'Hybrid'];
  final List<String> _educationOptions = ['SMA / SMK', 'D3', 'S1', 'S2', 'Semua Jurusan'];
  final List<String> _experienceOptions = ['Mahasiswa Aktif', 'Fresh Graduate', '1 - 3 Tahun', 'Semua Pengalaman'];

  @override
  void initState() {
    super.initState();
    final init = widget.initialJob;
    _titleController = TextEditingController(text: init?.title ?? '');
    _companyController = TextEditingController(text: init?.companyName ?? '');
    _categoryController = TextEditingController(text: init?.companyCategory ?? 'Teknologi Informasi & Software');
    _locationController = TextEditingController(text: init?.location ?? '');
    _salaryMinController = TextEditingController(text: init != null && init.salaryMin > 0 ? init.salaryMin.toString() : '');
    _salaryMaxController = TextEditingController(text: init != null && init.salaryMax > 0 ? init.salaryMax.toString() : '');
    _aboutCompanyController = TextEditingController(text: init?.aboutCompany ?? '');
    _descriptionController = TextEditingController(text: init?.shortDescription ?? '');

    if (init != null) {
      if (_workplaceTypes.contains(init.workplaceType)) {
        _workplaceType = init.workplaceType;
      }
      if (_educationOptions.contains(init.education)) {
        _education = init.education;
      }
      if (_experienceOptions.contains(init.experience)) {
        _experience = init.experience;
      }
      _filePdfUrl = init.filePdf;
      if (init.filePdf.isNotEmpty) {
        _filePdfName = init.filePdf.split(RegExp(r'[/\\]')).last;
      }
      for (final s in init.jobDescription) {
        _descItemControllers.add(TextEditingController(text: s));
      }
      for (final s in init.requirements) {
        _reqItemControllers.add(TextEditingController(text: s));
      }
      for (final s in init.benefits) {
        _benefitItemControllers.add(TextEditingController(text: s));
      }
    }

    if (_descItemControllers.isEmpty) _descItemControllers.add(TextEditingController());
    if (_reqItemControllers.isEmpty) _reqItemControllers.add(TextEditingController());
    if (_benefitItemControllers.isEmpty) _benefitItemControllers.add(TextEditingController());

    _loadMasterSkema();
    _loadDynamicFilters();
  }

  Future<void> _loadDynamicFilters() async {
    try {
      final opts = await CareerExpoService.getFilterOptions();
      if (!mounted) return;
      final filtered = opts.workplaceTypes
          .where((e) => e.trim().isNotEmpty && e.toLowerCase() != 'semua')
          .toList();
      if (filtered.isNotEmpty) {
        setState(() {
          _workplaceTypes = filtered;
          if (!_workplaceTypes.contains(_workplaceType)) {
            _workplaceTypes.insert(0, _workplaceType);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMasterSkema() async {
    try {
      final list = await MasterService.getMasterSkemaList();
      if (!mounted) return;
      setState(() {
        _skemaList = list;
        _isLoadingSkema = false;
        if (widget.initialJob?.idSkema != null) {
          final found = list.where((s) => s.id == widget.initialJob!.idSkema);
          if (found.isNotEmpty) _selectedSkema = found.first;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSkema = false;
          _skemaLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _aboutCompanyController.dispose();
    _descriptionController.dispose();
    for (final c in _descItemControllers) {
      c.dispose();
    }
    for (final c in _reqItemControllers) {
      c.dispose();
    }
    for (final c in _benefitItemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file != null && file.path != null) {
        final path = file.path!;
        final name = file.name;
        setState(() {
          _filePdfName = name;
          _isUploadingPdf = true;
        });

        final res = await MagangHubService.uploadFile(path);
        if (!mounted) return;
        setState(() {
          _filePdfUrl = res['file_url'] ?? '';
          _isUploadingPdf = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dokumen PDF berhasil diunggah!'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file PDF: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submit(bool isDraft) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi field yang bertanda wajib.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final descList = _descItemControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final reqList = _reqItemControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final benefitList = _benefitItemControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    final payload = <String, dynamic>{
      'nama_pekerjaan': _titleController.text.trim(),
      'nama_perusahaan': _companyController.text.trim(),
      'kategori_perusahaan': _categoryController.text.trim(),
      'tentang_perusahaan': _aboutCompanyController.text.trim(),
      'deskripsi_lowongan': _descriptionController.text.trim(),
      'tipe_pekerjaan': 'Magang',
      'jenis_tempat': _workplaceType,
      'lokasi': _locationController.text.trim(),
      'salary_min': int.tryParse(_salaryMinController.text.trim()) ?? 0,
      'salary_max': int.tryParse(_salaryMaxController.text.trim()) ?? 0,
      'salary_period': 'bulan',
      'pengalaman': _experience,
      'pendidikan': _education,
      'poin_deskripsi': descList,
      'poin_persyaratan': reqList,
      'poin_benefit': benefitList,
      'file_pdf': _filePdfUrl,
      'status_lowongan': isDraft ? 'draft' : 'publish',
      'id_skema': _selectedSkema?.id ?? ((_skemaLoadFailed || _isLoadingSkema) ? widget.initialJob?.idSkema : null),
    };

    try {
      if (widget.initialJob != null) {
        await MagangHubService.updateMagang(widget.initialJob!.id, payload);
      } else {
        await MagangHubService.createMagang(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDraft
                ? 'Draft lowongan magang berhasil disimpan!'
                : (widget.initialJob != null
                    ? 'Lowongan magang berhasil diperbarui!'
                    : 'Lowongan magang berhasil diterbitkan!'),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final msg = e is DioException && e.response?.data is Map && e.response?.data['message'] != null
          ? e.response!.data['message'].toString()
          : 'Terjadi kesalahan saat menyimpan data.';
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
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: widget.initialJob != null ? 'Edit Info Magang' : 'Pasang Info Magang',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Informasi Perusahaan Mitra',
                      icon: Icons.apartment_rounded,
                      children: [
                        _buildTextField(
                          controller: _companyController,
                          label: 'Nama Perusahaan Mitra *',
                          hint: 'Contoh: PT Ruang Digital Kreatif',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama perusahaan wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _categoryController,
                          label: 'Bidang / Kategori Industri',
                          hint: 'Contoh: IT & Software / Digital Agency',
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _aboutCompanyController,
                          label: 'Tentang Perusahaan',
                          hint: 'Jelaskan profil ringkas perusahaan mitra...',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSectionCard(
                      title: 'Posisi & Detail Magang',
                      icon: Icons.school_outlined,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Judul / Posisi Magang *',
                          hint: 'Contoh: UI/UX Designer (Intern)',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Posisi magang wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          label: 'Sistem Kerja Magang',
                          value: _workplaceType,
                          items: _workplaceTypes,
                          onChanged: (v) => setState(() => _workplaceType = v!),
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _locationController,
                          label: 'Lokasi Kota / Daerah *',
                          hint: 'Contoh: Jakarta Selatan / Yogyakarta',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _salaryMinController,
                                label: 'Uang Saku Min (Rp)',
                                hint: 'Contoh: 1500000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _salaryMaxController,
                                label: 'Uang Saku Max (Rp)',
                                hint: 'Contoh: 3000000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Kualifikasi Pelamar',
                                value: _experience,
                                items: _experienceOptions,
                                onChanged: (v) => setState(() => _experience = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Min. Pendidikan',
                                value: _education,
                                items: _educationOptions,
                                onChanged: (v) => setState(() => _education = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Ringkasan Program Magang',
                          hint: 'Ringkasan singkat tentang program magang ini...',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Kualifikasi Skema LSP Terkait (Opsional)',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 6),
                        if (_isLoadingSkema)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(color: Color(0xFF7C3AED)),
                          )
                        else
                          DropdownButtonFormField<MasterSkema>(
                            initialValue: _selectedSkema,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                            items: [
                              const DropdownMenuItem<MasterSkema>(
                                value: null,
                                child: Text('Tidak mewajibkan skema khusus', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                              ),
                              ..._skemaList.map(
                                (s) => DropdownMenuItem<MasterSkema>(
                                  value: s,
                                  child: Text(s.namaSkema, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                            onChanged: (val) => setState(() => _selectedSkema = val),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildDynamicListSection(
                      title: 'Poin Deskripsi Tugas Magang',
                      controllers: _descItemControllers,
                      hint: 'Contoh: Membantu perancangan antarmuka aplikasi',
                    ),
                    const SizedBox(height: 18),
                    _buildDynamicListSection(
                      title: 'Poin Persyaratan Kualifikasi',
                      controllers: _reqItemControllers,
                      hint: 'Contoh: Mahasiswa aktif atau fresh graduate jurusan IT',
                    ),
                    const SizedBox(height: 18),
                    _buildDynamicListSection(
                      title: 'Poin Benefit & Fasilitas Magang',
                      controllers: _benefitItemControllers,
                      hint: 'Contoh: Sertifikat magang resmi, uang saku bulanan, mentoring',
                    ),
                    const SizedBox(height: 18),
                    // PDF Upload Card
                    _buildSectionCard(
                      title: 'Dokumen Kerangka Acuan / Flyer (PDF)',
                      icon: Icons.picture_as_pdf_rounded,
                      children: [
                        if (_filePdfName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _filePdfName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                                  onPressed: () => setState(() {
                                    _filePdfName = '';
                                    _filePdfUrl = '';
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isUploadingPdf ? null : _pickPdfFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7C3AED),
                            side: const BorderSide(color: Color(0xFF7C3AED)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isUploadingPdf
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.upload_file_rounded, size: 20),
                          label: Text(_isUploadingPdf ? 'Mengunggah...' : 'Pilih Berkas PDF'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Submit Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () => _submit(true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF94A3B8)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Simpan Draft', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : () => _submit(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    widget.initialJob != null ? 'Perbarui Info' : 'Publikasikan Magang',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicListSection({
    required String title,
    required List<TextEditingController> controllers,
    required String hint,
  }) {
    return _buildSectionCard(
      title: title,
      icon: Icons.format_list_bulleted_rounded,
      children: [
        ...List.generate(controllers.length, (idx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[idx],
                    decoration: InputDecoration(
                      hintText: '$hint (${idx + 1})',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                ),
                if (controllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 20),
                    onPressed: () => setState(() {
                      controllers[idx].dispose();
                      controllers.removeAt(idx);
                    }),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => setState(() => controllers.add(TextEditingController())),
          icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF7C3AED)),
          label: const Text('Tambah Poin', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
