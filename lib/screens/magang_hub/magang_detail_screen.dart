import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/company_logo.dart';
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
                title: 'Detail',
                onBack: () => Navigator.pop(context, _hasEdited),
                rightWidget: PopupMenuButton<String>(
                  tooltip: 'Opsi',
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F172A)),
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Logo, Company Info, Bookmark
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CompanyLogo(
                              imageUrl: _job.companyLogo,
                              size: 44,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _job.companyName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _job.companyCategory.isNotEmpty
                                        ? _job.companyCategory
                                        : 'IT Services & Consulting',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      _buildTagBadge('+${_job.employmentType}'),
                                      _buildTagBadge('+${_job.workplaceType}'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 14,
                                        color: Color(0xFF334155),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'RP. ${NumberFormatHelper.formatSalaryRange(_job.salaryMin, _job.salaryMax)} /${_job.salaryPeriod}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF334155),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_job.postedAt.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: Color(0xFF334155),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _job.postedAt,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Bookmark button
                            GestureDetector(
                              onTap: _toggleBookmark,
                              child: Icon(
                                _isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                color: const Color(0xFF0F172A),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),

                        // 3 Specs in a row (Location, Experience, Education)
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.location_on_outlined,
                                _job.location,
                              ),
                            ),
                            Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.work_outline_rounded,
                                _job.experience,
                              ),
                            ),
                            Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.school_outlined,
                                _job.education,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Big Action CTA Button "Lamar Sekarang"
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isCreator
                                ? _editJob
                                : (_isApplied
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Status lamaran: Terkirim.'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    : _showApplyModal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCreator
                                  ? const Color(0xFF0066F6)
                                  : (_isApplied
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF94A3B8)),
                              foregroundColor: _isCreator
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isCreator
                                      ? 'Edit Lowongan'
                                      : (_isApplied ? (_applicationStatus.isNotEmpty ? _applicationStatus : 'Terkirim') : 'Lamar Sekarang'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _isCreator ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _isCreator
                                      ? Icons.edit_outlined
                                      : (_isApplied ? Icons.check_circle_rounded : Icons.send_rounded),
                                  size: 16,
                                  color: _isCreator ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section: Tentang Perusahaan
                        const Text(
                          'Tentang Perusahaan :',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _job.aboutCompany.isNotEmpty
                              ? _job.aboutCompany
                              : 'Perusahaan penyedia Layanan Teknologi Informasi dan Konsultasi yang berfokus pada inovasi digital.',
                          maxLines: _isAboutExpanded ? 30 : 4,
                          overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                          child: Text(
                            _isAboutExpanded ? 'Tutup' : 'Selanjutnya...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Section: Deskripsi Magang
                        const Text(
                          'Deskripsi Magang :',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_job.jobDescription.isNotEmpty)
                          ..._job.jobDescription.map(
                            (desc) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '> $desc',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          const Text('> Membuat desain UI/UX untuk Aplikasi dan Website', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                          const SizedBox(height: 4),
                          const Text('> Berkolaborasi dengan tim produk dan developer', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                          const SizedBox(height: 4),
                          const Text('> Melakukan riset pengguna dan analisis kebutuhan', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                        ],

                        if (_job.requirements.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Persyaratan :',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ..._job.requirements.map(
                            (req) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '> $req',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTagBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}

