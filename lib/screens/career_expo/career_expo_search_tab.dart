import 'dart:async';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/career_expo/career_filter_sheet.dart';
import '../../widgets/common/company_logo.dart';
import 'career_expo_detail_screen.dart';

/// Tab Pencarian Lowongan Career Expo — filter dan sort dinamis dari API
class CareerExpoSearchTab extends StatefulWidget {
  final String initialQuery;
  final String? initialEmploymentType;
  final String? initialWorkplaceType;
  final String? initialLocation;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CareerExpoSearchTab({
    super.key,
    this.initialQuery = '',
    this.initialEmploymentType,
    this.initialWorkplaceType,
    this.initialLocation,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<CareerExpoSearchTab> createState() => _CareerExpoSearchTabState();
}

class _CareerExpoSearchTabState extends State<CareerExpoSearchTab> {
  late TextEditingController _searchController;
  List<CareerJobItem> _jobs = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;
  bool _isGridView = false;
  String _selectedSortChip = 'Paling Relevan';
  String _empTypeFilter = 'Semua';
  String _workplaceTypeFilter = 'Semua';
  String _locationFilter = 'Semua';
  CareerFilterOptions _filterOptions = const CareerFilterOptions();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onControllerChange);

    if (widget.initialEmploymentType != null) {
      _empTypeFilter = widget.initialEmploymentType!;
    }
    if (widget.initialWorkplaceType != null) {
      _workplaceTypeFilter = widget.initialWorkplaceType!;
    }
    if (widget.initialLocation != null) {
      _locationFilter = widget.initialLocation!;
    }

    _loadFilterOptions();
    _fetchJobs();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onControllerChange);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    final opts = await CareerExpoService.getFilterOptions();
    if (!mounted) return;
    setState(() => _filterOptions = opts);
  }

  String get _sortValue {
    switch (_selectedSortChip) {
      case 'Terbaru':
        return 'terbaru';
      case 'Gaji':
        return 'gaji';
      default:
        return 'relevan';
    }
  }

  /// GET /api/career-expo/lowongan — pencarian, sort, dan filter di server.
  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final jobs = await CareerExpoService.getLowongan(
        search: _searchController.text,
        employmentType: _empTypeFilter,
        workplaceType: _workplaceTypeFilter,
        location: _locationFilter,
        sortBy: _sortValue,
      );
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException && e.response != null
            ? 'Gagal memuat lowongan (kode ${e.response?.statusCode}).'
            : 'Tidak bisa terhubung ke server. Periksa koneksi internetmu.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _fetchJobs();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _fetchJobs();
  }

  Future<void> _toggleBookmark(CareerJobItem job, bool value) async {
    void update(bool v) {
      final idx = _jobs.indexWhere((j) => j.id == job.id);
      if (idx != -1) {
        _jobs[idx] = _jobs[idx].copyWith(isBookmarked: v);
      }
    }

    setState(() => update(value));
    try {
      await CareerExpoService.setTersimpan(job.id, value);
    } catch (e) {
      if (!mounted) return;
      setState(() => update(!value));
      final unauthorized = e is DioException && e.response?.statusCode == 401;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unauthorized
                ? 'Silakan login terlebih dahulu untuk menyimpan lowongan.'
                : 'Gagal memperbarui lowongan tersimpan. Coba lagi ya.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 320),
        reverseDuration: Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) => CareerFilterSheet(
        selectedEmploymentType: _empTypeFilter,
        selectedWorkplaceType: _workplaceTypeFilter,
        selectedLocation: _locationFilter,
        filterOptions: _filterOptions,
        onApply: (emp, wp, loc) {
          setState(() {
            _empTypeFilter = emp;
            _workplaceTypeFilter = wp;
            _locationFilter = loc;
          });
          _fetchJobs();
        },
      ),
    );
  }

  bool get _hasActiveFilter =>
      _empTypeFilter != 'Semua' ||
      _workplaceTypeFilter != 'Semua' ||
      _locationFilter != 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _fetchJobs(),
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Cari disini',
                          hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  color: const Color(0xFF64748B),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Filter icon button
                  IconButton(
                    onPressed: _openFilterSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  // Grid view button
                  IconButton(
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    icon: Icon(
                      _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      size: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            // 3 Sort/Filter Pills Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildSortChip('Paling Relevan'),
                  const SizedBox(width: 8),
                  _buildSortChip('Terbaru'),
                  const SizedBox(width: 8),
                  _buildSortChip('Gaji'),
                ],
              ),
            ),

            // Divider Line
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),

            // Results Count Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _searchController.text.trim().isNotEmpty
                    ? '${_jobs.length} Lowongan Ditemukan Untuk ${_searchController.text.trim()}'
                    : '${_jobs.length} Lowongan Ditemukan',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Job List Body
            Expanded(
              child: _buildJobList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSortChip(String label) {
    final isSelected = _selectedSortChip == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSortChip = label);
        _fetchJobs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    if (_isLoading && _jobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066F6)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xFF94A3B8)),
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _fetchJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak Ada Lowongan yang Cocok',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coba ubah kata kunci pencarian atau sesuaikan filter untuk menemukan lowongan yang tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              if (_hasActiveFilter || _searchController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _empTypeFilter = 'Semua';
                      _workplaceTypeFilter = 'Semua';
                      _locationFilter = 'Semua';
                    });
                    _fetchJobs();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066F6),
                    side: const BorderSide(color: Color(0xFF0066F6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reset Pencarian & Filter'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return RefreshIndicator(
        onRefresh: _fetchJobs,
        color: const Color(0xFF0066F6),
        child: GridView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 196,
          ),
          itemCount: _jobs.length,
          itemBuilder: (context, index) {
            final job = _jobs[index];
            return _buildGridJobCard(job);
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: const Color(0xFF0066F6),
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return _buildSearchJobCard(job);
        },
      ),
    );
  }

  Widget _buildSearchJobCard(CareerJobItem job) {
    final salaryText = NumberFormatHelper.formatSalaryRange(job.salaryMin, job.salaryMax);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CareerExpoDetailScreen(job: job),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo perusahaan (gambar asli dari hasil upload)
                  Align(
                    alignment: Alignment.topLeft,
                    child: CompanyLogo(
                      imageUrl: job.companyLogo,
                      size: 32,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                // Center information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _buildCardChip('+${job.employmentType}'),
                          _buildCardChip('+${job.workplaceType}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF334155),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 13,
                            color: Color(0xFF334155),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              salaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side: Bookmark & posted time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleBookmark(job, !job.isBookmarked),
                      child: Icon(
                        job.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: const Color(0xFF0F172A),
                        size: 22,
                      ),
                    ),
                    if (job.postedAt.isNotEmpty)
                      Text(
                        job.postedAt,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildGridJobCard(CareerJobItem job) {
    final salaryRange = NumberFormatHelper.formatSalaryRange(job.salaryMin, job.salaryMax);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CareerExpoDetailScreen(job: job),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanyLogo(
                      imageUrl: job.companyLogo,
                      size: 32,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _toggleBookmark(job, !job.isBookmarked),
                      child: Icon(
                        job.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  job.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildCardChip('+${job.employmentType}'),
                    _buildCardChip('+${job.workplaceType}'),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF334155),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 13,
                      color: Color(0xFF334155),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        salaryRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildCardChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


