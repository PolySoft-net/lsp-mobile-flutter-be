import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/magang_hub_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../career_expo/career_expo_favorit_screen.dart';
import '../career_expo/career_expo_lamaran_tab.dart';
import '../career_expo/career_expo_profile_tab.dart';
import 'magang_detail_screen.dart';
import 'magang_form_screen.dart';
import 'magang_perusahaan_detail_screen.dart';
import 'widgets/magang_hub_common.dart';
import 'widgets/magang_hub_tabs.dart';

/// Screen utama Magang Hub — Portal Magang Perusahaan Mitra yang di-input Asesor.
class MagangHubScreen extends StatefulWidget {
  const MagangHubScreen({super.key});

  @override
  State<MagangHubScreen> createState() => _MagangHubScreenState();
}

class _MagangHubScreenState extends State<MagangHubScreen> {
  int _currentIndex = 0;
  bool get _isAsesor =>
      AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;

  // Tab 1: Lowongan Magang
  bool _isLoadingJobs = true;
  String? _errorJobs;
  List<CareerJobItem> _jobs = [];
  String _searchJobQuery = '';
  String _selectedWorkplace = 'Semua';
  List<String> _workplaceFilterOptions = ['Semua', 'On Site', 'Remote', 'Hybrid'];
  final TextEditingController _searchJobController = TextEditingController();

  // Tab 2: Perusahaan Mitra
  bool _isLoadingCompanies = true;
  String? _errorCompanies;
  List<MagangPerusahaanItem> _companies = [];
  String _searchCompanyQuery = '';
  String _selectedCompanyLocation = 'Semua';
  List<String> _companyLocationOptions = ['Semua'];
  final TextEditingController _searchCompanyController = TextEditingController();

  // Tab 3: Magang Saya (Khusus Asesor)
  bool _isLoadingMyJobs = true;
  String? _errorMyJobs;
  List<CareerJobItem> _myJobs = [];
  String _selectedMyStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _searchJobController.dispose();
    _searchCompanyController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadJobs(),
      _loadCompanies(),
      _loadDynamicFilters(),
      if (_isAsesor) _loadMyJobs(),
    ]);
  }

  Future<void> _loadDynamicFilters() async {
    try {
      final opts = await CareerExpoService.getFilterOptions();
      if (!mounted) return;
      setState(() {
        _workplaceFilterOptions = _orderedWorkplaceTypes(opts.workplaceTypes);
      });
    } catch (_) {}
  }

  /// Urutan pil tetap mengikuti preferensi tampilan, opsi lain dari backend tetap ditambahkan.
  List<String> _orderedWorkplaceTypes(List<String> fromBackend) {
    const preferred = ['Semua', 'Hybrid', 'On Site', 'Remote'];
    final result = <String>[];
    for (final p in preferred) {
      if (fromBackend.contains(p)) result.add(p);
    }
    for (final item in fromBackend) {
      if (!result.contains(item)) result.add(item);
    }
    if (result.isEmpty) return const ['Semua', 'Hybrid', 'On Site', 'Remote'];
    return result;
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoadingJobs = true;
      _errorJobs = null;
    });
    try {
      final items = await MagangHubService.getLowongan(
        search: _searchJobQuery,
        workplaceType: _selectedWorkplace,
      );
      if (!mounted) return;
      setState(() {
        _jobs = items;
        _isLoadingJobs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorJobs = 'Gagal memuat daftar lowongan magang.';
        _isLoadingJobs = false;
      });
    }
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
      _errorCompanies = null;
    });
    try {
      final items = await MagangHubService.getPerusahaan(
        search: _searchCompanyQuery,
        location: _selectedCompanyLocation,
      );
      if (!mounted) return;
      setState(() {
        _companies = items;
        _isLoadingCompanies = false;
        // Isi opsi lokasi sekali dari muatan penuh (belum terfilter), agar tetap stabil.
        if (_companyLocationOptions.length == 1 && _selectedCompanyLocation == 'Semua') {
          final options = <String>['Semua'];
          for (final c in items) {
            final loc = c.lokasi.trim();
            if (loc.isNotEmpty && !options.contains(loc)) options.add(loc);
          }
          _companyLocationOptions = options;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCompanies = 'Gagal memuat profil perusahaan mitra.';
        _isLoadingCompanies = false;
      });
    }
  }

  Future<void> _loadMyJobs() async {
    setState(() {
      _isLoadingMyJobs = true;
      _errorMyJobs = null;
    });
    try {
      final items = await MagangHubService.getMyLowongan(
        status: _selectedMyStatus,
      );
      if (!mounted) return;
      setState(() {
        _myJobs = items;
        _isLoadingMyJobs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMyJobs = 'Gagal memuat lowongan magang saya.';
        _isLoadingMyJobs = false;
      });
    }
  }

  void _openForm({CareerJobItem? job}) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MagangFormScreen(initialJob: job),
      ),
    );
    if (!mounted) return;
    if (updated == true) {
      _loadAllData();
    }
  }

  Future<void> _openJobDetail(CareerJobItem job) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MagangDetailScreen(job: job),
      ),
    );
    if (!mounted) return;
    if (updated == true) {
      _loadAllData();
    }
  }

  void _openCompanyDetail(MagangPerusahaanItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MagangPerusahaanDetailScreen(perusahaan: item),
      ),
    );
  }

  Future<void> _deleteJob(CareerJobItem job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Hapus Lowongan Magang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus lowongan "${job.title}" di ${job.companyName}?',
          style: const TextStyle(fontSize: 14, color: hubMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: hubMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await MagangHubService.deleteMagang(job.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lowongan magang berhasil dihapus.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadAllData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus lowongan magang.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleJobBookmark(CareerJobItem job) async {
    final target = !job.isBookmarked;
    setState(() {
      final idx = _jobs.indexWhere((j) => j.id == job.id);
      if (idx != -1) {
        _jobs[idx] = _jobs[idx].copyWith(isBookmarked: target);
      }
    });
    try {
      await CareerExpoService.setTersimpan(job.id, target);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            target
                ? 'Info magang disimpan ke favorit'
                : 'Info magang dihapus dari favorit',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _jobs.indexWhere((j) => j.id == job.id);
        if (idx != -1) {
          _jobs[idx] = _jobs[idx].copyWith(isBookmarked: !target);
        }
      });
      final unauthorized = e is DioException && e.response?.statusCode == 401;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unauthorized
                ? 'Silakan login terlebih dahulu untuk menyimpan info magang.'
                : 'Gagal memperbarui status tersimpan.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      MagangHubJobsTab(
        jobs: _jobs,
        isLoading: _isLoadingJobs,
        error: _errorJobs,
        searchController: _searchJobController,
        searchQuery: _searchJobQuery,
        workplaceOptions: _workplaceFilterOptions,
        selectedWorkplace: _selectedWorkplace,
        canCreate: _isAsesor,
        onRefresh: _loadAllData,
        onSearchSubmitted: (value) {
          setState(() => _searchJobQuery = value.trim());
          _loadJobs();
        },
        onSearchCleared: () {
          _searchJobController.clear();
          setState(() => _searchJobQuery = '');
          _loadJobs();
        },
        onWorkplaceSelected: (value) {
          setState(() => _selectedWorkplace = value);
          _loadJobs();
        },
        onOpenJob: _openJobDetail,
        onToggleBookmark: _toggleJobBookmark,
        onCreate: () => _openForm(),
        onSeeMore: () {
          _searchJobController.clear();
          setState(() {
            _searchJobQuery = '';
            _selectedWorkplace = 'Semua';
          });
          _loadJobs();
        },
      ),
      MagangHubCompaniesTab(
        companies: _companies,
        isLoading: _isLoadingCompanies,
        error: _errorCompanies,
        searchController: _searchCompanyController,
        searchQuery: _searchCompanyQuery,
        locationOptions: _companyLocationOptions,
        selectedLocation: _selectedCompanyLocation,
        onRefresh: _loadCompanies,
        onSearchSubmitted: (value) {
          setState(() => _searchCompanyQuery = value.trim());
          _loadCompanies();
        },
        onSearchCleared: () {
          _searchCompanyController.clear();
          setState(() => _searchCompanyQuery = '');
          _loadCompanies();
        },
        onLocationSelected: (value) {
          setState(() => _selectedCompanyLocation = value);
          _loadCompanies();
        },
        onOpenCompany: _openCompanyDetail,
      ),
      CareerExpoLamaranTab(
        onBack: () => setState(() => _currentIndex = 0),
      ),
      const CareerExpoFavoritScreen(
        showBackButton: false,
      ),
      CareerExpoProfileTab(
        onNavigateToLamaran: () => setState(() => _currentIndex = 2),
        onNavigateToFavorit: () => setState(() => _currentIndex = 3),
      ),
      if (_isAsesor)
        MagangHubMyJobsTab(
          jobs: _myJobs,
          isLoading: _isLoadingMyJobs,
          error: _errorMyJobs,
          selectedStatus: _selectedMyStatus,
          onRefresh: _loadMyJobs,
          onStatusSelected: (value) {
            setState(() => _selectedMyStatus = value);
            _loadMyJobs();
          },
          onOpenJob: _openJobDetail,
          onEdit: (job) => _openForm(job: job),
          onDelete: _deleteJob,
          onCreate: () => _openForm(),
        ),
    ];

    return Scaffold(
      backgroundColor: hubCanvas,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _isAsesor
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: hubAccent,
              foregroundColor: Colors.white,
              tooltip: 'Pasang Info Magang',
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.search_rounded, Icons.search_rounded, 'Search'),
              _buildNavItem(2, Icons.account_balance_rounded, Icons.account_balance_outlined, 'Lamaran'),
              _buildNavItem(3, Icons.bookmark_rounded, Icons.bookmark_outline_rounded, 'Save'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
              if (_isAsesor)
                _buildNavItem(5, Icons.assignment_rounded, Icons.assignment_outlined, 'Kelola'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

