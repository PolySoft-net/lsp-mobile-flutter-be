import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
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
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Detail',
            onBack: () => Navigator.pop(context),
            rightWidget: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF0F172A),
                size: 22,
              ),
              onPressed: () => _showOptionsMenu(context),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const CustomPaint(
                            painter: _DiagonalPlaceholderPainter(
                              color: Color(0xFF475569),
                              strokeWidth: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.companyName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.job.companyCategory.isNotEmpty
                                    ? widget.job.companyCategory
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
                                  _buildTagBadge('+${widget.job.employmentType}'),
                                  _buildTagBadge('+${widget.job.workplaceType}'),
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
                                      'RP. ${NumberFormatHelper.formatSalaryRange(widget.job.salaryMin, widget.job.salaryMax)} /${widget.job.salaryPeriod}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                      widget.job.postedAt.isNotEmpty
                                          ? 'Berlaku sampai ${widget.job.postedAt}'
                                          : 'Berlaku sampai 30 Juni 2026',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                            widget.job.location,
                          ),
                        ),
                        Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.work_outline_rounded,
                            widget.job.experience,
                          ),
                        ),
                        Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.school_outlined,
                            widget.job.education,
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
                        onPressed: _isApplied
                            ? () {
                                final statusText = _appliedStatusLabel;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Status lamaran: $statusText.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : _showApplyModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isApplied
                              ? _appliedButtonColor
                              : const Color(0xFF94A3B8),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isApplied ? _appliedStatusLabel : 'Lamar Sekarang',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isApplied ? _appliedButtonIcon : Icons.send_rounded,
                              size: 16,
                              color: const Color(0xFF0F172A),
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
                      widget.job.aboutCompany.isNotEmpty
                          ? widget.job.aboutCompany
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

                    // Section: Deskripsi Pekerjaan
                    const Text(
                      'Deskripsi Pekerjaan :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.job.jobDescription.isNotEmpty)
                      ...widget.job.jobDescription.map(
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

                    if (widget.job.requirements.isNotEmpty) ...[
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
                      ...widget.job.requirements.map(
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 280),
        reverseDuration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Opsi Lowongan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.share_outlined,
                  iconColor: const Color(0xFF0066F6),
                  iconBgColor: const Color(0xFFEFF6FF),
                  title: 'Bagikan Lowongan',
                  subtitle: 'Salin tautan lowongan untuk dibagikan ke teman',
                  onTap: () {
                    final shareText =
                        'Lowongan Kerja: ${widget.job.title}\n'
                        'Perusahaan: ${widget.job.companyName}\n'
                        'Lokasi: ${widget.job.location} (${widget.job.workplaceType})\n'
                        'Gaji: Rp ${NumberFormatHelper.formatSalaryRange(widget.job.salaryMin, widget.job.salaryMax)}\n\n'
                        'Lamar dan cek lowongan ini di aplikasi LSP Teknologi Digital:\n'
                        'https://play.google.com/store/apps/details?id=id.lspdigital.mobile';
                    Clipboard.setData(ClipboardData(text: shareText));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Info lowongan telah disalin ke clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (_isApplied) ...[
                  _buildOptionItem(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFDC2626),
                    iconBgColor: const Color(0xFFFEE2E2),
                    title: 'Batalkan / Hapus Lamaran',
                    subtitle: 'Batalkan lamaran pekerjaan yang telah dikirim',
                    titleColor: const Color(0xFFDC2626),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmHapusLamaran();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                _buildOptionItem(
                  icon: Icons.flag_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFEF3C7),
                  title: 'Laporkan Lowongan',
                  subtitle: 'Laporkan jika lowongan mencurigakan atau bermasalah',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Laporan Anda telah diterima dan akan ditinjau oleh tim LSP',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
class _DiagonalPlaceholderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DiagonalPlaceholderPainter({
    this.color = const Color(0xFF475569),
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalPlaceholderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
