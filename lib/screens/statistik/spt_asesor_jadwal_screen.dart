import 'dart:async';
import 'package:material_ui/material_ui.dart';

import '../../models/admin_statistik_detail_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

const List<String> _monthLabels = [
  'Semua',
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

class SptAsesorJadwalScreen extends StatefulWidget {
  final int asesorId;
  final String namaAsesor;
  final String? tglExpired;
  final String? statusMasaBerlaku;
  final int? initialBulan;
  final int? initialTahun;

  const SptAsesorJadwalScreen({
    super.key,
    required this.asesorId,
    required this.namaAsesor,
    this.tglExpired,
    this.statusMasaBerlaku,
    this.initialBulan,
    this.initialTahun,
  });

  @override
  State<SptAsesorJadwalScreen> createState() => _SptAsesorJadwalScreenState();
}

class _SptAsesorJadwalScreenState extends State<SptAsesorJadwalScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = true;
  int _selectedBulan = 0; // 0 = Semua, 1-12 = Jan-Des
  int _selectedTahun = 2026; // 0 = Semua, 2026, etc.
  String _searchQuery = '';

  AsesorJadwalHistoryData? _historyData;

  @override
  void initState() {
    super.initState();
    _selectedBulan = widget.initialBulan ?? 0;
    _selectedTahun = widget.initialTahun ?? 2026;
    _fetchJadwalHistory();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJadwalHistory() async {
    setState(() => _isLoading = true);

    try {
      final res = await DashboardService.getAsesorJadwalHistory(
        widget.asesorId,
        tahun: _selectedTahun,
        bulan: _selectedBulan,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _historyData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching asesor jadwal history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _searchQuery = value.trim());
        _fetchJadwalHistory();
      }
    });
  }

  void _onSelectBulan(int index) {
    if (_selectedBulan == index) return;
    setState(() {
      _selectedBulan = index;
    });
    _fetchJadwalHistory();
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('aktif') || s.contains('jalan') || s.contains('berjalan')) {
      return const Color(0xFF16A34A);
    } else if (s.contains('selesai')) {
      return const Color(0xFF2563EB);
    } else if (s.contains('tenggang') || s.contains('menunggu')) {
      return const Color(0xFFD97706);
    } else if (s.contains('batal') || s.contains('expired')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final info = _historyData?.asesor;
    final displayName = info?.namaAsesor.isNotEmpty == true
        ? info!.namaAsesor
        : widget.namaAsesor;
    final statusMasaBerlaku = info?.statusMasaBerlaku.isNotEmpty == true
        ? info!.statusMasaBerlaku
        : (widget.statusMasaBerlaku ?? 'Aktif');
    final expiredDate = info?.tglExpired.isNotEmpty == true
        ? info!.tglExpired
        : (widget.tglExpired ?? '');

    final jadwalList = _historyData?.jadwal ?? [];

    Color statusColor;
    if (statusMasaBerlaku == 'Aktif') {
      statusColor = const Color(0xFF16A34A);
    } else if (statusMasaBerlaku == 'Tenggang') {
      statusColor = const Color(0xFFD97706);
    } else {
      statusColor = const Color(0xFFDC2626);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Riwayat Jadwal Uji Asesor',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchJadwalHistory,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Asesor Profile Header Card
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (info != null && info.noMet.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'No. MET: ${info.noMet}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                      if (expiredDate.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Expired: ${DateFormatHelper.formatToIndonesian(expiredDate)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusMasaBerlaku,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 12),
                            // Quick Summary Pills
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.event_note_rounded,
                                          size: 16,
                                          color: Color(0xFF2563EB),
                                        ),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Total Penugasan',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            Text(
                                              '${info?.totalPenugasan ?? _historyData?.total ?? jadwalList.length} Jadwal',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.people_outline_rounded,
                                          size: 16,
                                          color: Color(0xFF16A34A),
                                        ),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Total Asesi Diuji',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            Text(
                                              '${info?.totalAsesi ?? jadwalList.fold<int>(0, (sum, j) => sum + j.totalAsesi)} Asesi',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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

                  // 2. Filter Bulan horizontal list
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Jadwal Penugasan ($_selectedTahun)',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              PopupMenuButton<int>(
                                initialValue: _selectedTahun,
                                onSelected: (val) {
                                  if (_selectedTahun != val) {
                                    setState(() => _selectedTahun = val);
                                    _fetchJadwalHistory();
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedTahun == 0 ? 'Semua Tahun' : 'Tahun $_selectedTahun',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 2026, child: Text('Tahun 2026')),
                                  const PopupMenuItem(value: 2025, child: Text('Tahun 2025')),
                                  const PopupMenuItem(value: 2024, child: Text('Tahun 2024')),
                                  const PopupMenuItem(value: 0, child: Text('Semua Tahun')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Search field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearchChanged,
                                    decoration: const InputDecoration(
                                      hintText: 'Cari jadwal, skema, atau TUK...',
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Horizontal Bulan Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_monthLabels.length, (index) {
                                final isSelected = _selectedBulan == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(_monthLabels[index]),
                                    selected: isSelected,
                                    onSelected: (_) => _onSelectBulan(index),
                                    labelStyle: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                    ),
                                    selectedColor: const Color(0xFF2563EB),
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Jadwal List Section
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    )
                  else if (jadwalList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(
                                  Icons.event_busy_rounded,
                                  size: 28,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tidak Ada Jadwal Penugasan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedBulan > 0
                                    ? 'Tidak ada riwayat pengujian untuk bulan ${_monthLabels[_selectedBulan]} $_selectedTahun'
                                    : 'Tidak ada riwayat pengujian pada filter yang dipilih.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildJadwalCard(jadwalList[index]);
                          },
                          childCount: jadwalList.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(AsesorJadwalHistoryItem item) {
    final statusColor = _getStatusColor(item.statusJadwal);
    String displayTanggal = item.tanggal;
    if (item.tanggal.isNotEmpty) {
      displayTanggal = DateFormatHelper.formatToIndonesian(item.tanggal);
      if (item.tanggalAkhir.isNotEmpty && item.tanggalAkhir != item.tanggal) {
        displayTanggal = '$displayTanggal - ${DateFormatHelper.formatToIndonesian(item.tanggalAkhir)}';
      }
    }

    final String rawWaktu = item.waktu.trim();
    final String waktuText = (rawWaktu.isEmpty || rawWaktu == '0' || rawWaktu == '00:00' || rawWaktu == '00:00:00')
        ? '08:00 WIB'
        : (rawWaktu.toLowerCase().contains('wib') ? rawWaktu : '$rawWaktu WIB');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tanggal & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTanggal.isNotEmpty ? displayTanggal : 'Tanggal belum ditentukan',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waktuText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.statusJadwal,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Nama / Judul Jadwal
          Text(
            item.namaJadwal.isNotEmpty ? item.namaJadwal : 'Jadwal Uji Asesmen',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Skema Sertifikasi
          if (item.skema.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 15,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.skema,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Tempat Uji / TUK
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TUK: ${item.tuk.isNotEmpty ? item.tuk : 'TUK Mandiri'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (item.alamatTuk.isNotEmpty)
                      Text(
                        item.alamatTuk,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Info Chips: Total Asesi, Mode, No SPT
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 13, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.totalAsesi} Asesi',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.jenisUji.toLowerCase().contains('online')
                          ? Icons.videocam_outlined
                          : Icons.apartment_outlined,
                      size: 13,
                      color: const Color(0xFF475569),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.jenisUji.isNotEmpty ? item.jenisUji : 'Offline',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.noSpt.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 13, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'SPT: ${item.noSpt}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

