import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../widgets/career_expo/career_filter_sheet.dart';
import '../../widgets/career_expo/career_job_card.dart';
import 'career_expo_detail_screen.dart';

/// Tab / Layar Pencarian Lowongan Career Expo sesuai Screen 2
class CareerExpoSearchTab extends StatefulWidget {
  final String initialQuery;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CareerExpoSearchTab({
    super.key,
    this.initialQuery = 'UI/UX',
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<CareerExpoSearchTab> createState() => _CareerExpoSearchTabState();
}

class _CareerExpoSearchTabState extends State<CareerExpoSearchTab> {
  late TextEditingController _searchController;
  late List<CareerJobItem> _allJobs;
  String _selectedSortChip = 'Paling Relevan';
  String _empTypeFilter = 'Semua';
  String _workplaceTypeFilter = 'Semua';
  String _locationFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _allJobs = CareerExpoMockData.getJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CareerFilterSheet(
        selectedEmploymentType: _empTypeFilter,
        selectedWorkplaceType: _workplaceTypeFilter,
        selectedLocation: _locationFilter,
        onApply: (emp, wp, loc) {
          setState(() {
            _empTypeFilter = emp;
            _workplaceTypeFilter = wp;
            _locationFilter = loc;
          });
        },
      ),
    );
  }

  List<CareerJobItem> _getFilteredJobs() {
    final query = _searchController.text.trim().toLowerCase();
    return _allJobs.where((job) {
      // Query search
      if (query.isNotEmpty) {
        final matchTitle = job.title.toLowerCase().contains(query);
        final matchCompany = job.companyName.toLowerCase().contains(query);
        final matchLocation = job.location.toLowerCase().contains(query);
        if (!matchTitle && !matchCompany && !matchLocation) return false;
      }
      // Employment type filter
      if (_empTypeFilter != 'Semua' &&
          job.employmentType.toLowerCase() != _empTypeFilter.toLowerCase()) {
        return false;
      }
      // Workplace filter
      if (_workplaceTypeFilter != 'Semua' &&
          job.workplaceType.toLowerCase() != _workplaceTypeFilter.toLowerCase()) {
        return false;
      }
      // Location filter
      if (_locationFilter != 'Semua' &&
          job.location.toLowerCase() != _locationFilter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _getFilteredJobs();
    final hasActiveFilter =
        _empTypeFilter != 'Semua' || _workplaceTypeFilter != 'Semua' || _locationFilter != 'Semua';

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
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Cari posisi atau perusahaan...',
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
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
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
                  InkWell(
                    onTap: _openFilterSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: hasActiveFilter ? const Color(0xFF0066F6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasActiveFilter
                              ? const Color(0xFF0066F6)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: hasActiveFilter ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Quick Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildSortChip('Paling Relevan'),
                  const SizedBox(width: 8),
                  _buildSortChip('Terbaru'),
                  const SizedBox(width: 8),
                  _buildSortChip('Gaji'),
                  const SizedBox(width: 8),
                  // Filter dropdown chip
                  InkWell(
                    onTap: _openFilterSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: hasActiveFilter ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasActiveFilter
                              ? const Color(0xFF0066F6)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: hasActiveFilter
                                ? const Color(0xFF0066F6)
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasActiveFilter ? 'Filter (Aktif)' : 'Filter',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: hasActiveFilter
                                  ? const Color(0xFF0066F6)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: hasActiveFilter
                                ? const Color(0xFF0066F6)
                                : const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Results Count Text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                _searchController.text.isNotEmpty
                    ? '${filteredJobs.length} lowongan ditemukan untuk "${_searchController.text}"'
                    : '${filteredJobs.length} lowongan tersedia',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            // Job List
            Expanded(
              child: filteredJobs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
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
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Lowongan tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Coba ganti kata kunci pencarian atau sesuaikan filter Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
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
                          onBookmarkToggle: (val) {
                            setState(() {
                              final idx = _allJobs.indexWhere((j) => j.id == job.id);
                              if (idx != -1) {
                                _allJobs[idx] = _allJobs[idx].copyWith(isBookmarked: val);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSortChip == label;
    return InkWell(
      onTap: () {
        setState(() => _selectedSortChip = label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
}
