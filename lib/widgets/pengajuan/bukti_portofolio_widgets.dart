// ============================================================================
// Bukti Portofolio Widgets
//
// Bottom sheet upload file/tautan + kartu item portofolio. Diekstrak dari
// bukti_portofolio_screen.dart.
// ============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../utils/upload_file_validator.dart';

/// Bottom sheet upload berkas portofolio (file picker + preview).
class PortfolioUploadSheet extends StatefulWidget {
  final String docKey;
  final String docLabel;
  final String description;
  final void Function(String key, String fileName, String filePath) onUploaded;

  const PortfolioUploadSheet({
    super.key,
    required this.docKey,
    required this.docLabel,
    required this.description,
    required this.onUploaded,
  });

  @override
  State<PortfolioUploadSheet> createState() => _PortfolioUploadSheetState();
}

class _PortfolioUploadSheetState extends State<PortfolioUploadSheet> {
  String? _localFileName;
  String? _localFilePath;
  bool _isPicking = false;

  Future<void> _pickRealFile() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (file == null) {
        return;
      }
      final valid = await UploadFileValidator.isValid(
        messenger,
        file,
        UploadFileValidator.asesiDocMaxMB,
      );
      if (!mounted || !valid) {
        return;
      }
      final path = file.path!;
      setState(() {
        _localFileName = file.name;
        _localFilePath = path;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal pilih file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Portofolio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF378CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.docLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF378CE7),
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  _localFileName ?? 'Tidak ada file terpilih',
                  style: TextStyle(
                    fontSize: 13,
                    color: _localFileName != null
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF64748B),
                    fontWeight: _localFileName != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: _isPicking
                        ? null
                        : () async {
                            setState(() => _isPicking = true);
                            await _pickRealFile();
                            if (!mounted) return;
                            setState(() => _isPicking = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AADEF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isPicking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Pilih File',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFED8936), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Format : PDF, JPG, PNG. Maksimal 2MB',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCBD5E1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _localFileName == null || _localFilePath == null
                        ? null
                        : () {
                            final name = _localFileName!;
                            final path = _localFilePath!;
                            Navigator.pop(context);
                            widget.onUploaded(widget.docKey, name, path);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      disabledForegroundColor: Colors.white60,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Bottom sheet simpan tautan portofolio / GitHub.
class PortfolioLinkSheet extends StatefulWidget {
  final String docKey;
  final String initialText;
  final void Function(String key, bool isUploaded, String? value) onSaved;

  const PortfolioLinkSheet({
    super.key,
    required this.docKey,
    required this.initialText,
    required this.onSaved,
  });

  @override
  State<PortfolioLinkSheet> createState() => _PortfolioLinkSheetState();
}

class _PortfolioLinkSheetState extends State<PortfolioLinkSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Simpan Tautan Portofolio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan tautan GitHub atau URL portofolio karya Anda:',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Tautan Portofolio / GitHub',
              hintText: 'https://github.com/username/project',
              prefixIcon: const Icon(Icons.link, color: Color(0xFF378CE7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF378CE7),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final val = _controller.text.trim();
                    widget.onSaved(
                      widget.docKey,
                      val.isNotEmpty,
                      val.isNotEmpty ? val : null,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378CE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu item portofolio (status + tombol upload/edit).
class PortfolioItemCard extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool isLink;
  final String? hint;
  final String? comment;
  final bool isUploaded;
  final String? fileName;
  final String statusText;
  final VoidCallback onUploadTap;
  final VoidCallback onLinkTap;

  const PortfolioItemCard({
    super.key,
    required this.label,
    required this.isRequired,
    required this.isLink,
    this.hint,
    this.comment,
    required this.isUploaded,
    this.fileName,
    required this.statusText,
    required this.onUploadTap,
    required this.onLinkTap,
  });

  (Color, Color) _badgeColors(String statusText) {
    switch (statusText) {
      case 'Terverifikasi':
        return (const Color(0xFFC6F6D5), const Color(0xFF22543D));
      case 'Ditolak':
        return (const Color(0xFFFED7D7), const Color(0xFF9B2C2C));
      case 'Menunggu Verifikasi':
        return (const Color(0xFFFEEBC8), const Color(0xFF7B341E));
      case 'Belum Diunggah':
      default:
        return (const Color(0xFFEDF2F7), const Color(0xFF4A5568));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (badgeBgColor, badgeTextColor) = _badgeColors(statusText);

    String? rejectionComment;
    if (statusText == 'Ditolak') {
      rejectionComment = comment;
    }

    final bool isUnuploaded = statusText == 'Belum Diunggah' && !isUploaded;
    final Color buttonBgColor = isUnuploaded
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF378CE7);
    final Color buttonTextColor = isUnuploaded
        ? const Color(0xFF64748B)
        : Colors.white;

    String buttonLabel = isLink ? 'Simpan Tautan' : 'Unggah Dokumen';
    if (!isUnuploaded) {
      if (isLink) {
        buttonLabel = 'Edit Tautan';
      } else if (statusText == 'Ditolak') {
        buttonLabel = 'Unggah Ulang';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontFamily: 'Inter',
              ),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isLink ? Icons.language : Icons.description_outlined,
                  color: const Color(0xFF378CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Status :   ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (rejectionComment != null &&
                        rejectionComment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '($rejectionComment)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (fileName != null &&
                        fileName!.isNotEmpty &&
                        !isUnuploaded) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File     :   ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Expanded(
                            child: isLink
                                ? Text(
                                    fileName!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1976D2),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    fileName!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isLink ? onLinkTap : onUploadTap,
              icon: Icon(
                isLink
                    ? (isUnuploaded ? Icons.link_rounded : Icons.edit_rounded)
                    : Icons.cloud_upload_outlined,
                color: buttonTextColor,
                size: 18,
              ),
              label: Text(
                buttonLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: buttonTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (hint != null && isUnuploaded) ...[
            const SizedBox(height: 10),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
