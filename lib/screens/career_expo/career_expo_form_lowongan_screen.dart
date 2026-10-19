import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../models/master_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/common/master_service.dart';

/// Form Input & Edit Lowongan Pekerjaan Career Expo untuk Asesor / Rekruter
class CareerExpoFormLowonganScreen extends StatefulWidget {
  final CareerJobItem? initialJob;

  const CareerExpoFormLowonganScreen({
    super.key,
    this.initialJob,
  });

  @override
  State<CareerExpoFormLowonganScreen> createState() => _CareerExpoFormLowonganScreenState();
}

class _CareerExpoFormLowonganScreenState extends State<CareerExpoFormLowonganScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _aboutCompanyController;
  late TextEditingController _descriptionController;

  String _employmentType = 'Full Time';
  String _workplaceType = 'On Site';
  String _salaryPeriod = 'bulan';
  String _experience = '1 - 3 Tahun';
  String _education = 'S1';

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

  List<String> _employmentTypes = ['Full Time', 'Part Time', 'Magang', 'Kontrak', 'Freelance'];
  List<String> _workplaceTypes = ['On Site', 'Remote', 'Hybrid'];
  List<String> _experienceOptions = ['Fresh Graduate', '1 - 3 Tahun', '3 - 5 Tahun', '> 5 Tahun'];
  List<String> _educationOptions = ['SMA / SMK', 'D3', 'S1', 'S2', 'Semua Jurusan'];

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
    _descriptionController = TextEditingController(
      text: init?.shortDescription.isNotEmpty == true
          ? init!.shortDescription
          : (init?.jobDescription.isNotEmpty == true ? init!.jobDescription.first : ''),
    );
    if (init != null) {
      if (_employmentTypes.contains(init.employmentType)) {
        _employmentType = init.employmentType;
      } else if (init.employmentType.isNotEmpty) {
        _employmentTypes = [..._employmentTypes, init.employmentType];
        _employmentType = init.employmentType;
      }
      if (_workplaceTypes.contains(init.workplaceType)) {
        _workplaceType = init.workplaceType;
      } else if (init.workplaceType.isNotEmpty) {
        _workplaceTypes = [..._workplaceTypes, init.workplaceType];
        _workplaceType = init.workplaceType;
      }
      if (init.salaryPeriod.isNotEmpty) _salaryPeriod = init.salaryPeriod;
      if (_experienceOptions.contains(init.experience)) {
        _experience = init.experience;
      } else if (init.experience.isNotEmpty) {
        _experienceOptions = [..._experienceOptions, init.experience];
        _experience = init.experience;
      }
      if (_educationOptions.contains(init.education)) {
        _education = init.education;
      } else if (init.education.isNotEmpty) {
        _educationOptions = [..._educationOptions, init.education];
        _education = init.education;
      }
      _filePdfUrl = init.filePdfUrl;
      _filePdfName = init.filePdf.split(RegExp(r'[/\\]')).last;

      for (final d in init.jobDescription) {
        _descItemControllers.add(TextEditingController(text: d));
      }
      for (final r in init.requirements) {
        _reqItemControllers.add(TextEditingController(text: r));
      }
      for (final b in init.benefits) {
        _benefitItemControllers.add(TextEditingController(text: b));
      }
    }

    if (_descItemControllers.isEmpty) {
      _descItemControllers.add(TextEditingController());
    }
    if (_reqItemControllers.isEmpty) {
      _reqItemControllers.add(TextEditingController());
    }
    if (_benefitItemControllers.isEmpty) {
      _benefitItemControllers.add(TextEditingController());
    }

    _loadMasterSkema();
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

        final res = await CareerExpoService.uploadFile(path);
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
          content: Text('Harap lengkapi field yang bertanda bintang (*)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final poinDeskripsi = _descItemControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final poinPersyaratan = _reqItemControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final poinBenefit = _benefitItemControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final payload = {
      'nama_pekerjaan': _titleController.text.trim(),
      'nama_perusahaan': _companyController.text.trim(),
      'kategori_perusahaan': _categoryController.text.trim(),
      'tentang_perusahaan': _aboutCompanyController.text.trim(),
      'tipe_pekerjaan': _employmentType,
      'jenis_tempat': _workplaceType,
      'lokasi': _locationController.text.trim(),
      'salary_min': int.tryParse(_salaryMinController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      'salary_max': int.tryParse(_salaryMaxController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      'salary_period': _salaryPeriod,
      'pengalaman': _experience,
      'pendidikan': _education,
      'deskripsi_lowongan': _descriptionController.text.trim(),
      'poin_deskripsi': poinDeskripsi,
      'poin_persyaratan': poinPersyaratan,
      'poin_benefit': poinBenefit,
      'id_skema': _selectedSkema?.id ?? (_skemaLoadFailed || _isLoadingSkema ? widget.initialJob?.idSkema : null),
      'file_pdf': _filePdfUrl,
      'status_lowongan': isDraft ? 'draft' : 'publish',
    };

    setState(() => _isSubmitting = true);
    try {
      if (widget.initialJob != null) {
        await CareerExpoService.updateLowongan(widget.initialJob!.id, payload);
      } else {
        await CareerExpoService.createLowongan(payload);
      }
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDraft
                ? 'Lowongan berhasil disimpan sebagai draft.'
                : 'Lowongan pekerjaan berhasil dipublikasikan!',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      var msg = 'Gagal menyimpan lowongan.';
      if (e is DioException && e.response?.data is Map) {
        final d = e.response!.data as Map;
        if (d['message'] != null) msg = d['message'].toString();
        if (d['errors'] != null) msg = d['errors'].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialJob != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Lowongan' : 'Pasang Lowongan Baru',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('1. Informasi Posisi & Perusahaan'),
              const SizedBox(height: 12),
              _buildLabel('Posisi / Judul Pekerjaan *'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Contoh: Senior UI/UX Designer'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Posisi pekerjaan wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildLabel('Nama Perusahaan *'),
              TextFormField(
                controller: _companyController,
                decoration: _inputDecoration('Contoh: PT Digital Inovasi Asia'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama perusahaan wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildLabel('Kategori Industri / Bidang'),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration('Contoh: Teknologi Informasi & Software'),
              ),
              const SizedBox(height: 14),
              _buildLabel('Lokasi Penempatan *'),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Contoh: Jakarta Selatan, DKI Jakarta'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('2. Tipe & Skema Sertifikasi'),
              const SizedBox(height: 12),
              _buildLabel('Tipe Pekerjaan'),
              Wrap(
                spacing: 8,
                children: _employmentTypes.map((type) {
                  final isSelected = _employmentType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _employmentType = type),
                    selectedColor: const Color(0xFF0066F6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _buildLabel('Tipe Tempat Kerja'),
              Wrap(
                spacing: 8,
                children: _workplaceTypes.map((type) {
                  final isSelected = _workplaceType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _workplaceType = type),
                    selectedColor: const Color(0xFF0066F6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _buildLabel('Kualifikasi Skema Sertifikasi LSP (Opsional)'),
              if (_isLoadingSkema)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(color: Color(0xFF0066F6)),
                )
              else
                DropdownButtonFormField<MasterSkema>(
                  initialValue: _selectedSkema,
                  isExpanded: true,
                  decoration: _inputDecoration('Pilih skema sertifikasi terkait'),
                  items: [
                    const DropdownMenuItem<MasterSkema>(
                      value: null,
                      child: Text('Tidak mewajibkan skema khusus', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ..._skemaList.map(
                      (s) => DropdownMenuItem<MasterSkema>(
                        value: s,
                        child: Text(s.namaSkema, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedSkema = val),
                ),

              const SizedBox(height: 24),
              _buildSectionHeader('3. Gaji & Kualifikasi'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gaji Min (Rp)'),
                        TextFormField(
                          controller: _salaryMinController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Mis. 6000000'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gaji Max (Rp)'),
                        TextFormField(
                          controller: _salaryMaxController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Mis. 10000000'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Periode'),
                        DropdownButtonFormField<String>(
                          initialValue: _salaryPeriod,
                          decoration: _inputDecoration(''),
                          items: const [
                            DropdownMenuItem(value: 'bulan', child: Text('Bulan', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'tahun', child: Text('Tahun', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'proyek', child: Text('Proyek', style: TextStyle(fontSize: 12.5))),
                          ],
                          onChanged: (val) => setState(() => _salaryPeriod = val ?? 'bulan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Pengalaman Minimal'),
                        DropdownButtonFormField<String>(
                          initialValue: _experience,
                          decoration: _inputDecoration(''),
                          items: _experienceOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => setState(() => _experience = val ?? _experience),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Pendidikan Minimal'),
                        DropdownButtonFormField<String>(
                          initialValue: _education,
                          decoration: _inputDecoration(''),
                          items: _educationOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => setState(() => _education = val ?? _education),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('4. Deskripsi & Detail Pekerjaan'),
              const SizedBox(height: 12),
              _buildLabel('Ringkasan Posisi'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Tuliskan ringkasan singkat perihal peran ini...'),
              ),
              const SizedBox(height: 16),
              _buildDynamicListSection(
                title: 'Tanggung Jawab Pekerjaan',
                controllers: _descItemControllers,
                hintText: 'Contoh: Mengembangkan fitur aplikasi mobile',
              ),
              const SizedBox(height: 16),
              _buildDynamicListSection(
                title: 'Persyaratan & Kualifikasi',
                controllers: _reqItemControllers,
                hintText: 'Contoh: Menguasai Flutter & REST API',
              ),
              const SizedBox(height: 16),
              _buildDynamicListSection(
                title: 'Benefit & Fasilitas',
                controllers: _benefitItemControllers,
                hintText: 'Contoh: BPJS Ketenagakerjaan & Kesehatan',
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('5. Dokumen Lowongan (PDF Rekruter)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF0066F6), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _filePdfName.isNotEmpty ? _filePdfName : 'Belum ada dokumen PDF',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isUploadingPdf
                                    ? 'Mengunggah file ke server...'
                                    : 'Lampirkan Brosur / TOR / Syarat Tambahan (PDF)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isUploadingPdf ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_filePdfName.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFEF4444)),
                            onPressed: () {
                              setState(() {
                                _filePdfName = '';
                                _filePdfUrl = '';
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploadingPdf ? null : _pickPdfFile,
                        icon: _isUploadingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066F6)),
                              )
                            : const Icon(Icons.upload_file_rounded, size: 18),
                        label: Text(_isUploadingPdf ? 'Mengunggah...' : 'Pilih Berkas PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066F6),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => _submit(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan Draft', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _submit(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Publikasikan Lowongan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF0066F6), width: 1.5),
      ),
    );
  }

  Widget _buildDynamicListSection({
    required String title,
    required List<TextEditingController> controllers,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(title),
            TextButton.icon(
              onPressed: () {
                setState(() => controllers.add(TextEditingController()));
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF0066F6)),
              label: const Text('Tambah', style: TextStyle(fontSize: 12, color: Color(0xFF0066F6))),
            ),
          ],
        ),
        ...controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: _inputDecoration('$hintText (${index + 1})'),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    onPressed: () {
                      setState(() {
                        controllers.removeAt(index).dispose();
                      });
                    },
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
