import 'package:file_picker/file_picker.dart';
import '../../utils/upload_file_validator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/instrumen_asesmen_models.dart';
import '../../services/asesor/asesor_service.dart';

class IA04AInstruksiTerstrukturWidget extends StatefulWidget {
  final IA04AData? data;
  final Function(String umpanBalik) onSave;

  const IA04AInstruksiTerstrukturWidget({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  State<IA04AInstruksiTerstrukturWidget> createState() =>
      _IA04AInstruksiTerstrukturWidgetState();
}

class _IA04AInstruksiTerstrukturWidgetState
    extends State<IA04AInstruksiTerstrukturWidget> {
  late TextEditingController _umpanBalikController;
  bool _isSaving = false;
  bool _isUploadingFile = false;
  @override
  void initState() {
    super.initState();
    _umpanBalikController = TextEditingController(
      text: widget.data?.umpanBalikDit ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant IA04AInstruksiTerstrukturWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data?.umpanBalikDit != widget.data?.umpanBalikDit) {
      _umpanBalikController.text = widget.data?.umpanBalikDit ?? '';
    }
  }

  @override
  void dispose() {
    _umpanBalikController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    final d = widget.data;
    if (d == null || d.asesiId == 0) return;

    try {
      final messenger = ScaffoldMessenger.of(context);
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'png',
          'jpg',
          'jpeg',
          'zip',
          'doc',
          'docx',
          'rar',
        ],
      );

      if (result.isNotEmpty && result.first.path != null) {
        final file = result.first;
        final valid = await UploadFileValidator.isValid(
          messenger,
          file,
          UploadFileValidator.ia04EvidenceMaxMB,
        );
        if (!mounted || !valid) {
          return;
        }
        setState(() => _isUploadingFile = true);

        final res = await AsesorService.uploadIA04(
          asesiId: d.asesiId,
          filePath: file.path!,
          fileName: file.name,
        );

        if (mounted) {
          setState(() => _isUploadingFile = false);
          if (res != null && res['data'] != null) {
            final fileName = res['data']['file_name']?.toString() ?? file.name;
            final fileUrl = res['data']['file_url']?.toString();
            setState(() {
              d.fileTugasDit = fileName;
              d.fileUrl = fileUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Berkas tugas FR.IA.04A berhasil diunggah.'),
                backgroundColor: Color(0xFF16A34A),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Gagal mengunggah berkas tugas.'),
                backgroundColor: Color(0xFFDC2626),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Terjadi kesalahan: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    String text = htmlString;
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</td>', caseSensitive: false), '  ');
    text = text.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  void _copyInstruction() {
    final cleanInstruksi = _cleanHtml(widget.data?.instruksiDit ?? '');
    final cleanDemo = _cleanHtml(widget.data?.demonstrasiDit ?? '');
    final text =
        '''
INSTRUKSI TERSTRUKTUR (DIT) - ${widget.data?.skema ?? ''}
Peserta: ${widget.data?.namaAsesi ?? ''}

--- SKENARIO PROYEK (STAR) ---
$cleanInstruksi

--- HAL YANG PERLU DIDEMONSTRASIKAN / DIPRESENTASIKAN ---
$cleanDemo
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Instruksi DIT berhasil disalin ke clipboard!'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    if (d == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Data FR.IA.04A belum tersedia untuk skema ini.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF84CC16)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.file_text, color: Color(0xFF4D7C0F), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FR.IA.04A. DIT – DAFTAR INSTRUKSI TERSTRUKTUR',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F6212),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Info Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Asesi', d.namaAsesi),
                _buildInfoRow('Skema', d.skema),
                if (d.durasi.isNotEmpty)
                  _buildInfoRow('Waktu Pengerjaan', d.durasi),
                if (d.penyusun.isNotEmpty)
                  _buildInfoRow('Penyusun', d.penyusun),
                if (d.noStMapa.isNotEmpty)
                  _buildInfoRow('No. ST MAPA', d.noStMapa),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tabel Unit Kompetensi
          if (d.units.isNotEmpty) ...[
            const Text(
              'Daftar Unit Kompetensi Yang Diujikan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Table(
                  border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FixedColumnWidth(110),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                      children: [
                        _buildTableHeader('No.'),
                        _buildTableHeader('Kode Unit'),
                        _buildTableHeader('Judul Unit'),
                      ],
                    ),
                    ...d.units.asMap().entries.map((entry) {
                      final i = entry.key;
                      final u = entry.value;
                      return TableRow(
                        children: [
                          _buildTableCell('${i + 1}', center: true),
                          _buildTableCell(u['kode_unit'] ?? '', isBold: true),
                          _buildTableCell(u['judul_unit'] ?? ''),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Skenario Proyek STAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 18,
                      color: Color(0xFF0D9488),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Skenario Proyek / Instruksi Terstruktur (STAR)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Text(
                  d.instruksiDit.isNotEmpty
                      ? _cleanHtml(d.instruksiDit)
                      : 'Instruksi terstruktur belum didefinisikan.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF334155),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hal yang perlu Didemonstrasikan
          if (d.demonstrasiDit.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.presentation,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hal yang Perlu Didemonstrasikan / Dipresentasikan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Text(
                    _cleanHtml(d.demonstrasiDit),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons: Kirim Instruksi & Copy
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyInstruction,
                  icon: const Icon(LucideIcons.copy, size: 15),
                  label: const Text('Copy Instruksi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D9488),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // File Upload Tugas DIT Asesi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.file_archive,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File Tugas DIT Asesi:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.fileTugasDit,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (d.fileUrl != null && d.fileUrl!.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          LucideIcons.download,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                        tooltip: 'Unduh Berkas',
                        onPressed: () async {
                          final uri = Uri.parse(d.fileUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingFile ? null : _pickAndUploadFile,
                    icon: _isUploadingFile
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.upload, size: 15),
                    label: Text(
                      _isUploadingFile
                          ? 'Mengunggah...'
                          : (d.fileTugasDit != 'Belum Upload Tugas DIT'
                                ? 'Ganti Berkas Tugas DIT'
                                : 'Unggah Berkas Tugas DIT'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D9488),
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Umpan Balik Asesor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Umpan Balik Untuk Asesi:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _umpanBalikController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Tulis umpan balik pelaksanaan tugas DIT untuk asesi...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            await widget.onSave(_umpanBalikController.text);
                            if (mounted) setState(() => _isSaving = false);
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.save, size: 15),
                    label: Text(
                      _isSaving ? 'Menyimpan...' : 'Simpan Umpan Balik DIT',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isBold = false,
    bool center = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: const Color(0xFF334155),
        ),
        textAlign: center ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
