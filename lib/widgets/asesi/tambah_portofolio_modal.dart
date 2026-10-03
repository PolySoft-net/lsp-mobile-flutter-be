import 'package:file_picker/file_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/asesi/asesi_portofolio_model.dart';
import '../../services/asesi/asesi_portofolio_service.dart';

class TambahPortofolioModal extends StatefulWidget {
  final ValueChanged<AsesiPortofolioItem>? onCreated;

  const TambahPortofolioModal({super.key, this.onCreated});

  static Future<AsesiPortofolioItem?> show(BuildContext context) {
    return showModalBottomSheet<AsesiPortofolioItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TambahPortofolioModal(),
    );
  }

  @override
  State<TambahPortofolioModal> createState() => _TambahPortofolioModalState();
}

class _TambahPortofolioModalState extends State<TambahPortofolioModal> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _linkController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // 'link', 'dokumen', 'gambar'
  String _selectedTipe = 'link';
  DateTime _selectedDate = DateTime.now();
  String? _localFilePath;
  String? _localFileName;
  bool _submitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _linkController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFile() async {
    try {
      final allowedExt = _selectedTipe == 'gambar'
          ? const ['jpg', 'jpeg', 'png', 'webp']
          : const ['pdf', 'doc', 'docx'];

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExt,
      );

      if (result.isNotEmpty) {
        final f = result.first;
        if (f.path != null) {
          setState(() {
            _localFilePath = f.path;
            _localFileName = f.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih berkas: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTipe != 'link' && (_localFilePath == null || _localFilePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan pilih berkas ${_selectedTipe == "gambar" ? "foto/gambar" : "dokumen PDF"} terlebih dahulu',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    try {
      AsesiPortofolioItem? item;
      if (_selectedTipe == 'link') {
        item = await AsesiPortofolioService.createPortofolioLink(
          judul: _judulController.text,
          linkUrl: _linkController.text,
          tanggal: dateStr,
          deskripsi: _deskripsiController.text,
        );
      } else {
        item = await AsesiPortofolioService.createPortofolioFile(
          judul: _judulController.text,
          filePath: _localFilePath!,
          tanggal: dateStr,
          deskripsi: _deskripsiController.text,
          tipe: _selectedTipe,
        );
      }

      if (mounted && item != null) {
        widget.onCreated?.call(item);
        Navigator.of(context).pop(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portofolio berhasil ditambahkan'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan portofolio: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateDisplay =
        '${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle drag bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Portofolio Asesi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Pilihan Bentuk Bukti
              const Text(
                'Bentuk Bukti Portofolio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _tipeChip(
                      value: 'link',
                      label: 'Link / Tautan',
                      icon: LucideIcons.link,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tipeChip(
                      value: 'dokumen',
                      label: 'Dokumen',
                      icon: LucideIcons.file_text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tipeChip(
                      value: 'gambar',
                      label: 'Gambar / Foto',
                      icon: LucideIcons.image,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Judul Portofolio
              const Text(
                'Judul Portofolio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _judulController,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: _selectedTipe == 'link'
                      ? 'Misal: Source Code GitHub Sistem POS'
                      : (_selectedTipe == 'dokumen'
                          ? 'Misal: Surat Pengalaman Kerja / Kontrak'
                          : 'Misal: Foto Dokumentasi Pekerjaan'),
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul portofolio wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // 3. Input Bukti Dinamis (Link vs Upload File)
              if (_selectedTipe == 'link') ...[
                const Text(
                  'Tautan URL Portofolio',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.globe, size: 18, color: Color(0xFF64748B)),
                    hintText: 'https://github.com/username/project',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Alamat tautan link wajib diisi';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Text(
                  _selectedTipe == 'gambar' ? 'Unggah Foto Bukti' : 'Unggah Dokumen (PDF/DOC)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _localFilePath != null ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedTipe == 'gambar' ? LucideIcons.image : LucideIcons.file_up,
                          color: _localFilePath != null ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localFileName ?? 'Pilih berkas dari perangkat...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _localFileName != null
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedTipe == 'gambar' ? 'Format JPG, PNG (Maks 10MB)' : 'Format PDF, DOC (Maks 10MB)',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Pilih',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 4. Tanggal Terakhir Update / Aktif Bekerja
              const Text(
                'Tanggal Terakhir Update / Bekerja',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Text(
                        dateDisplay,
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 5. Deskripsi Portofolio
              const Text(
                'Deskripsi Portofolio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Jelaskan isi portofolio ini, fitur yang dibuat, atau peran Anda dalam proyek...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi portofolio wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Simpan Portofolio',
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

  Widget _tipeChip({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedTipe == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTipe = value;
          _localFilePath = null;
          _localFileName = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
