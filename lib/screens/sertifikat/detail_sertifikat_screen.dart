import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/upload_file_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/api_service.dart';
import '../../utils/date_format_helper.dart';

class DetailSertifikatScreen extends StatefulWidget {
  final SertifikatItem item;
  final bool isAsesiView;

  const DetailSertifikatScreen({
    super.key,
    required this.item,
    this.isAsesiView = false,
  });

  @override
  State<DetailSertifikatScreen> createState() => _DetailSertifikatScreenState();
}

class _DetailSertifikatScreenState extends State<DetailSertifikatScreen> {
  final List<Map<String, dynamic>> _uploadedFiles = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png'],
      );

      if (files.isNotEmpty) {
        final validFiles = await UploadFileValidator.filterValid(
          messenger,
          files,
          UploadFileValidator.certificateMaxMB,
        );
        if (!mounted) {
          return;
        }
        for (var file in validFiles) {
          if (!_uploadedFiles.any((f) => f['name'] == file.name)) {
            final fileLength = (await file.length()) ?? 0;
            final double kb = fileLength / 1024;
            final double mb = kb / 1024;
            final String sizeStr = mb >= 1
                ? '${mb.toStringAsFixed(1)} MB'
                : '${kb.toStringAsFixed(1)} KB';
            setState(() {
              _uploadedFiles.add({
                'name': file.name,
                'size': sizeStr,
                'path': file.path,
                'status': 'pending',
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses file ditolak atau tidak ada file dipilih.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _uploadFiles() async {
    final pendingFiles = _uploadedFiles
        .where((f) => f['status'] == 'pending')
        .toList();
    if (pendingFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      for (var file in _uploadedFiles) {
        if (file['status'] == 'pending') {
          file['status'] = 'uploading';
        }
      }
    });

    try {
      final List<String> filePaths = [];
      for (var file in pendingFiles) {
        if (file['path'] != null) {
          filePaths.add(file['path'] as String);
        }
      }

      if (filePaths.isEmpty) {
        setState(() {
          _isUploading = false;
          for (var file in _uploadedFiles) {
            if (file['status'] == 'uploading') {
              file['status'] = 'pending';
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada berkas fisik valid untuk diunggah.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final res = await AsesiService.uploadTtd(widget.item.id, filePaths);
      if (!mounted) return;

      setState(() {
        _isUploading = false;
        if (res != null) {
          for (var file in _uploadedFiles) {
            if (file['status'] == 'uploading') {
              file['status'] = 'success';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Dokumen foto & tanda tangan berhasil diunggah!'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          for (var file in _uploadedFiles) {
            if (file['status'] == 'uploading') {
              file['status'] = 'failed';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah beberapa berkas.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error uploading files: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
          for (var file in _uploadedFiles) {
            if (file['status'] == 'uploading') {
              file['status'] = 'failed';
            }
          }
        });
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Detail Sertifikat',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Profil Sertifikasi'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow(
                      'Nama Pemegang Sertifikat',
                      widget.item.pemegang,
                      Icons.person_outline_rounded,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Nama Skema',
                      widget.item.skema,
                      Icons.assignment_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Tempat Uji (TUK)',
                      widget.item.tempatUji,
                      Icons.business_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Asesor',
                      widget.item.namaAsesor,
                      Icons.record_voice_over_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Nama Jadwal Asesmen',
                      widget.item.namaJadwal,
                      Icons.event_note_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Tanggal Asesmen',
                      widget.item.tanggalAsesmen,
                      Icons.event_available_outlined,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Kodifikasi'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow(
                      'No. Registrasi',
                      widget.item.nomorRegistrasi,
                      Icons.badge_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'No. Sertifikat',
                      widget.item.nomorSertifikat,
                      Icons.workspace_premium_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'No. Blanko',
                      widget.item.nomorBlanko,
                      Icons.description_outlined,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Masa Berlaku'),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildInfoRow(
                      'Tanggal Terbit',
                      widget.item.tanggalTerbit,
                      Icons.calendar_today_outlined,
                    ),
                    _buildInfoDivider(),
                    _buildInfoRow(
                      'Berlaku Sampai',
                      widget.item.tanggalBerlaku,
                      Icons.event_busy_outlined,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _buildFootnoteCard(),
                  const SizedBox(height: 24),

                  if (widget.isAsesiView) ...[
                    _buildUploadSection(),
                    const SizedBox(height: 24),
                  ],

                  _buildDownloadButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    bool isActive = widget.item.status.toLowerCase() == 'aktif';
    bool isPending = widget.item.status.toLowerCase() == 'akan_kadaluarsa';

    Color bannerColor = isActive
        ? const Color(0xFF10B981)
        : (isPending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    Color bannerBgColor = isActive
        ? const Color(0xFFECFDF5)
        : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));
    String statusText = isActive
        ? 'Sertifikat Aktif'
        : (isPending ? 'Sertifikat Akan Berakhir' : 'Sertifikat Kadaluarsa');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bannerBgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: bannerColor.withAlpha(76)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive
                      ? Icons.check_circle_outline_rounded
                      : (isPending
                            ? Icons.warning_amber_rounded
                            : Icons.cancel_outlined),
                  color: bannerColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.item.pemegang,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Nama Skema: ${widget.item.skema}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }

  String _sisaHariText(String tanggal) {
    final int days = DateFormatHelper.daysFromNow(tanggal);
    if (days <= 0) return 'Tidak berlaku lagi';
    return '$days hari';
  }

  Widget _buildFootnoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Keterangan: Sertifikat ini akan berakhir dalam ${_sisaHariText(widget.item.tanggalBerlaku)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.drive_folder_upload_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Upload Foto & TTD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Unggah berkas foto Anda yang sudah dilengkapi tanda tangan. Format berkas wajib berupa PDF atau PNG (mendukung multi-file).',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _isUploading ? null : _pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withAlpha(76),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF3B82F6),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih Berkas PDF / PNG',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maksimal ukuran berkas 5MB',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_uploadedFiles.isNotEmpty) ...[
            const Text(
              'Berkas Terpilih:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _uploadedFiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = _uploadedFiles[index];
                final isSuccess = file['status'] == 'success';
                final isFileUploading = file['status'] == 'uploading';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSuccess
                          ? const Color(0xFF10B981).withAlpha(76)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        file['name'].toString().toLowerCase().endsWith('.pdf')
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_rounded,
                        color:
                            file['name'].toString().toLowerCase().endsWith(
                              '.pdf',
                            )
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF3B82F6),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              file['size'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isFileUploading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF3B82F6),
                          ),
                        )
                      else if (isSuccess)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          onPressed: _isUploading
                              ? null
                              : () => _removeFile(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          if (_uploadedFiles.any((f) => f['status'] == 'pending'))
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadFiles,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.drive_folder_upload_rounded, size: 18),
                label: Text(
                  _isUploading ? 'Mengunggah...' : 'Unggah Dokumen',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

          if (_uploadedFiles.isNotEmpty &&
              _uploadedFiles.every((f) => f['status'] == 'success'))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(76),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Semua berkas foto & tanda tangan telah terunggah.',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Menghubungi server untuk unduh ${widget.item.skema}...',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );

            final url = await AsesiService.downloadSertifikat(widget.item.id);
            if (url != null && url.isNotEmpty) {
              final uri = Uri.parse(url);
              try {
                if (await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  return; // Success
                }
                if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                  return; // Fallback success
                }
              } catch (e) {
                // Launch failed for both modes
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka link download.'),
                    backgroundColor: Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sertifikat belum dapat diunduh.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error downloading certificate: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terjadi kesalahan saat mengunduh.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.download_rounded, size: 20),
        label: const Text(
          'Download Sertifikat',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9FD8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
