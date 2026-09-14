import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/asesor_dashboard_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class TukStatistikScreen extends StatefulWidget {
  final int idTuk;
  final String namaTuk;
  final String? alamatTuk;

  const TukStatistikScreen({
    super.key,
    required this.idTuk,
    required this.namaTuk,
    this.alamatTuk,
  });

  @override
  State<TukStatistikScreen> createState() => _TukStatistikScreenState();
}

class _TukStatistikScreenState extends State<TukStatistikScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<TUKStatistikTahunanItem> _statsList = [];

  @override
  void initState() {
    super.initState();
    _fetchStatistik();
  }

  Future<void> _fetchStatistik() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await AsesorService.getTukStatistik(idTuk: widget.idTuk);

      if (mounted) {
        setState(() {
          _statsList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat statistik TUK: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            CustomAppBar(
              title: 'Statistik Uji TUK',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circle_alert, size: 42, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchStatistik,
                icon: const Icon(LucideIcons.rotate_cw, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_statsList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchStatistik,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.chart_column, size: 36, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Statistik Uji',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'TUK ini belum memiliki riwayat data asesmen yang tercatat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Calculate Grand Totals
    int totalAllJadwal = 0;
    int totalAllAsesi = 0;
    int totalAllKompeten = 0;

    for (final s in _statsList) {
      totalAllJadwal += s.totalJadwal;
      totalAllAsesi += s.totalAsesi;
      totalAllKompeten += s.jumlahKompeten;
    }

    final double avgKompetenPct = totalAllAsesi > 0
        ? (totalAllKompeten / totalAllAsesi) * 100
        : 0.0;

    return RefreshIndicator(
      onRefresh: _fetchStatistik,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info TUK
            _buildTukHeaderCard(),
            const SizedBox(height: 14),

            // Summary Metric Cards
            _buildOverallMetricsCard(
              totalJadwal: totalAllJadwal,
              totalAsesi: totalAllAsesi,
              totalKompeten: totalAllKompeten,
              pct: avgKompetenPct,
            ),
            const SizedBox(height: 18),

            // Section Header
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: Color(0xFF1E293B)),
                const SizedBox(width: 8),
                const Text(
                  'Rekapitulasi Uji Per Tahun',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Annual Cards List
            for (final item in _statsList) ...[
              _buildYearlyStatCard(item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTukHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.building, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaTuk,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ID TUK: #${widget.idTuk}${widget.alamatTuk != null && widget.alamatTuk!.isNotEmpty ? ' • ${widget.alamatTuk}' : ''}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallMetricsCard({
    required int totalJadwal,
    required int totalAsesi,
    required int totalKompeten,
    required double pct,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x202563EB),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Aktivitas Asesmen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}% Kompeten',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricCol(
                  label: 'Total Jadwal',
                  value: '$totalJadwal',
                  icon: LucideIcons.calendar,
                ),
              ),
              Container(height: 36, width: 1, color: Colors.white24),
              Expanded(
                child: _buildMetricCol(
                  label: 'Total Asesi',
                  value: '$totalAsesi',
                  icon: LucideIcons.users,
                ),
              ),
              Container(height: 36, width: 1, color: Colors.white24),
              Expanded(
                child: _buildMetricCol(
                  label: 'Kompeten [K]',
                  value: '$totalKompeten',
                  icon: LucideIcons.circle_check,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildYearlyStatCard(TUKStatistikTahunanItem item) {
    final double pct = item.totalAsesi > 0
        ? (item.jumlahKompeten / item.totalAsesi)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Tahun
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Tahun ${item.tahun}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.totalJadwal} Jadwal Diselenggarakan',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.totalAsesi} Asesi',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metric Pill Row
                Row(
                  children: [
                    Expanded(
                      child: _buildPillStat(
                        label: 'Kompeten',
                        value: '${item.jumlahKompeten}',
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPillStat(
                        label: 'Belum Komp.',
                        value: '${item.jumlahBelumKompeten}',
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPillStat(
                        label: 'Kelulusan',
                        value: item.totalAsesi > 0
                            ? '${(pct * 100).toStringAsFixed(1)}%'
                            : '-',
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Competency Progress Bar
                if (item.totalAsesi > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFFEE2E2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Breakdown Skema di TUK
                if (item.skemaList.isNotEmpty) ...[
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(LucideIcons.layers, size: 13, color: Color(0xFF64748B)),
                      SizedBox(width: 6),
                      Text(
                        'Skema Sertifikasi yang Diujikan:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final skema in item.skemaList)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              skema.namaSkema,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${skema.totalAsesi} asesi',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillStat({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
