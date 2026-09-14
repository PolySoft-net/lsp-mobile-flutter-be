import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import '../../models/asesor_dashboard_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../jadwal/jadwal_detail_screen.dart';

class TukJadwalListScreen extends StatefulWidget {
  final int idTuk;
  final String namaTuk;
  final String? alamatTuk;

  const TukJadwalListScreen({
    super.key,
    required this.idTuk,
    required this.namaTuk,
    this.alamatTuk,
  });

  @override
  State<TukJadwalListScreen> createState() => _TukJadwalListScreenState();
}

class _TukJadwalListScreenState extends State<TukJadwalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = true;
  String _errorMessage = '';
  List<TUKJadwalItem> _allJadwal = [];
  List<TUKJadwalItem> _filteredJadwal = [];

  int _selectedTahun = 0; // 0 = Semua
  String _selectedStatus = 'Semua';

  final List<int> _availableYears = [0, 2026, 2025, 2024, 2023, 2022];
  final List<String> _statusOptions = ['Semua', 'Selesai', 'Sedang Berjalan', 'Pelaporan', 'Draft'];

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJadwal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await AsesorService.getTukJadwal(
        idTuk: widget.idTuk,
        tahun: _selectedTahun > 0 ? _selectedTahun : null,
      );

      if (mounted) {
        setState(() {
          _allJadwal = list;
          _isLoading = false;
        });
        _applyLocalFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat jadwal TUK: $e';
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyLocalFilter();
    });
  }

  void _applyLocalFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredJadwal = _allJadwal.where((j) {
        final matchesQuery = query.isEmpty ||
            j.namaJadwal.toLowerCase().contains(query) ||
            j.skema.toLowerCase().contains(query) ||
            j.asesor.toLowerCase().contains(query);

        final matchesStatus = _selectedStatus == 'Semua' ||
            j.statusJadwal.toLowerCase() == _selectedStatus.toLowerCase();

        return matchesQuery && matchesStatus;
      }).toList();
    });
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
              title: 'Daftar Jadwal TUK',
              onBack: () => Navigator.of(context).pop(),
            ),
            _buildTukHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTukHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.building, color: Color(0xFF2563EB), size: 20),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari jadwal, skema, atau asesor...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF94A3B8)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    _applyLocalFilter();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Year Dropdown / Chip
            for (final yr in _availableYears)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(yr == 0 ? 'Semua Tahun' : '$yr'),
                  selected: _selectedTahun == yr,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTahun = selected ? yr : 0;
                    });
                    _fetchJadwal();
                  },
                  backgroundColor: const Color(0xFFF1F5F9),
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: _selectedTahun == yr ? FontWeight.bold : FontWeight.normal,
                    color: _selectedTahun == yr ? Colors.white : const Color(0xFF475569),
                  ),
                  checkmarkColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                ),
              ),
            const SizedBox(width: 8),
            Container(height: 18, width: 1, color: const Color(0xFFCBD5E1)),
            const SizedBox(width: 8),
            // Status Chips
            for (final st in _statusOptions)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(st),
                  selected: _selectedStatus == st,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? st : 'Semua';
                    });
                    _applyLocalFilter();
                  },
                  backgroundColor: const Color(0xFFF1F5F9),
                  selectedColor: const Color(0xFF0F172A),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: _selectedStatus == st ? FontWeight.bold : FontWeight.normal,
                    color: _selectedStatus == st ? Colors.white : const Color(0xFF475569),
                  ),
                  checkmarkColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                onPressed: _fetchJadwal,
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

    if (_filteredJadwal.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchJadwal,
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
                  child: const Icon(LucideIcons.calendar_off, size: 36, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak Ada Jadwal Ditemukan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchController.text.isNotEmpty || _selectedStatus != 'Semua' || _selectedTahun != 0
                      ? 'Tidak ada jadwal yang cocok dengan filter yang dipilih.'
                      : 'TUK ini belum memiliki riwayat pelaksanaan jadwal asesmen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJadwal,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _filteredJadwal.length,
        itemBuilder: (context, index) {
          final item = _filteredJadwal[index];
          return _buildJadwalCard(item);
        },
      ),
    );
  }

  Widget _buildJadwalCard(TUKJadwalItem item) {
    Color statusBg = const Color(0xFFEFF6FF);
    Color statusFg = const Color(0xFF2563EB);
    String stText = item.statusJadwal;

    if (stText.toLowerCase().contains('selesai')) {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF16A34A);
    } else if (stText.toLowerCase().contains('berjalan')) {
      statusBg = const Color(0xFFE0F2FE);
      statusFg = const Color(0xFF0284C7);
    } else if (stText.toLowerCase().contains('pelaporan')) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFD97706);
    } else if (stText.toLowerCase().contains('batal')) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFDC2626);
    } else if (stText.toLowerCase().contains('draft')) {
      statusBg = const Color(0xFFF1F5F9);
      statusFg = const Color(0xFF64748B);
    }

    final tglDisplay = item.tanggal.isNotEmpty
        ? (item.tanggalAkhir.isNotEmpty && item.tanggalAkhir != item.tanggal
            ? '${DateFormatHelper.formatToIndonesian(item.tanggal)} s/d ${DateFormatHelper.formatToIndonesian(item.tanggalAkhir)}'
            : DateFormatHelper.formatToIndonesian(item.tanggal))
        : '-';

    return InkWell(
      onTap: () {
        final jadwalItem = JadwalItem(
          id: item.idJadwal,
          skema: item.skema.isNotEmpty ? item.skema : item.namaJadwal,
          tuk: widget.namaTuk,
          tanggalMulai: item.tanggal,
          tanggalSelesai: item.tanggalAkhir.isNotEmpty ? item.tanggalAkhir : item.tanggal,
          status: item.statusJadwal,
          statusJadwal: item.statusJadwalCode,
          statusLabel: item.statusJadwal,
          statusJadwalLabel: item.statusJadwal,
          jumlahAsesi: item.totalAsesi,
          totalAsesi: item.totalAsesi,
          asesor: item.asesor.isNotEmpty ? item.asesor.split(', ') : [],
          jenisUji: item.jenisUji,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JadwalDetailScreen(
              jadwal: jadwalItem,
              userRole: UserRole.asesor,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Tanggal & Badge Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      tglDisplay,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Judul Jadwal
            Text(
              item.namaJadwal,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Skema Sertifikasi
            if (item.skema.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(LucideIcons.award, size: 13, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.skema,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Asesor Bertugas
            if (item.asesor.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(LucideIcons.user_check, size: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Asesor: ${item.asesor}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Footer: Jenis Uji, Total Asesi & Action Detail
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.jenisUji,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.users, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.totalAsesi} Asesi',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: const [
                    Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(LucideIcons.chevron_right, size: 14, color: Color(0xFF2563EB)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
