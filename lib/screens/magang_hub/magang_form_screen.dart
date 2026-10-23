import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../models/master_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/common/master_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../widgets/common/company_logo_upload_field.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/magang_form_fields.dart';

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
  String _companyLogo = '';
  bool _isUploadingPdf = false;
  bool _isUploadingLogo = false;
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
      _companyLogo = init.companyLogo;
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

  Future<void> _pickLogoFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      if (!mounted || file == null || file.path == null) return;
      setState(() => _isUploadingLogo = true);

      final res = await MagangHubService.uploadFile(file.path!);
      if (!mounted) return;
      final url = Uri.parse((res['file_url'] ?? '').trim()).path;
      setState(() {
        if (url.isNotEmpty) _companyLogo = url;
        _isUploadingLogo = false;
      });
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengunggah logo. Coba lagi.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo perusahaan berhasil diunggah!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah logo: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit(bool isDraft) async {
    if (_isUploadingLogo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tunggu proses unggah logo selesai.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_companyLogo.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo perusahaan wajib diunggah (JPG/PNG).'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
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
      'company_logo': _companyLogo.trim(),
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

  void _addPoint(List<TextEditingController> controllers) {
    setState(() => controllers.add(TextEditingController()));
  }

  void _removePoint(List<TextEditingController> controllers, int index) {
    setState(() {
      controllers[index].dispose();
      controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: widget.initialJob != null ? 'Edit Info Magang' : 'Pasang Info Magang',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MagangFormSection(
                        title: 'Informasi Perusahaan Mitra',
                        icon: Icons.apartment_rounded,
                        children: [
                          MagangFormTextField(
                            controller: _companyController,
                            label: 'Nama Perusahaan Mitra *',
                            hint: 'Contoh: PT Ruang Digital Kreatif',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nama perusahaan wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          MagangFormLabel('Logo Perusahaan (JPG/PNG) *'),
                          const SizedBox(height: 6),
                          CompanyLogoUploadField(
                            imageUrl: _companyLogo,
                            isUploading: _isUploadingLogo,
                            onPick: _pickLogoFile,
                            onClear: () => setState(() => _companyLogo = ''),
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _categoryController,
                            label: 'Bidang / Kategori Industri',
                            hint: 'Contoh: IT & Software / Digital Agency',
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _aboutCompanyController,
                            label: 'Tentang Perusahaan',
                            hint: 'Jelaskan profil ringkas perusahaan mitra...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      MagangFormSection(
                        title: 'Posisi & Detail Magang',
                        icon: Icons.school_outlined,
                        children: [
                          MagangFormTextField(
                            controller: _titleController,
                            label: 'Judul / Posisi Magang *',
                            hint: 'Contoh: UI/UX Designer (Intern)',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Posisi magang wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          MagangFormDropdownField(
                            label: 'Sistem Kerja Magang',
                            value: _workplaceType,
                            items: _workplaceTypes,
                            onChanged: (v) => setState(() => _workplaceType = v!),
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _locationController,
                            label: 'Lokasi Kota / Daerah *',
                            hint: 'Contoh: Jakarta Selatan / Yogyakarta',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _salaryMinController,
                            label: 'Uang Saku Min (Rp)',
                            hint: 'Contoh: 1500000',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _salaryMaxController,
                            label: 'Uang Saku Max (Rp)',
                            hint: 'Contoh: 3000000',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          MagangFormDropdownField(
                            label: 'Kualifikasi Pelamar',
                            value: _experience,
                            items: _experienceOptions,
                            onChanged: (v) => setState(() => _experience = v!),
                          ),
                          const SizedBox(height: 14),
                          MagangFormDropdownField(
                            label: 'Min. Pendidikan',
                            value: _education,
                            items: _educationOptions,
                            onChanged: (v) => setState(() => _education = v!),
                          ),
                          const SizedBox(height: 14),
                          MagangFormTextField(
                            controller: _descriptionController,
                            label: 'Ringkasan Program Magang',
                            hint: 'Ringkasan singkat tentang program magang ini...',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          MagangFormSkemaField(
                            isLoading: _isLoadingSkema,
                            skemaList: _skemaList,
                            selected: _selectedSkema,
                            onChanged: (val) => setState(() => _selectedSkema = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      MagangFormPointList(
                        title: 'Poin Deskripsi Tugas Magang',
                        controllers: _descItemControllers,
                        hint: 'Contoh: Membantu perancangan antarmuka aplikasi',
                        onAdd: () => _addPoint(_descItemControllers),
                        onRemove: (idx) => _removePoint(_descItemControllers, idx),
                      ),
                      const SizedBox(height: 14),
                      MagangFormPointList(
                        title: 'Poin Persyaratan Kualifikasi',
                        controllers: _reqItemControllers,
                        hint: 'Contoh: Mahasiswa aktif atau fresh graduate jurusan IT',
                        onAdd: () => _addPoint(_reqItemControllers),
                        onRemove: (idx) => _removePoint(_reqItemControllers, idx),
                      ),
                      const SizedBox(height: 14),
                      MagangFormPointList(
                        title: 'Poin Benefit & Fasilitas Magang',
                        controllers: _benefitItemControllers,
                        hint: 'Contoh: Sertifikat magang resmi, uang saku bulanan, mentoring',
                        onAdd: () => _addPoint(_benefitItemControllers),
                        onRemove: (idx) => _removePoint(_benefitItemControllers, idx),
                      ),
                      const SizedBox(height: 14),
                      MagangPdfUploadSection(
                        fileName: _filePdfName,
                        isUploading: _isUploadingPdf,
                        onPick: _pickPdfFile,
                        onClear: () => setState(() {
                          _filePdfName = '';
                          _filePdfUrl = '';
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MagangFormActions(
              isSubmitting: _isSubmitting,
              isEditing: widget.initialJob != null,
              onSaveDraft: () => _submit(true),
              onPublish: () => _submit(false),
            ),
          ],
        ),
      ),
    );
  }
}
