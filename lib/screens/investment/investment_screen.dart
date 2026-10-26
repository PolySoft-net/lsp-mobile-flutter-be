import 'dart:async';
import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(
          child: CustomAppBar(
            title: 'Katalog Startup & Investasi',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            rightWidget: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF0F172A)),
              tooltip: 'Filter',
              onPressed: _openFilterSheet,
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
        backgroundColor: const Color(0xFF0D9488),
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
        color: const Color(0xFF0D9488),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Banner + Stats Section
            SliverToBoxAdapter(
              child: _buildBannerAndStats(),
            ),

            // Search Bar & Filter summary
            SliverToBoxAdapter(
              child: _buildSearchBox(),
            ),

            // Category Chips
            SliverToBoxAdapter(
              child: _buildCategoryChips(),
            ),

            // Tab Selector
            SliverToBoxAdapter(
              child: _buildTabSelector(),
            ),

            // Content List
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

  Widget _buildBannerAndStats() {
    final fundingStr = _stats.totalFunding > 0
        ? 'Rp ${NumberFormatHelper.formatCompactJt(_stats.totalFunding)}'
        : 'Rp 0';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D9488).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portal Investasi Startup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Peluang pendanaan & kolaborasi inovasi LSP',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0x33FFFFFF), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Startup', '${_stats.totalStartups}'),
                _buildStatItem('Kebutuhan Dana', fundingStr),
                _buildStatItem('Sektor Aktif', '${_stats.activeSectors}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 10.5,
          ),
        ),
      ],
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
              selectedColor: const Color(0xFF0D9488),
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
                      ? const Color(0xFF0D9488)
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
