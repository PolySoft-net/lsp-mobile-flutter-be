import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../widgets/common/company_logo.dart';
import '../../widgets/common/career_portal_banner.dart';
import 'career_expo_detail_screen.dart';
import '../../utils/number_format_helper.dart';

typedef CareerSearchNavigator = void Function({String? query, String? empType, String? workplaceType, String? location});

/// Tab Beranda Career Expo sesuai Screen 1
class CareerExpoHomeTab extends StatefulWidget {
  final CareerSearchNavigator onNavigateToSearch;
  final VoidCallback onNavigateToNotification;
  final int unreadNotifCount;

  const CareerExpoHomeTab({
    super.key,
    required this.onNavigateToSearch,
    required this.onNavigateToNotification,
    this.unreadNotifCount = 0,
  });

  @override
  State<CareerExpoHomeTab> createState() => _CareerExpoHomeTabState();
}

class _CareerExpoHomeTabState extends State<CareerExpoHomeTab> {
  String _selectedCategory = 'Semua Pekerjaan';
  List<CareerJobItem> _jobs = [];
  CareerFilterOptions _filterOptions = const CareerFilterOptions();
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  /// Muat lowongan dari GET /api/career-expo/lowongan.
  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        CareerExpoService.getLowongan(),
        CareerExpoService.getFilterOptions(),
      ]);
      if (!mounted) return;
      setState(() {
        _jobs = results[0] as List<CareerJobItem>;
        _filterOptions = results[1] as CareerFilterOptions;
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

  /// Simpan/hapus bookmark lewat API; kalau gagal, kembalikan state lama.
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

  bool get _isEmpTypeCategory =>
      _filterOptions.employmentTypes.any((e) => e.toLowerCase() == _selectedCategory.toLowerCase());

  String get _activeEmpType =>
      _selectedCategory == 'Magang' ? 'Magang' : (_isEmpTypeCategory ? _selectedCategory : 'Semua');

  String get _activeWorkplaceType =>
      _selectedCategory == 'Office'
          ? 'On Site'
          : ((!_isEmpTypeCategory && _selectedCategory != 'Semua Pekerjaan') ? _selectedCategory : 'Semua');

  List<CareerJobItem> _getFilteredByCategory() {
    if (_selectedCategory == 'Semua Pekerjaan') {
      return _jobs;
    }
    final q = _selectedCategory.toLowerCase();
    return _jobs.where((j) {
      if (q == 'office') {
        final wp = j.workplaceType.toLowerCase();
        return wp.contains('office') || wp.contains('on site') || wp.contains('onsite');
      }
      if (q == 'magang') {
        final emp = j.employmentType.toLowerCase();
        final cat = j.category.toLowerCase();
        return emp.contains('magang') || emp.contains('intern') || cat.contains('magang');
      }
      return j.category.toLowerCase() == q ||
          j.workplaceType.toLowerCase().contains(q) ||
          j.employmentType.toLowerCase().contains(q);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066F6)),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
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
                    Icons.wifi_off_rounded,
                    size: 44,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
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
                  onPressed: _loadJobs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
                        if (widget.unreadNotifCount > 0)
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    widget.onNavigateToSearch(
                      query: '',
                      empType: _activeEmpType,
                      workplaceType: _activeWorkplaceType,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: Color(0xFF475569),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'search',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCategoryItem('Semua Pekerjaan', Icons.laptop_chromebook_rounded, label: 'Semua\nPekerjaan'),
                    _buildCategoryItem('Remote', Icons.laptop_chromebook_rounded),
                    _buildCategoryItem('Office', Icons.apartment_rounded),
                    _buildCategoryItem('Magang', Icons.school_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CareerPortalBanner(
                onSeeMore: () => widget.onNavigateToSearch(),
              ),
              const SizedBox(height: 20),
              // Section Header: Pekerjaan Paling Populer + Lihat Lainnya
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pekerjaan Paling Populer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.onNavigateToSearch(
                        empType: _activeEmpType,
                        workplaceType: _activeWorkplaceType,
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Lihat Lainnya',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 2-Column Grid of Jobs
              if (categoryFilteredJobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Center(
                    child: Text(
                      'Tidak ada lowongan untuk kategori ini.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 196,
                  ),
                  itemCount: categoryFilteredJobs.take(6).length,
                  itemBuilder: (context, index) {
                    final job = categoryFilteredJobs.take(6).elementAt(index);
                    return _buildGridJobCard(job);
                  },
                ),
              // Ruang bawah agar baris grid terakhir tidak tertutup FAB asesor.
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, {String? label}) {
    final isSelected = _selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = title);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 72,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF0066F6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label ?? title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  height: 1.15,
                ),
              ),
            ],
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
                // Top row: Logo perusahaan + Bookmark
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
                // Company Name
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
                // Job Title
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
                // Tags Row (+Full Time, +Remote)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildCardChip('+${job.employmentType}'),
                    _buildCardChip('+${job.workplaceType}'),
                  ],
                ),
                const Spacer(),
                // Location row
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
                // Salary row
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

