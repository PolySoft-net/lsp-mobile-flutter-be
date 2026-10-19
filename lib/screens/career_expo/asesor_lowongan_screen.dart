import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../utils/number_format_helper.dart';
import 'career_expo_detail_screen.dart';
import 'career_expo_form_lowongan_screen.dart';

/// Halaman Kelola Lowongan Kerja Saya (untuk Asesor / Rekruter)
class AsesorLowonganScreen extends StatefulWidget {
  const AsesorLowonganScreen({super.key});

  @override
  State<AsesorLowonganScreen> createState() => _AsesorLowonganScreenState();
}

class _AsesorLowonganScreenState extends State<AsesorLowonganScreen> {
  bool _isLoading = true;
  String? _error;
  List<CareerJobItem> _jobs = [];
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Publish', 'Draft'];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await CareerExpoService.getMyLowongan(
        status: _selectedFilter == 'Semua' ? '' : _selectedFilter,
      );
      if (!mounted) return;
      setState(() {
        _jobs = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException && e.response != null
            ? 'Gagal memuat lowongan (kode ${e.response?.statusCode}).'
            : 'Tidak bisa terhubung ke server. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteJob(CareerJobItem job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Lowongan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus lowongan "${job.title}" di ${job.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CareerExpoService.deleteLowongan(job.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lowongan berhasil dihapus.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadJobs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus lowongan.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openForm({CareerJobItem? job}) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CareerExpoFormLowonganScreen(initialJob: job),
      ),
    );
    if (updated == true) {
      _loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Lowongan Kerja Saya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF0066F6),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Pasang Lowongan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedFilter = filter);
                        _loadJobs();
                      }
                    },
                    selectedColor: const Color(0xFF0066F6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Job list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadJobs,
              color: const Color(0xFF0066F6),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066F6)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_outline_rounded, size: 36, color: Color(0xFF0066F6)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Lowongan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Anda belum memasang lowongan pekerjaan. Pasang lowongan sekarang untuk menemukan talenta tersertifikasi LSP.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Pasang Lowongan Pertama'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(CareerJobItem job) {
    String salaryFormatted = '';
    if (job.salaryMin > 0 && job.salaryMax > 0) {
      salaryFormatted =
          'Rp ${NumberFormatHelper.formatWithDots(job.salaryMin)} - Rp ${NumberFormatHelper.formatWithDots(job.salaryMax)}/${job.salaryPeriod}';
    } else if (job.salaryMin > 0) {
      salaryFormatted = '> Rp ${NumberFormatHelper.formatWithDots(job.salaryMin)}/${job.salaryPeriod}';
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Logo, Company & Status Chip
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: job.logoBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  job.logoText.isNotEmpty ? job.logoText : job.companyName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      job.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: job.statusLowongan.toLowerCase() == 'draft' ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: job.statusLowongan.toLowerCase() == 'draft' ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  job.statusLowongan.toLowerCase() == 'draft' ? 'Draft' : 'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: job.statusLowongan.toLowerCase() == 'draft' ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips (Type, Workplace, Location)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(job.employmentType, const Color(0xFFEFF6FF), const Color(0xFF0066F6)),
              _buildBadge(job.workplaceType, const Color(0xFFF1F5F9), const Color(0xFF475569)),
              if (job.location.isNotEmpty)
                _buildBadge(job.location, const Color(0xFFF8FAFC), const Color(0xFF64748B), icon: Icons.location_on_outlined),
              if (job.filePdfUrl.isNotEmpty)
                _buildBadge('PDF Brosur', const Color(0xFFFEE2E2), const Color(0xFFDC2626), icon: Icons.picture_as_pdf_rounded),
            ],
          ),

          if (salaryFormatted.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              salaryFormatted,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0066F6)),
            ),
          ],

          const Divider(height: 22, thickness: 1, color: Color(0xFFF1F5F9)),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CareerExpoDetailScreen(job: job),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)),
                label: const Text('Detail', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _openForm(job: job),
                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0066F6)),
                label: const Text('Edit', style: TextStyle(fontSize: 12.5, color: Color(0xFF0066F6))),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _deleteJob(job),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                label: const Text('Hapus', style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textCol, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textCol),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textCol),
          ),
        ],
      ),
    );
  }
}
