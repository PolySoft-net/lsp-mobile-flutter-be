import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import 'career_expo_detail_screen.dart';

/// Tab Lamaran Saya di Career Expo — data dari GET /api/career-expo/lamaran.
class CareerExpoLamaranTab extends StatefulWidget {
  final VoidCallback? onBack;

  const CareerExpoLamaranTab({
    super.key,
    this.onBack,
  });

  @override
  State<CareerExpoLamaranTab> createState() => _CareerExpoLamaranTabState();
}

class _CareerExpoLamaranTabState extends State<CareerExpoLamaranTab> {
  List<CareerApplicationItem> _applications = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await CareerExpoService.getLamaran();
      if (!mounted) return;
      setState(() {
        _applications = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException && e.response?.statusCode == 401
            ? 'Silakan login untuk melihat lamaranmu.'
            : 'Tidak bisa memuat lamaran. Periksa koneksi internetmu.';
        _isLoading = false;
      });
    }
  }

  bool _matchesStatus(CareerApplicationItem item, String filter) {
    if (filter == 'Semua') return true;
    final s = item.status.trim().toLowerCase();
    final f = filter.toLowerCase();
    if (f == 'diproses' || f == 'proses menunggu') {
      return s == 'terkirim' || s == 'diproses' || s == 'menunggu' || s == 'proses menunggu' || s == 'wawancara';
    }
    return s == f;
  }

  List<String> get _filterCategories => const [
    'Semua',
    'Diterima',
    'Diproses',
    'Ditolak',
  ];

  List<CareerApplicationItem> get _filteredApplications {
    if (_selectedStatus == 'Semua') return _applications;
    return _applications.where((a) => _matchesStatus(a, _selectedStatus)).toList();
  }

  String _dateLabel(CareerApplicationItem item) {
    if (item.appliedLabel.isNotEmpty) return item.appliedLabel;
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = item.appliedDate;
    return 'Dilamar ${d.day} ${bulan[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066F6)),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Lamaran Saya',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                  onPressed: widget.onBack,
                )
              : null,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadApplications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final filtered = _filteredApplications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lamaran Saya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                onPressed: widget.onBack,
              )
            : null,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filterCategories.map((cat) {
                final isSelected = _selectedStatus == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStatus = cat),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          // Applications List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.work_history_outlined,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tidak ada lamaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Belum ada lamaran dengan status ini.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CareerExpoDetailScreen(
                                    job: item.job,
                                    applicationStatus: item.status,
                                  ),
                                ),
                              );
                              if (mounted) _loadApplications();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Logo placeholder with diagonal line
                                  Container(
                                    width: 40,
                                    height: 40,
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
                                  // Texts
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.job.title,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.job.companyName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _dateLabel(item),
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCBD5E1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
