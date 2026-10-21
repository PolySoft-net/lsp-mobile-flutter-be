import 'package:material_ui/material_ui.dart';

import '../../models/magang_hub_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../profile/data_diri_screen.dart';
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

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DataDiriScreen()),
    ).then((_) => _loadAllData());
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
        onCreate: () => _openForm(),
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(title: 'Magang Hub'),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: tabs),
            ),
          ],
        ),
      ),
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
    final items = <_NavItem>[
      const _NavItem(
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded,
        label: 'Lowongan',
      ),
      const _NavItem(
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        label: 'Perusahaan',
      ),
      if (_isAsesor)
        const _NavItem(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment_rounded,
          label: 'Magang Saya',
        ),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: hubLine)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _navButton(
                    items[i],
                    selected: _currentIndex == i,
                    onTap: () => setState(() => _currentIndex = i),
                  ),
                ),
              Expanded(
                child: _navButton(
                  const _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                  ),
                  selected: false,
                  onTap: _openProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(_NavItem item, {required bool selected, required VoidCallback onTap}) {
    final color = selected ? const Color(0xFF0F172A) : hubMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? item.activeIcon : item.icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
