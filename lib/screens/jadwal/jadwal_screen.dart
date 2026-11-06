import 'dart:async';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../widgets/jadwal/jadwal_list_view.dart';
import '../../widgets/jadwal/jadwal_tab_content.dart';
import '../../widgets/jadwal/custom_tab_bar.dart';
import '../../widgets/jadwal/jadwal_search_date_row.dart';
import '../../services/auth/auth_repository.dart';

import '../../utils/date_format_helper.dart';

class JadwalScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const JadwalScreen({super.key, this.onBackToHome});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreDraft = true;
  bool _hasMoreRunning = true;
  bool _hasMorePelaporan = true;
  bool _hasMoreSelesai = true;

  final int _pageSize = 20;

  // Mock user role - dalam implementasi nyata, ambil dari auth service
  UserRole get currentUser {
    final user = AuthRepository.currentUserInstance;
    return UserRole(
      role: user?.role ?? 'admin',
      name: user?.name ?? 'Admin User',
      email: user?.email ?? 'admin@lsp.com',
    );
  }

  // Data dari API
  List<JadwalItem> draftList = [];
  List<JadwalItem> runningList = [];
  List<JadwalItem> pelaporanList = [];
  List<JadwalItem> selesaiList = [];

  // Statistics from API
  JadwalStatistik? _statistik;
  int totalAsesmen = 0;
  String trendPercentage = '+0%';

  int get _draftBadgeCount => _statistik?.draft ?? draftList.length;
  int get _runningBadgeCount =>
      _statistik?.sedangBerjalan ?? runningList.length;
  int get _pelaporanBadgeCount => _statistik?.pelaporan ?? pelaporanList.length;
  int get _selesaiBadgeCount => _statistik?.selesai ?? selesaiList.length;

  // Scroll controllers for pagination
  final ScrollController _scrollControllerDraft = ScrollController();
  final ScrollController _scrollControllerRunning = ScrollController();
  final ScrollController _scrollControllerPelaporan = ScrollController();
  final ScrollController _scrollControllerSelesai = ScrollController();

  // Search state — hanya tab Selesai (request Roy: biar gak berat)
  // Kriteria: tanggal asesmen + TUK
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  bool _isSearchingSelesai = false;
  DateTime? _selectedDate;

  int get _overdueRunningCount {
    if (_statistik != null && _statistik!.runningLewatTanggal > 0) {
      return _statistik!.runningLewatTanggal;
    }
    return runningList.where(_isItemOverdue).length;
  }

  bool _isItemOverdue(JadwalItem item) {
    if (item.daysLate != null && item.daysLate! > 0) return true;
    final endDt = _parseJadwalItemDate(item.tanggalSelesai) ?? _parseJadwalItemDate(item.tanggalMulai);
    if (endDt != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime(endDt.year, endDt.month, endDt.day);
      return today.isAfter(end);
    }
    return false;
  }

  DateTime? _parseJadwalItemDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  bool get _isAsesiRole => currentUser.role == 'asesi';
  bool get _isAsesorRole => currentUser.role == 'asesor';
  bool get _isAdminRole =>
      currentUser.role == 'admin' || (!_isAsesiRole && !_isAsesorRole);

  /// Index tab Selesai per role. Asesi tidak punya tab Selesai.
  int get _selesaiTabIndex {
    if (_isAsesiRole) return -1;
    if (_isAsesorRole) return 2; // Menunggu, Dibatalkan, Selesai
    return 3; // Admin: Draft, Running, Pelaporan, Selesai
  }

  bool get _isOnSelesaiTab =>
      _selesaiTabIndex >= 0 && _tabController.index == _selesaiTabIndex;

  /// Tanggal asesmen dari date picker untuk query param terpisah
  String? get _selesaiTanggalParam {
    if (_selectedDate == null) return null;
    return DateFormat('yyyy-MM-dd').format(_selectedDate!);
  }

  /// TUK dari search bar untuk query param terpisah
  String? get _selesaiTukParam {
    final q = _searchQuery.trim();
    return q.isEmpty ? null : q;
  }

  @override
  void initState() {
    super.initState();
    final bool isAsesi = _isAsesiRole;
    final bool isAdmin = _isAdminRole;
    _tabController = TabController(
      length: isAsesi ? 2 : (isAdmin ? 4 : 3),
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _loadJadwalData();

    // Setup scroll listeners for pagination
    _scrollControllerDraft.addListener(_onScrollDraft);
    _scrollControllerRunning.addListener(_onScrollRunning);
    _scrollControllerPelaporan.addListener(_onScrollPelaporan);
    _scrollControllerSelesai.addListener(_onScrollSelesai);
  }

  void _onTabChanged() {
    if (!mounted || _tabController.indexIsChanging) return;
    setState(() {}); // show/hide search bar when switching tabs
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollControllerDraft.dispose();
    _scrollControllerRunning.dispose();
    _scrollControllerPelaporan.dispose();
    _scrollControllerSelesai.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce biar gak nembak API tiap ketik
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query == _searchQuery) return;
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
      });
      // Hanya reload tab Selesai — tab lain tidak ikut di-query ulang
      _reloadSelesaiOnly();
    });
  }

  /// Reset pencarian tab Selesai secara bersih
  void _resetSelesaiSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _selectedDate = null;
    });
    _reloadSelesaiOnly();
  }

  /// Filter client-side: tanggal (dari date picker) + TUK (dari search bar).
  /// Keduanya filter bersamaan (AND) — tidak saling timpa.
  List<JadwalItem> _filterSelesaiByTanggalDanTuk(List<JadwalItem> items) {
    final q = _searchQuery.trim().toLowerCase();
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!).toLowerCase()
        : '';
    if (q.isEmpty && dateStr.isEmpty) return items;
    return items.where((item) {
      final tanggalMulai = item.tanggalMulai.toLowerCase();
      final tanggalSelesai = item.tanggalSelesai.toLowerCase();
      final tuk = item.tuk.toLowerCase();
      final formattedMulaiShort = DateFormatHelper.formatToShort(
        item.tanggalMulai,
      ).toLowerCase();
      final formattedMulaiIndo = DateFormatHelper.formatToIndonesian(
        item.tanggalMulai,
      ).toLowerCase();

      // Filter TUK: jika search bar diisi, item harus cocok
      final tukMatch =
          q.isEmpty ||
          tuk.contains(q) ||
          tanggalMulai.contains(q) ||
          tanggalSelesai.contains(q) ||
          formattedMulaiShort.contains(q) ||
          formattedMulaiIndo.contains(q);

      // Filter tanggal: jika date picker dipilih, item harus cocok
      final dateMatch =
          dateStr.isEmpty ||
          tanggalMulai.contains(dateStr) ||
          tanggalSelesai.contains(dateStr) ||
          formattedMulaiShort.contains(dateStr) ||
          formattedMulaiIndo.contains(dateStr);

      return tukMatch && dateMatch;
    }).toList();
  }

  Future<void> _reloadSelesaiOnly() async {
    if (_selesaiTabIndex < 0) return;
    if (!mounted) return;

    setState(() {
      _isSearchingSelesai = true;
      _hasMoreSelesai = true;
    });

    try {
      final raw = await JadwalService.getJadwalForRole(
        role: currentUser.role,
        view: JadwalView.selesai,
        limit: _pageSize,
        tanggalAsesmen: _selesaiTanggalParam,
        tuk: _selesaiTukParam,
      );

      if (!mounted) return;
      setState(() {
        selesaiList = _sortJadwalList(_filterSelesaiByTanggalDanTuk(raw));
        _hasMoreSelesai = raw.length >= _pageSize;
        _isSearchingSelesai = false;
      });
    } catch (e) {
      debugPrint('🔴 Error reloading selesai search: $e');
      if (!mounted) return;
      setState(() {
        _isSearchingSelesai = false;
      });
    }
  }

  // Scroll listeners for pagination
  void _onScrollDraft() {
    if (_scrollControllerDraft.position.pixels >=
        _scrollControllerDraft.position.maxScrollExtent - 200) {
      _loadMoreDraft();
    }
  }

  void _onScrollRunning() {
    if (_scrollControllerRunning.position.pixels >=
        _scrollControllerRunning.position.maxScrollExtent - 200) {
      _loadMoreRunning();
    }
  }

  void _onScrollPelaporan() {
    if (_scrollControllerPelaporan.position.pixels >=
        _scrollControllerPelaporan.position.maxScrollExtent - 200) {
      _loadMorePelaporan();
    }
  }

  void _onScrollSelesai() {
    if (_scrollControllerSelesai.position.pixels >=
        _scrollControllerSelesai.position.maxScrollExtent - 200) {
      _loadMoreSelesai();
    }
  }

  Future<void> _loadJadwalData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasMoreDraft = true;
      _hasMoreRunning = true;
      _hasMorePelaporan = true;
      _hasMoreSelesai = true;
    });

    try {
      final role = currentUser.role;
      final isAsesi = role == 'asesi';
      final isAsesor = role == 'asesor';
      final isAdmin = role == 'admin' || (!isAsesi && !isAsesor);

      final listFutures = <Future<List<JadwalItem>>>[
        if (isAdmin)
          JadwalService.getJadwalForRole(
            role: role,
            view: JadwalView.draft,
            limit: _pageSize,
          ),
        JadwalService.getJadwalForRole(
          role: role,
          view: JadwalView.running,
          limit: _pageSize,
        ),
        JadwalService.getJadwalForRole(
          role: role,
          view: JadwalView.pelaporan,
          limit: _pageSize,
        ),
        JadwalService.getJadwalForRole(
          role: role,
          view: JadwalView.selesai,
          limit: _pageSize,
          tanggalAsesmen: _selesaiTanggalParam,
          tuk: _selesaiTukParam,
        ),
      ];

      final results = await Future.wait([
        Future.wait(listFutures),
        if (isAdmin) JadwalService.getJadwalStatistics(),
      ]);

      if (!mounted) return;

      final lists = results[0] as List<List<JadwalItem>>;
      final stats = isAdmin ? results[1] as JadwalStatistik : null;

      setState(() {
        int resultIndex = 0;
        if (isAdmin) {
          final rawDraft = lists[resultIndex];
          draftList = _sortJadwalList(rawDraft);
          _hasMoreDraft = rawDraft.length >= _pageSize;
          resultIndex++;
        }

        final rawRunning = lists[resultIndex];
        runningList = _sortJadwalList(rawRunning);
        _hasMoreRunning = rawRunning.length >= _pageSize;
        resultIndex++;

        final rawPelaporan = lists[resultIndex];
        pelaporanList = _sortJadwalList(rawPelaporan);
        _hasMorePelaporan = rawPelaporan.length >= _pageSize;
        resultIndex++;

        final rawSelesai = lists[resultIndex];
        selesaiList = _sortJadwalList(
          _filterSelesaiByTanggalDanTuk(rawSelesai),
        );
        _hasMoreSelesai = rawSelesai.length >= _pageSize;

        _statistik = stats;
        totalAsesmen =
            stats?.totalJadwal ??
            (runningList.length +
                pelaporanList.length +
                selesaiList.length +
                draftList.length);
        trendPercentage = stats?.trendPercentage ?? trendPercentage;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading jadwal data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load more methods for pagination
  Future<void> _loadMoreDraft() async {
    if (_isLoadingMore || !_hasMoreDraft) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newData = await JadwalService.getJadwalForRole(
        role: currentUser.role,
        view: JadwalView.draft,
        limit: _pageSize,
        offset: draftList.length,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreDraft = false;
        }
        draftList.addAll(_sortJadwalList(newData));
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more draft data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreRunning() async {
    if (_isLoadingMore || !_hasMoreRunning) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newData = await JadwalService.getJadwalForRole(
        role: currentUser.role,
        view: JadwalView.running,
        limit: _pageSize,
        offset: runningList.length,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreRunning = false;
        }
        runningList.addAll(_sortJadwalList(newData));
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more running data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePelaporan() async {
    if (_isLoadingMore || !_hasMorePelaporan) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newData = await JadwalService.getJadwalForRole(
        role: currentUser.role,
        view: JadwalView.pelaporan,
        limit: _pageSize,
        offset: pelaporanList.length,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMorePelaporan = false;
        }
        pelaporanList.addAll(_sortJadwalList(newData));
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more pelaporan data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreSelesai() async {
    if (_isLoadingMore || !_hasMoreSelesai) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newData = await JadwalService.getJadwalForRole(
        role: currentUser.role,
        view: JadwalView.selesai,
        limit: _pageSize,
        offset: selesaiList.length,
        tanggalAsesmen: _selesaiTanggalParam,
        tuk: _selesaiTukParam,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreSelesai = false;
        }
        selesaiList.addAll(
          _sortJadwalList(_filterSelesaiByTanggalDanTuk(newData)),
        );
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more selesai data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Sort jadwal list by tanggal DESC, then by ID DESC for consistent ordering
  List<JadwalItem> _sortJadwalList(List<JadwalItem> items) {
    final sorted = List<JadwalItem>.from(items);
    sorted.sort((a, b) {
      // Primary sort: by tanggalMulai DESC (terbaru dulu)
      final dateCompare = b.tanggalMulai.compareTo(a.tanggalMulai);
      if (dateCompare != 0) return dateCompare;

      // Secondary sort: by ID DESC (ID lebih besar = data lebih baru)
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  Future<void> _selectDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _reloadSelesaiOnly();
    }
  }

  Widget _buildSearchAndDateRow() {
    return JadwalSearchDateRow(
      searchController: _searchController,
      isSearching: _isSearchingSelesai,
      searchQuery: _searchQuery,
      selectedDate: _selectedDate,
      onSearchChanged: _onSearchChanged,
      onResetSearch: _resetSelesaiSearch,
      onSelectDate: _selectDateFilter,
    );
  }

  Future<void> _handleRefresh() async {
    await _loadJadwalData();

    // Tampilkan feedback ke user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header dengan style dari statistik_screen
          _buildAppBar(),

          // Search field & Date filter — hanya tab Selesai (tanggal asesmen + TUK)
          if (_isOnSelesaiTab) _buildSearchAndDateRow(),

          // Loading indicator
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: JadwalTabBar(
                controller: _tabController,
                draftCount: _draftBadgeCount,
                runningCount: _runningBadgeCount,
                pelaporanCount: _pelaporanBadgeCount,
                selesaiCount: _selesaiBadgeCount,
              ),
            ),

            // Tab Content with caching
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Draft (Only for Admin) — status_jadwal=0
                  if (currentUser.role == 'admin' ||
                      (currentUser.role != 'asesi' &&
                          currentUser.role != 'asesor'))
                    JadwalTabContent(
                      key: const PageStorageKey('draft_tab'),
                      child: _buildJadwalList(
                        draftList,
                        'draft',
                        _scrollControllerDraft,
                        _hasMoreDraft,
                        showCreatedDate: true,
                      ),
                    ),

                  // Tab 1: Sedang Berjalan (Mendatang for Asesi)
                  JadwalTabContent(
                    key: const PageStorageKey('sedang_berjalan_tab'),
                    child: Column(
                      children: [
                        if (_overdueRunningCount > 0 && !_isAsesiRole)
                          _buildOverdueSummaryBanner(),
                        Expanded(
                          child: _buildJadwalList(
                            runningList,
                            'running',
                            _scrollControllerRunning,
                            _hasMoreRunning,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Berjalan (Pelaporan for Admin/Asesor)
                  JadwalTabContent(
                    key: const PageStorageKey('pelaporan_tab'),
                    child: _buildJadwalList(
                      pelaporanList,
                      'sedang_berjalan',
                      _scrollControllerPelaporan,
                      _hasMorePelaporan,
                    ),
                  ),

                  // Tab 3: Selesai (Only for non-Asesi)
                  if (!_isAsesiRole)
                    JadwalTabContent(
                      key: const PageStorageKey('selesai_tab'),
                      child: _buildJadwalList(
                        selesaiList,
                        'selesai',
                        _scrollControllerSelesai,
                        _hasMoreSelesai,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJadwalList(
    List<JadwalItem> items,
    String status,
    ScrollController controller,
    bool hasMore, {
    bool showCreatedDate = false,
  }) {
    return JadwalListView(
      items: items,
      controller: controller,
      hasMore: hasMore,
      isLoadingMore: _isLoadingMore,
      showCreatedDate: showCreatedDate,
      userRole: currentUser,
      onRefresh: _handleRefresh,
      onItemUpdated: _loadJadwalData,
    );
  }

  Widget _buildOverdueSummaryBanner() {
    final count = _overdueRunningCount;
    final total = _runningBadgeCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.triangle_exclamation_point,
              size: 18,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count Jadwal Lewat Tanggal Uji',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count dari $total jadwal running telah melewati tanggal asesmen & belum dilaporkan.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB45309),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isAsesi = currentUser.role == 'asesi';
    final bool isAsesor = currentUser.role == 'asesor';

    return CustomAppBar(
      title: (isAsesi || isAsesor) ? 'Jadwal Saya' : 'Jadwal Asesmen',
      onBack: () {
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
// ============================================================================
// Tab Content Wrapper with AutomaticKeepAlive
// ============================================================================
// Wrapper untuk keep tab state agar tidak re-render saat pindah tab
