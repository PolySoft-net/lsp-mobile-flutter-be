import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/investment_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../utils/url_helper.dart';
import '../../widgets/investment/investment_filter_sheet.dart';
import '../../widgets/investment/investment_startup_card.dart';
import 'investment_detail_screen.dart';
import 'investment_form_screen.dart';

class InvestmentScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const InvestmentScreen({super.key, this.onBackToHome});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  int _selectedTab = 0; // 0: Jelajah, 1: Startup Saya, 2: Favorit
  String _selectedCategory = 'Semua';
  String _selectedStage = 'Semua';
  String _selectedSort = '';

  bool _isLoading = true;
  String? _error;
  List<InvestmentStartupItem> _startups = [];
  List<InvestmentStartupItem> _myStartups = [];
  List<InvestmentStartupItem> _favoriteStartups = [];
  InvestmentStats _stats = const InvestmentStats();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        InvestmentService.getStartups(
          search: _searchController.text,
          category: _selectedCategory,
          stage: _selectedStage,
          sortBy: _selectedSort,
        ),
        InvestmentService.getMyStartups().catchError((_) => <InvestmentStartupItem>[]),
        InvestmentService.getFavoriteStartups().catchError((_) => <InvestmentStartupItem>[]),
        InvestmentService.getStats(),
      ]);

      if (!mounted) return;
      setState(() {
        _startups = results[0] as List<InvestmentStartupItem>;
        _myStartups = results[1] as List<InvestmentStartupItem>;
        _favoriteStartups = results[2] as List<InvestmentStartupItem>;
        _stats = results[3] as InvestmentStats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat katalog startup. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadAll();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvestmentFilterSheet(
        selectedCategory: _selectedCategory,
        selectedStage: _selectedStage,
        selectedSort: _selectedSort,
        onApply: (cat, stage, sort) {
          setState(() {
            _selectedCategory = cat;
            _selectedStage = stage;
            _selectedSort = sort;
          });
          _loadAll();
        },
      ),
    );
  }

  Future<void> _toggleFavorite(InvestmentStartupItem startup) async {
    final nextState = !startup.isFavorite;
    try {
      await InvestmentService.toggleFavorite(startup.id, startup.isFavorite);
      if (!mounted) return;
      _loadAll();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nextState
              ? 'Gagal menyimpan favorit'
              : 'Gagal menghapus favorit'),
        ),
      );
    }
  }

  List<InvestmentStartupItem> get _displayedItems {
    if (_selectedTab == 1) return _myStartups;
    if (_selectedTab == 2) return _favoriteStartups;
    return _startups;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUserInstance;
    final userName = user?.name.trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    if (Navigator.canPop(context) || widget.onBackToHome != null) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: Color(0xFF0F172A)),
                        onPressed: () {
                          if (widget.onBackToHome != null) {
                            widget.onBackToHome!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 4),
                    ],
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFFEFF6FF),
                      backgroundImage: user?.fotoProfilUrl != null &&
                              user!.fotoProfilUrl!.isNotEmpty
                          ? NetworkImage(UrlHelper.resolveUrl(user.fotoProfilUrl))
                          : null,
                      child: (user?.fotoProfilUrl == null ||
                              user!.fotoProfilUrl!.isEmpty)
                          ? const Icon(Icons.person,
                              color: Color(0xFF0066F6), size: 20)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Halo, ${userName.isNotEmpty ? userName : 'Nurmalia'}',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Selamat datang di LSP Teknologi Digital',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: Color(0xFF0F172A), size: 20),
                      tooltip: 'Filter',
                      onPressed: _openFilterSheet,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Color(0xFF0F172A), size: 22),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const InvestmentFormScreen(),
            ),
          );
          if (res == true) _loadAll();
        },
        backgroundColor: const Color(0xFF0066F6),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Daftarkan Startup',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: const Color(0xFF0066F6),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Blue Card "Total Portofolio Investasi" matching Image 1
            SliverToBoxAdapter(
              child: _buildPortfolioBanner(),
            ),

            // 2. Search & Filter Bar
            SliverToBoxAdapter(
              child: _buildSearchBox(),
            ),

            // 3. Category Chips
            SliverToBoxAdapter(
              child: _buildCategoryChips(),
            ),

            // 4. "Startup Pilihan" Section Header matching Image 1
            SliverToBoxAdapter(
              child: _buildSectionHeader(),
            ),

            // 5. Tab Selector
            SliverToBoxAdapter(
              child: _buildTabSelector(),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D9488),
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
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
                          onPressed: _loadAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_displayedItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedTab == 1
                              ? Icons.business_center_outlined
                              : (_selectedTab == 2
                                  ? Icons.bookmark_border_rounded
                                  : Icons.search_off_rounded),
                          size: 54,
                          color: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedTab == 1
                              ? 'Belum ada startup yang Anda daftarkan.'
                              : (_selectedTab == 2
                                  ? 'Belum ada startup tersimpan di favorit.'
                                  : 'Tidak ada startup yang sesuai dengan pencarian.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        if (_selectedTab == 1) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final res = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InvestmentFormScreen(),
                                ),
                              );
                              if (res == true) _loadAll();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              elevation: 0,
                            ),
                            child: const Text('Daftarkan Sekarang'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _displayedItems[index];
                      return InvestmentStartupCard(
                        startup: item,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InvestmentDetailScreen(startup: item),
                            ),
                          );
                          if (updated == true) _loadAll();
                        },
                        onToggleFavorite: () => _toggleFavorite(item),
                      );
                    },
                    childCount: _displayedItems.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioBanner() {
    final fundingVal = _stats.totalFunding > 0 ? _stats.totalFunding : 5000000;
    final fundingStr = NumberFormatHelper.formatWithDots(fundingVal);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066F6), Color(0xFF0049B7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066F6).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Portofolio Investasi',
              style: TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rp $fundingStr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Startup Pilihan',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = 'Semua';
                _selectedStage = 'Semua';
                _selectedSort = '';
                _searchController.clear();
              });
              _loadAll();
            },
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'Cari startup, masalah, solusi, founder...',
            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _loadAll();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: InvestmentFilterSheet.categories.map((c) {
          final isSelected = _selectedCategory == c;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c),
              selected: isSelected,
              selectedColor: const Color(0xFF0066F6),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0066F6)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = c);
                  _loadAll();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _buildTabButton(0, 'Jelajah (${_startups.length})'),
            _buildTabButton(1, 'Startup Saya (${_myStartups.length})'),
            _buildTabButton(2, 'Favorit (${_favoriteStartups.length})'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
