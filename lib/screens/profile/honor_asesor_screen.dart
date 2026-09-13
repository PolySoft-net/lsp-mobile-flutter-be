import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/auth/auth_repository.dart';
import 'detail_honor_screen.dart';
import 'detail_tugas_asesor_screen.dart';


class HonorAsesorScreen extends StatefulWidget {
  const HonorAsesorScreen({super.key});

  @override
  State<HonorAsesorScreen> createState() => _HonorAsesorScreenState();
}

class _HonorAsesorScreenState extends State<HonorAsesorScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  DateTime? _selectedMonth;
  bool _isLoading = false;
  List<Map<String, dynamic>> _honorItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String get _selectedMonthLabel => _selectedMonth == null
      ? 'Semua'
      : '${_monthNames[_selectedMonth!.month - 1]} ${_selectedMonth!.year}';

  String get _selectedMonthCode => _selectedMonth == null
      ? 'semua'
      : '${_selectedMonth!.year}-${_selectedMonth!.month.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _honorItems = [];
    _fetchHonorData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHonorData([String? statusOverride]) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String tabStatus = statusOverride ??
          (_selectedTabIndex == 1 ? 'selesai' : 'semua');
      // 1. Try Admin endpoint first (/api/admin/honor-asesor)
      final resAdmin = await AsesorService.getAdminHonorAsesorList(
        status: tabStatus,
        bulan: _selectedMonthCode,
        search: _searchQuery,
      );

      if (mounted && resAdmin != null && resAdmin['data'] != null) {
        final List<dynamic> list = resAdmin['data'];
        setState(() {
          _honorItems = list.map((item) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
            String rawJudul = (map['nama_jadwal'] ?? map['judul_asesmen'] ?? map['skema'] ?? '').toString();
            rawJudul = rawJudul.replaceAll(RegExp(r'^Uji Kompetensi:\s*', caseSensitive: false), '').trim();
            return {
              ...map,
              'id': map['id'] ?? map['asesor_id'],
              'nama_asesor': map['nama_asesor'] ?? 'Asesor',
              'tipe_asesor': map['tipe_asesor'] ?? 'Asesor Internal',
              'judul_asesmen': rawJudul,
              'nama_jadwal': rawJudul,
              'skema': map['skema'] ?? rawJudul,
              'tuk': map['nama_tuk'] ?? map['tuk'] ?? '-',
              'tanggal': map['tanggal_pelaksanaan'] ?? map['tanggal_jadwal'] ?? map['tanggal'] ?? '',
              'honor': map['honor'] ?? 'Rp 0',
              'status': map['status'] ?? 'Selesai',
            };
          }).toList();
          _updateFilteredItems();
        });
        return;
      }

      // 2. Fallback to Asesor endpoint (/api/asesor/honor) if logged in as Asesor (403 on Admin endpoint)
      final resAsesor = await AsesorService.getHonorList(
        _selectedMonth == null ? null : _selectedMonthLabel,
        tabStatus,
      );

      if (mounted && resAsesor != null) {
        final List<dynamic> list = resAsesor['rincian'] ?? resAsesor['data'] ?? [];
        setState(() {
          _honorItems = list.map((item) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
            String rawJudul = (map['nama_jadwal'] ?? map['judul_asesmen'] ?? map['skema'] ?? '').toString();
            rawJudul = rawJudul.replaceAll(RegExp(r'^Uji Kompetensi:\s*', caseSensitive: false), '').trim();
            return {
              ...map,
              'id': map['id'] ?? map['asesor_id'] ?? map['tugas_id'] ?? map['id_detail'],
              'nama_asesor': map['nama_asesor'] ?? rawJudul,
              'tipe_asesor': map['tipe_asesor'] ?? 'Asesor Internal',
              'judul_asesmen': rawJudul,
              'nama_jadwal': rawJudul,
              'skema': map['skema'] ?? rawJudul,
              'tuk': map['nama_tuk'] ?? map['tuk'] ?? '-',
              'tanggal': map['tanggal_pelaksanaan'] ?? map['tanggal_jadwal'] ?? map['tanggal'] ?? '',
              'honor': map['honor'] ?? 'Rp 0',
              'status': map['status'] ?? 'Selesai',
            };
          }).toList();
          _updateFilteredItems();
        });
      }
    } catch (e) {
      debugPrint('🔴 Error in _fetchHonorData: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMonthPicker(BuildContext context) {
    int year = _selectedMonth?.year ?? DateTime.now().year;
    DateTime? picked = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilih Periode Bulan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF3B82F6)),
                            onPressed: () => setSheetState(() => year--),
                          ),
                          Text(
                            '$year',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF3B82F6)),
                            onPressed: () => setSheetState(() => year++),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.2,
                        children: List.generate(12, (i) {
                          final month = i + 1;
                          final isSelected =
                              picked != null && picked!.year == year && picked!.month == month;
                          return GestureDetector(
                            onTap: () => setSheetState(() => picked = DateTime(year, month)),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _monthNames[i].substring(0, 3),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => _selectedMonth = null);
                                _fetchHonorData();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Semua', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: picked == null
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      setState(() => _selectedMonth = picked);
                                      _fetchHonorData();
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Terapkan', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateFilteredItems() {
    List<Map<String, dynamic>> result = List.from(_honorItems);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((item) {
        final nama = (item['nama_jadwal'] ?? item['judul_asesmen'] ?? item['nama_asesor'] ?? '').toString().toLowerCase();
        final tuk = (item['tuk'] ?? '').toString().toLowerCase();
        final tgl = (item['tanggal'] ?? '').toString().toLowerCase();
        return nama.contains(q) || tuk.contains(q) || tgl.contains(q);
      }).toList();
    }

    _filteredItems = result;
  }

  void _navigateToHonorDetail(Map<String, dynamic> item) {
    final user = AuthRepository.currentUserInstance;
    final bool isAsesor = user?.role == 'asesor';

    if (isAsesor) {
      final String status = item['status'] ?? 'Selesai';
      final String metodePembayaran = item['metode_pembayaran'] ?? 'Transfer Bank';
      final String tanggalPembayaran =
          item['tanggal_pembayaran'] ?? item['tanggal'] ?? '';
      final String noTransfer = item['no_transfer'] ?? '-';
      final int jumlahAsesmen = item['jumlah_asesi'] ?? item['jumlah_asesmen'] ?? 1;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailHonorScreen(
            detail: item,
            status: status,
            metodePembayaran: metodePembayaran,
            tanggalPembayaran: tanggalPembayaran,
            noTransfer: noTransfer,
            jumlahAsesmen: jumlahAsesmen,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTugasAsesorScreen(
          asesorData: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [

          // Header
          CustomAppBar(
            title: 'Honor Asessor',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
              onSelected: (val) {
                if (val == 'refresh') {
                  _fetchHonorData();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text('Refresh Data', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs Row (Matching Jadwal Pill Style)
          _buildPillTabs(),

          // Search & Date Filter Row
          _buildSearchAndFilterRow(),
          const SizedBox(height: 12),

          // Loading bar or List Content
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHonorData,
              color: const Color(0xFF378CE7),
              child: _filteredItems.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Data honor tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: _buildHonorCard(_filteredItems[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPillTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPillTab(index: 0, label: 'Semua'),
          const SizedBox(width: 8),
          _buildPillTab(index: 1, label: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildPillTab({required int index, required String label}) {
    final isSelected = _selectedTabIndex == index;
    final containerColor = isSelected ? const Color(0xFF6C8BB4) : const Color(0xFFD2E3F4);
    final textColor = isSelected ? Colors.white : const Color(0xFF5A7EAA);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final String nextStatus = index == 1 ? 'selesai' : 'semua';
          setState(() {
            _selectedTabIndex = index;
          });
          _fetchHonorData(nextStatus);
        },
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    if (mounted) {
                      setState(() {
                        _searchQuery = val;
                        _updateFilteredItems();
                      });
                    }
                  });
                },
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari nama asesor/skema',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _updateFilteredItems();
                            });
                          },
                        )
                      : null,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Month Picker Button
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF475569),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedMonthLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
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

  Widget _buildHonorCard(Map<String, dynamic> item) {
    String namaJadwal = (item['nama_jadwal'] ?? item['judul_asesmen'] ?? item['skema'] ?? '').toString();
    namaJadwal = namaJadwal.replaceAll(RegExp(r'^Uji Kompetensi:\s*', caseSensitive: false), '').trim();
    if (namaJadwal.isEmpty) {
      namaJadwal = (item['nama_asesor'] ?? 'Jadwal Asesmen').toString();
    }

    final String tuk = (item['tuk'] ?? '-').toString().trim();
    final String tanggal = (item['tanggal'] ?? '').toString().trim();
    final String honor = item['honor'] ?? 'Rp 0';
    final String status = item['status'] ?? 'Selesai';
    final bool isSelesai = status.toLowerCase() == 'selesai' || status.toLowerCase() == 'complete';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _navigateToHonorDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nama Jadwal & Info TUK + Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaJadwal,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (tuk.isNotEmpty && tuk != '-') ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tuk,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (tanggal.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tanggal,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Honor Amount & Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      honor,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelesai ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSelesai ? 'Selesai' : 'Menunggu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
