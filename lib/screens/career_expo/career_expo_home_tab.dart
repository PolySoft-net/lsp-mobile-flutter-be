import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../widgets/career_expo/career_filter_sheet.dart';
import '../../widgets/career_expo/career_job_card.dart';
import 'career_expo_detail_screen.dart';

/// Tab Beranda Career Expo sesuai Screen 1
class CareerExpoHomeTab extends StatefulWidget {
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToNotification;

  const CareerExpoHomeTab({
    super.key,
    required this.onNavigateToSearch,
    required this.onNavigateToNotification,
  });

  @override
  State<CareerExpoHomeTab> createState() => _CareerExpoHomeTabState();
}

class _CareerExpoHomeTabState extends State<CareerExpoHomeTab> {
  String _selectedCategory = 'Semua Pekerjaan';
  late List<CareerJobItem> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = CareerExpoMockData.getJobs();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CareerFilterSheet(
        selectedEmploymentType: 'Semua',
        selectedWorkplaceType: 'Semua',
        selectedLocation: 'Semua',
        onApply: (emp, wp, loc) {
          widget.onNavigateToSearch();
        },
      ),
    );
  }

  List<CareerJobItem> _getFilteredByCategory() {
    if (_selectedCategory == 'Semua Pekerjaan') {
      return _jobs;
    }
    return _jobs.where((j) => j.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final popularJobs = _jobs.where((j) => j.isPopular).toList();
    final categoryFilteredJobs = _getFilteredByCategory();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header App Bar: Logo LSP + Notification Bell
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF0066F6),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'LSP Teknologi Digital',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Notification Bell with Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: widget.onNavigateToNotification,
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF0F172A),
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Search Bar & Filter Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: widget.onNavigateToSearch,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Cari posisi, perusahaan, atau kata kunci...',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Category Buttons Row (Semua Pekerjaan, Remote, On Site, Magang)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryItem(
                      'Semua Pekerjaan',
                      Icons.work_outline_rounded,
                    ),
                    _buildCategoryItem(
                      'Remote',
                      Icons.laptop_chromebook_rounded,
                    ),
                    _buildCategoryItem(
                      'On Site',
                      Icons.apartment_rounded,
                    ),
                    _buildCategoryItem(
                      'Magang',
                      Icons.school_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Promo Banner Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEBF5FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      // Text column
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Siap naik level\nkarier di dunia digital?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Dapatkan pekerjaan terbaik sesuai dengan kompetensimu.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF475569),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: widget.onNavigateToSearch,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Tips Karier',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0066F6),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Color(0xFF0066F6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Graphic Illustration
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 10,
                                left: 14,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFBFDBFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.military_tech_rounded,
                                    size: 14,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.computer_rounded,
                                size: 52,
                                color: Color(0xFF0066F6),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section Header: Pekerjaan Populer + Lihat Semua
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pekerjaan Populer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: widget.onNavigateToSearch,
                      child: const Row(
                        children: [
                          Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066F6),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF0066F6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal Scrollable Cards
              SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: popularJobs.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final job = popularJobs[index];
                    return CareerJobCard(
                      job: job,
                      isHorizontalCompact: true,
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
                          final idx = _jobs.indexWhere((j) => j.id == job.id);
                          if (idx != -1) {
                            _jobs[idx] = _jobs[idx].copyWith(isBookmarked: val);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Section Header: Rekomendasi Berdasarkan Kategori
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedCategory == 'Semua Pekerjaan'
                      ? 'Semua Lowongan Tersedia'
                      : 'Lowongan $_selectedCategory',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Vertical Job Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryFilteredJobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = categoryFilteredJobs[index];
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
                          final idx = _jobs.indexWhere((j) => j.id == job.id);
                          if (idx != -1) {
                            _jobs[idx] = _jobs[idx].copyWith(isBookmarked: val);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    final isSelected = _selectedCategory == title;
    return InkWell(
      onTap: () {
        setState(() => _selectedCategory = title);
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0066F6) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0066F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF475569),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0066F6) : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
