import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/number_format_helper.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../career_expo/career_expo_apply_screen.dart';
import 'magang_form_screen.dart';

/// Detail lowongan magang dengan aksi sesuai pemilik dan status lamaran.
class MagangDetailScreen extends StatefulWidget {
  final CareerJobItem job;
  final String? applicationStatus;

  const MagangDetailScreen({
    super.key,
    required this.job,
    this.applicationStatus,
  });

  @override
  State<MagangDetailScreen> createState() => _MagangDetailScreenState();
}

class _MagangDetailScreenState extends State<MagangDetailScreen> {
  late CareerJobItem _job;
  late bool _isBookmarked;
  late bool _isApplied;
  String _applicationStatus = '';
  bool _isAboutExpanded = false;
  bool _hasEdited = false;

  bool get _isCreator {
    final currentUserId = AuthRepository.currentUserInstance?.id;
    return currentUserId != null &&
        _job.createdBy.isNotEmpty &&
        _job.createdBy == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _isBookmarked = _job.isBookmarked;
    final initialStatus = (widget.applicationStatus != null && widget.applicationStatus!.isNotEmpty)
        ? widget.applicationStatus!
        : _job.applicationStatus;
    _isApplied = _job.isApplied || initialStatus.isNotEmpty;
    _applicationStatus = initialStatus;
    _loadLiveDetail();
  }

  Future<void> _loadLiveDetail() async {
    try {
      final detail = await MagangHubService.getDetail(_job.id);
      if (!mounted) return;
      setState(() {
        _job = detail;
        _isBookmarked = detail.isBookmarked;
        if (detail.isApplied) {
          _isApplied = true;
          if (detail.applicationStatus.isNotEmpty) {
            _applicationStatus = detail.applicationStatus;
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    final target = !_isBookmarked;
    setState(() => _isBookmarked = target);
    try {
      await CareerExpoService.setTersimpan(_job.id, target);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBookmarked = !target);
      final unauthorized = e is DioException && e.response?.statusCode == 401;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unauthorized
                ? 'Silakan login terlebih dahulu untuk menyimpan info magang.'
                : 'Gagal memperbarui status tersimpan.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          target ? 'Info magang disimpan ke favorit' : 'Info magang dihapus dari favorit',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF53A6ED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showApplyModal() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CareerExpoApplyScreen(job: _job),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _isApplied = true;
        _applicationStatus = 'Terkirim';
      });
    }
  }

  String get _salaryFormatted {
    final hasSalary = _job.salaryMin > 0 || _job.salaryMax > 0;
    if (!hasSalary) return 'Uang saku kompetitif';
    if (_job.salaryMin > 0 && _job.salaryMax > 0) {
      return 'Rp ${NumberFormatHelper.formatWithDots(_job.salaryMin)} - ${NumberFormatHelper.formatWithDots(_job.salaryMax)} / bln';
    }
    if (_job.salaryMin > 0) {
      return 'Rp ${NumberFormatHelper.formatWithDots(_job.salaryMin)} / bln';
    }
    return 'Rp ${NumberFormatHelper.formatWithDots(_job.salaryMax)} / bln';
  }

  Future<void> _editJob() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MagangFormScreen(initialJob: _job)),
    );
    if (updated == true && mounted) {
      _hasEdited = true;
      _loadLiveDetail();
    }
  }

  Future<void> _copyInfo() async {
    await Clipboard.setData(ClipboardData(
      text: 'Lowongan Magang: ${_job.title} di ${_job.companyName} - LSP Digital Mobile',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informasi magang disalin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _hasEdited);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomAppBar(
                title: 'Detail Magang',
                onBack: () => Navigator.pop(context, _hasEdited),
                rightWidget: PopupMenuButton<String>(
                  tooltip: 'Opsi lowongan',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'copy') _copyInfo();
                    if (value == 'edit') _editJob();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'copy',
                      child: Text('Salin informasi'),
                    ),
                    if (_isCreator)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit lowongan'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _section(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _job.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _job.companyName,
                              style: const TextStyle(fontSize: 15, color: Color(0xFF475569)),
                            ),
                            if (_job.companyCategory.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(_job.companyCategory, style: const TextStyle(color: Color(0xFF64748B))),
                            ],
                            if (_job.postedAt.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(_job.postedAt, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ],
                        ),
                      ),
                      _section(
                        title: 'Informasi magang',
                        child: Column(
                          children: [
                            _info('Uang saku', _salaryFormatted),
                            _info('Sistem kerja', _job.workplaceType),
                            _info('Lokasi', _job.location),
                            _info('Pendidikan', _job.education),
                            if (_job.experience.isNotEmpty) _info('Pengalaman', _job.experience),
                          ],
                        ),
                      ),
                      if (_job.shortDescription.isNotEmpty || _job.jobDescription.isNotEmpty)
                        _section(
                          title: 'Deskripsi magang',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_job.shortDescription.isNotEmpty)
                                Text(_job.shortDescription, style: _bodyStyle),
                              if (_job.shortDescription.isNotEmpty && _job.jobDescription.isNotEmpty)
                                const SizedBox(height: 12),
                              ..._job.jobDescription.map(_bullet),
                            ],
                          ),
                        ),
                      if (_job.requirements.isNotEmpty)
                        _section(
                          title: 'Persyaratan',
                          child: Column(children: _job.requirements.map(_bullet).toList()),
                        ),
                      if (_job.benefits.isNotEmpty)
                        _section(
                          title: 'Fasilitas dan benefit',
                          child: Column(children: _job.benefits.map(_bullet).toList()),
                        ),
                      if (_job.aboutCompany.isNotEmpty)
                        _section(
                          title: 'Tentang perusahaan',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _job.aboutCompany,
                                style: _bodyStyle,
                                maxLines: _isAboutExpanded ? null : 4,
                                overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              ),
                              if (_job.aboutCompany.length > 150)
                                TextButton(
                                  onPressed: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                                  child: Text(_isAboutExpanded ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya'),
                                ),
                            ],
                          ),
                        ),
                      if (_job.filePdf.isNotEmpty)
                        _section(
                          title: 'Dokumen pendukung',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.description_outlined, size: 24),
                            title: const Text('Dokumen magang', style: TextStyle(fontSize: 14)),
                            trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                            onTap: () {
                              final pdfUrl = _job.filePdfUrl.isNotEmpty
                                  ? _job.filePdfUrl
                                  : (_job.filePdf.startsWith('http')
                                      ? _job.filePdf
                                      : '${ApiClient.baseUrl}/${_job.filePdf.replaceAll(RegExp(r'^/+'), '')}');
                              UrlHelper.launchURL(pdfUrl);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isApplied && !_isCreator) ...[
                  Text(
                    'Status lamaran: ${_applicationStatus.isEmpty ? 'Terkirim' : _applicationStatus}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (!_isCreator) ...[
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton.outlined(
                          tooltip: _isBookmarked ? 'Hapus dari tersimpan' : 'Simpan lowongan',
                          onPressed: _toggleBookmark,
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isCreator ? _editJob : (_isApplied ? null : _showApplyModal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF53A6ED),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFDCFCE7),
                            disabledForegroundColor: const Color(0xFF166534),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _isCreator ? 'Edit lowongan' : (_isApplied ? 'Terkirim' : 'Lamar magang'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isApplied && !_isCreator ? const Color(0xFF166534) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _bodyStyle = TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155));

  Widget _section({String? title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Tidak dicantumkan' : value, style: _bodyStyle),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: _bodyStyle),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }
}
