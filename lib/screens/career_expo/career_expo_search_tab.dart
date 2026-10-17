import 'dart:async';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../widgets/career_expo/career_bouncy_tap.dart';
import '../../widgets/career_expo/career_filter_sheet.dart';
import '../../widgets/career_expo/career_job_card.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
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
                    const SizedBox(width: 8),
                  ],
                  // Search field
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _fetchJobs(),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Cari posisi, perusahaan, atau lokasi...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  color: const Color(0xFF64748B),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter icon button
                  CareerBouncyTap(
                    onTap: _openFilterSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _hasActiveFilter ? const Color(0xFF0066F6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasActiveFilter
                              ? const Color(0xFF0066F6)
                              : const Color(0xFFCBD5E1),
                          width: _hasActiveFilter ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_hasActiveFilter ? const Color(0xFF0066F6) : Colors.black)
                                .withValues(alpha: _hasActiveFilter ? 0.25 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: _hasActiveFilter ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic Filter Pills Row
            _buildPillsRow(),

            // Results Count Text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                _searchController.text.isNotEmpty
                    ? '${_jobs.length} lowongan ditemukan untuk "${_searchController.text}"'
                    : '${_jobs.length} lowongan tersedia',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),

            // Job List Body
            Expanded(
              child: _buildJobList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Filter Sheet Button
          CareerBouncyTap(
            onTap: _openFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _hasActiveFilter ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasActiveFilter
                      ? const Color(0xFF0066F6)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: _hasActiveFilter
                        ? const Color(0xFF0066F6)
                        : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hasActiveFilter ? 'Filter (Aktif)' : 'Filter',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _hasActiveFilter
                          ? const Color(0xFF0066F6)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _hasActiveFilter
                        ? const Color(0xFF0066F6)
                        : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Active Location Tag with clear button
          if (_locationFilter != 'Semua') ...[
            _buildActiveTagPill(
              label: '📍 $_locationFilter',
              onClear: () {
                setState(() => _locationFilter = 'Semua');
                _fetchJobs();
              },
            ),
            const SizedBox(width: 8),
          ],

          // Sort Pills
          _buildSortChip('Paling Relevan'),
          const SizedBox(width: 8),
          _buildSortChip('Terbaru'),
          const SizedBox(width: 8),
          _buildSortChip('Gaji'),
          const SizedBox(width: 8),

          // Dynamic Workplace Pills from API
          ..._filterOptions.workplaceTypes
              .where((wp) => wp != 'Semua')
              .map((wp) {
            final isSelected = _workplaceTypeFilter == wp;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterPill(
                label: wp,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _workplaceTypeFilter = isSelected ? 'Semua' : wp;
                  });
                  _fetchJobs();
                },
              ),
            );
          }),

          // Dynamic Employment Type Pills from API
          ..._filterOptions.employmentTypes
              .where((emp) => emp != 'Semua')
              .map((emp) {
            final isSelected = _empTypeFilter == emp;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterPill(
                label: emp,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _empTypeFilter = isSelected ? 'Semua' : emp;
                  });
                  _fetchJobs();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSortChip == label;
    return CareerBouncyTap(
      onTap: () {
        setState(() => _selectedSortChip = label);
        _fetchJobs();
      },
      scaleDown: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CareerBouncyTap(
      onTap: onTap,
      scaleDown: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTagPill({
    required String label,
    required VoidCallback onClear,
  }) {
    return CareerBouncyTap(
      onTap: onClear,
      scaleDown: 0.94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0066F6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066F6),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.close_rounded,
              size: 14,
              color: Color(0xFF0066F6),
            ),
          ],
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

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: const Color(0xFF0066F6),
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return CareerJobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CareerExpoDetailScreen(job: job),
                ),
              );
            },
            onBookmarkToggle: (val) => _toggleBookmark(job, val),
          );
        },
      ),
    );
  }
}
