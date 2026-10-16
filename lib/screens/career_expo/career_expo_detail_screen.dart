import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../utils/number_format_helper.dart';
import 'career_expo_apply_screen.dart';

/// Halaman Detail Lowongan Career Expo sesuai desain UI
class CareerExpoDetailScreen extends StatefulWidget {
  final CareerJobItem job;
  final String? applicationStatus;

  const CareerExpoDetailScreen({
    super.key,
    required this.job,
    this.applicationStatus,
  });

  @override
  State<CareerExpoDetailScreen> createState() => _CareerExpoDetailScreenState();
}

class _CareerExpoDetailScreenState extends State<CareerExpoDetailScreen> {
  late bool _isBookmarked;
  bool _isAboutExpanded = false;
  late bool _isApplied;
  String _applicationStatus = '';

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.job.isBookmarked;
    final initialStatus = (widget.applicationStatus != null && widget.applicationStatus!.isNotEmpty)
        ? widget.applicationStatus!
        : widget.job.applicationStatus;
    _isApplied = widget.job.isApplied || initialStatus.isNotEmpty;
    _applicationStatus = initialStatus;
    _loadLiveDetail();
  }

  Future<void> _loadLiveDetail() async {
    try {
      final detail = await CareerExpoService.getDetail(widget.job.id);
      if (!mounted) return;
      setState(() {
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
      await CareerExpoService.setTersimpan(widget.job.id, target);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBookmarked = !target);
      final unauthorized = e is DioException && e.response?.statusCode == 401;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unauthorized
                ? 'Silakan login terlebih dahulu untuk menyimpan lowongan.'
                : 'Gagal memperbarui lowongan tersimpan. Coba lagi ya.',
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
          target ? 'Lowongan disimpan ke tersimpan' : 'Lowongan dihapus dari tersimpan',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showApplyModal() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CareerExpoApplyScreen(job: widget.job),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _isApplied = true;
        _applicationStatus = 'Terkirim';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final salaryFormatted =
        'Rp ${NumberFormatHelper.formatWithDots(widget.job.salaryMin)} - ${NumberFormatHelper.formatWithDots(widget.job.salaryMax)} / ${widget.job.salaryPeriod}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isBookmarked ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
            ),
            onPressed: _toggleBookmark,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF0F172A)),
            onSelected: (val) {
              if (val == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan lowongan telah disalin'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (val == 'hapus_lamaran') {
                _confirmHapusLamaran();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Bagikan'),
                  ],
                ),
              ),
              if (_isApplied)
                const PopupMenuItem(
                  value: 'hapus_lamaran',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text('Hapus Lamaran', style: TextStyle(color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text('Laporkan Lowongan', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.job.logoBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.job.logoText.isNotEmpty
                        ? widget.job.logoText
                        : widget.job.companyName.substring(0, 1),
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
                        widget.job.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.job.companyCategory,
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
            const SizedBox(height: 16),
            // Job Title
            Text(
              widget.job.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Tag Pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagBadge(widget.job.employmentType),
                _buildTagBadge(widget.job.workplaceType),
              ],
            ),
            const SizedBox(height: 16),
            // Salary
            Text(
              salaryFormatted,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0066F6),
              ),
            ),
            const SizedBox(height: 20),
            // Highlight Info Grid (Location, Experience, Education)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on_outlined,
                      widget.job.location,
                    ),
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.work_history_outlined,
                      widget.job.experience,
                    ),
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.school_outlined,
                      widget.job.education,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons (Lamar Sekarang & Simpan)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isApplied
                    ? () {
                        final statusText = _appliedStatusLabel;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status lamaran: $statusText. Lamaran Anda sudah diterima sistem.'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : _showApplyModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isApplied
                      ? _appliedButtonColor
                      : const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isApplied ? _appliedButtonIcon : Icons.send_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isApplied ? _appliedStatusLabel : 'Lamar Sekarang',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _toggleBookmark,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: _isBookmarked ? const Color(0xFF0066F6) : const Color(0xFF0F172A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBookmarked ? 'Tersimpan' : 'Simpan',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            // Section: Tentang Perusahaan
            const Text(
              'Tentang Perusahaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.aboutCompany,
              maxLines: _isAboutExpanded ? 20 : 3,
              overflow: _isAboutExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() => _isAboutExpanded = !_isAboutExpanded);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isAboutExpanded ? 'Sembunyikan' : 'Selengkapnya',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0066F6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isAboutExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: const Color(0xFF0066F6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section: Deskripsi Pekerjaan
            const Text(
              'Deskripsi Pekerjaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            ...widget.job.jobDescription.map(
              (desc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0066F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section: Kualifikasi & Persyaratan
            if (widget.job.requirements.isNotEmpty) ...[
              const Text(
                'Kualifikasi & Persyaratan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              ...widget.job.requirements.map(
                (req) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          req,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Section: Benefit
            if (widget.job.benefits.isNotEmpty) ...[
              const Text(
                'Benefit & Keuntungan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              ...widget.job.benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          benefit,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
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
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  String get _appliedStatusLabel {
    final status = _applicationStatus.trim();
    if (status.isEmpty) return 'Proses Menunggu';
    final lower = status.toLowerCase();
    if (lower == 'diterima') return 'Lamaran Diterima';
    if (lower == 'ditolak') return 'Lamaran Ditolak';
    if (lower == 'diproses') return 'Proses Menunggu';
    if (lower == 'terkirim') return 'Proses Menunggu';
    return status;
  }

  Color get _appliedButtonColor {
    final lower = _applicationStatus.trim().toLowerCase();
    if (lower == 'diterima') return const Color(0xFF16A34A);
    if (lower == 'ditolak') return const Color(0xFFDC2626);
    return const Color(0xFFD97706);
  }

  IconData get _appliedButtonIcon {
    final lower = _applicationStatus.trim().toLowerCase();
    if (lower == 'diterima') return Icons.check_circle_outline_rounded;
    if (lower == 'ditolak') return Icons.highlight_off_rounded;
    return Icons.hourglass_top_rounded;
  }
  void _confirmHapusLamaran() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Lamaran?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan dan menghapus lamaran untuk posisi ${widget.job.title} di ${widget.job.companyName}?',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Lamaran'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await CareerExpoService.batalLamar(widget.job.id);
      if (!mounted) return;
      setState(() {
        _isApplied = false;
        _applicationStatus = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lamaran berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus lamaran. Silakan coba lagi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
