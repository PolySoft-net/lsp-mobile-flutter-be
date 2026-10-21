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
import '../../widgets/career_expo/career_bouncy_tap.dart';
import '../career_expo/career_expo_apply_screen.dart';
import 'magang_form_screen.dart';

/// Halaman Detail Info Magang di Magang Hub (warna aksen ungu #7C3AED).
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
        backgroundColor: const Color(0xFF7C3AED),
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

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _hasEdited);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context, _hasEdited),
          ),
          title: const Text(
            'Detail Lowongan Magang',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          actions: [
            if (_isCreator)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF7C3AED)),
                tooltip: 'Edit Info Magang',
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MagangFormScreen(initialJob: _job),
                    ),
                  );
                  if (updated == true && mounted) {
                    _hasEdited = true;
                    _loadLiveDetail();
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                  text: 'Lowongan Magang: ${_job.title} di ${_job.companyName} - LSP Digital Mobile',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan info magang disalin ke clipboard.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isBookmarked ? const Color(0xFF7C3AED) : const Color(0xFF1E293B),
              ),
              onPressed: _toggleBookmark,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _job.logoBgColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _job.logoText.isNotEmpty
                                  ? _job.logoText
                                  : (_job.companyName.isNotEmpty
                                      ? _job.companyName.substring(0, 1).toUpperCase()
                                      : 'M'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _job.companyName,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _job.companyCategory.isNotEmpty
                                      ? _job.companyCategory
                                      : 'Mitra Industri Asesor',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title & Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _job.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              height: 1.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Program Magang',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Highlights Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildSpecRow(
                            Icons.payments_outlined,
                            'Uang Saku',
                            _salaryFormatted,
                            const Color(0xFF7C3AED),
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          _buildSpecRow(
                            Icons.business_outlined,
                            'Sistem Kerja',
                            _job.workplaceType.isNotEmpty ? _job.workplaceType : 'On Site',
                            const Color(0xFF2563EB),
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          _buildSpecRow(
                            Icons.location_on_outlined,
                            'Lokasi',
                            _job.location.isNotEmpty ? _job.location : '-',
                            const Color(0xFF0D9488),
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          _buildSpecRow(
                            Icons.school_outlined,
                            'Pendidikan',
                            _job.education.isNotEmpty ? _job.education : 'Semua Jurusan',
                            const Color(0xFFEA580C),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Deskripsi
                    if (_job.shortDescription.isNotEmpty || _job.jobDescription.isNotEmpty) ...[
                      const Text(
                        'Deskripsi Tugas & Program Magang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_job.shortDescription.isNotEmpty)
                        Text(
                          _job.shortDescription,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      if (_job.jobDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ..._job.jobDescription.map((item) => _buildBulletPoint(item)),
                      ],
                      const SizedBox(height: 24),
                    ],
                    // Persyaratan
                    if (_job.requirements.isNotEmpty) ...[
                      const Text(
                        'Persyaratan Kualifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._job.requirements.map((item) => _buildBulletPoint(item)),
                      const SizedBox(height: 24),
                    ],
                    // Benefit
                    if (_job.benefits.isNotEmpty) ...[
                      const Text(
                        'Fasilitas & Benefit Magang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._job.benefits.map((item) => _buildBulletPoint(item, isBenefit: true)),
                      const SizedBox(height: 24),
                    ],
                    // Tentang Perusahaan
                    if (_job.aboutCompany.isNotEmpty) ...[
                      const Text(
                        'Tentang Perusahaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _job.aboutCompany,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                        maxLines: _isAboutExpanded ? null : 3,
                        overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                      if (_job.aboutCompany.length > 150)
                        GestureDetector(
                          onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _isAboutExpanded ? 'Sembunyikan' : 'Baca Selengkapnya',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    // Berkas Unduhan / Flyer PDF
                    if (_job.filePdf.isNotEmpty) ...[
                      const Text(
                        'Dokumen / Flyer Magang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, size: 32, color: Color(0xFFEF4444)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kerangka Acuan / Flyer Magang',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Format PDF resmi dari perusahaan',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final pdfUrl = _job.filePdfUrl.isNotEmpty
                                    ? _job.filePdfUrl
                                    : (_job.filePdf.startsWith('http')
                                        ? _job.filePdf
                                        : '${ApiClient.baseUrl}/${_job.filePdf.replaceAll(RegExp(r'^/+'), '')}');
                                UrlHelper.launchURL(pdfUrl);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Buka', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
              ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
              child: _isCreator
                  ? CareerBouncyTap(
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MagangFormScreen(initialJob: _job),
                          ),
                        );
                        if (updated == true && mounted) {
                          _hasEdited = true;
                          _loadLiveDetail();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Edit Info Magang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _isApplied
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Lamaran Terkirim (${_applicationStatus.isNotEmpty ? _applicationStatus : 'Menunggu Review'})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CareerBouncyTap(
                          onTap: _showApplyModal,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Lamar Magang Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, {bool isBenefit = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              isBenefit ? Icons.check_circle_rounded : Icons.fiber_manual_record,
              size: isBenefit ? 15 : 8,
              color: isBenefit ? const Color(0xFF7C3AED) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
