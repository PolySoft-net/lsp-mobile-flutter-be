import 'package:material_ui/material_ui.dart';

import '../../models/magang_hub_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import 'magang_detail_screen.dart';
import 'magang_form_screen.dart';
import 'magang_perusahaan_detail_screen.dart';
import 'widgets/magang_card.dart';
import 'widgets/magang_perusahaan_card.dart';
/// Screen utama Magang Hub — Portal Magang Perusahaan Mitra yang di-input Asesor.
class MagangHubScreen extends StatefulWidget {
  const MagangHubScreen({super.key});

  @override
  State<MagangHubScreen> createState() => _MagangHubScreenState();
}

class _MagangHubScreenState extends State<MagangHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get _isAsesor => AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;

  // Stats
  MagangStats _stats = const MagangStats();

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
  final TextEditingController _searchCompanyController = TextEditingController();

  // Tab 3: Magang Saya (Khusus Asesor)
  bool _isLoadingMyJobs = true;
  String? _errorMyJobs;
  List<CareerJobItem> _myJobs = [];
  String _selectedMyStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isAsesor ? 3 : 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchJobController.dispose();
    _searchCompanyController.dispose();
    super.dispose();
  }
  Future<void> _loadAllData() async {
    _loadStats();
    _loadJobs();
    _loadCompanies();
    _loadDynamicFilters();
    if (_isAsesor) _loadMyJobs();
  }

  Future<void> _loadDynamicFilters() async {
    try {
      final opts = await CareerExpoService.getFilterOptions();
      if (!mounted) return;
      if (opts.workplaceTypes.isNotEmpty) {
        final list = List<String>.from(opts.workplaceTypes);
        if (!list.contains('Semua')) {
          list.insert(0, 'Semua');
        }
        setState(() {
          _workplaceFilterOptions = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final s = await MagangHubService.getStats();
      if (!mounted) return;
      setState(() => _stats = s);
    } catch (_) {}
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
      );
      if (!mounted) return;
      setState(() {
        _companies = items;
        _isLoadingCompanies = false;
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
    if (updated == true) {
      _loadAllData();
    }
  }

  Future<void> _deleteJob(CareerJobItem job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Lowongan Magang', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus lowongan "${job.title}" di ${job.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Magang Hub',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          if (_isAsesor)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ElevatedButton.icon(
                onPressed: () => _openForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Pasang',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              tabs: [
                const Tab(text: 'Lowongan'),
                const Tab(text: 'Perusahaan'),
                if (_isAsesor) const Tab(text: 'Magang Saya'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLowonganTab(),
          _buildPerusahaanTab(),
          if (_isAsesor) _buildMagangSayaTab(),
        ],
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Lowongan',
              '${_stats.totalLowonganMagang}',
              Icons.school_outlined,
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFDDD6FE)),
          Expanded(
            child: _buildStatItem(
              'Mitra Industri',
              '${_stats.totalPerusahaan}',
              Icons.business_rounded,
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFDDD6FE)),
          Expanded(
            child: _buildStatItem(
              'Kota/Wilayah',
              '${_stats.totalKota}',
              Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7C3AED), size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF5B21B6),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B21A8),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  Widget _buildLowonganTab() {
    return RefreshIndicator(
      color: const Color(0xFF7C3AED),
      onRefresh: _loadAllData,
      child: Column(
        children: [
          // Compact Stats Banner
          _buildStatsBanner(),
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchJobController,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Cari posisi magang atau perusahaan...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  suffixIcon: _searchJobQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchJobController.clear();
                            setState(() => _searchJobQuery = '');
                            _loadJobs();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (v) {
                  setState(() => _searchJobQuery = v.trim());
                  _loadJobs();
                },
              ),
            ),
          ),
          // Workplace Type Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _workplaceFilterOptions.map((type) {
                final isSelected = _selectedWorkplace == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedWorkplace = type);
                      _loadJobs();
                    },
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF7C3AED),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Job List
          Expanded(
            child: _isLoadingJobs
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : _errorJobs != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorJobs!, style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadJobs,
                              child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF7C3AED))),
                            ),
                          ],
                        ),
                      )
                    : _jobs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.school_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum ada lowongan magang yang sesuai kriteria.',
                                    style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_isAsesor) ...[
                                    const SizedBox(height: 14),
                                    ElevatedButton.icon(
                                      onPressed: () => _openForm(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7C3AED),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.add_rounded, size: 18),
                                      label: const Text('Pasang Info Magang Baru'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                            itemCount: _jobs.length,
                            itemBuilder: (context, idx) {
                              final job = _jobs[idx];
                              return MagangJobCard(
                                job: job,
                                onTap: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MagangDetailScreen(job: job),
                                    ),
                                  );
                                  if (updated == true) {
                                    _loadAllData();
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerusahaanTab() {
    return RefreshIndicator(
      color: const Color(0xFF7C3AED),
      onRefresh: _loadCompanies,
      child: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchCompanyController,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Cari perusahaan atau kategori industri...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  suffixIcon: _searchCompanyQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchCompanyController.clear();
                            setState(() => _searchCompanyQuery = '');
                            _loadCompanies();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (v) {
                  setState(() => _searchCompanyQuery = v.trim());
                  _loadCompanies();
                },
              ),
            ),
          ),
          // Companies List
          Expanded(
            child: _isLoadingCompanies
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : _errorCompanies != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorCompanies!, style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadCompanies,
                              child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF7C3AED))),
                            ),
                          ],
                        ),
                      )
                    : _companies.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.business_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                  SizedBox(height: 12),
                                  Text(
                                    'Belum ada data perusahaan mitra magang.',
                                    style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                            itemCount: _companies.length,
                            itemBuilder: (context, idx) {
                              final item = _companies[idx];
                              return MagangPerusahaanCard(
                                item: item,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MagangPerusahaanDetailScreen(perusahaan: item),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagangSayaTab() {
    return RefreshIndicator(
      color: const Color(0xFF7C3AED),
      onRefresh: _loadMyJobs,
      child: Column(
        children: [
          // Filter Chips: Semua, Publish, Draft
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['Semua', 'Publish', 'Draft'].map((status) {
                final isSelected = _selectedMyStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedMyStatus = status);
                      _loadMyJobs();
                    },
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF7C3AED),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // My Jobs List
          Expanded(
            child: _isLoadingMyJobs
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : _errorMyJobs != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMyJobs!, style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadMyJobs,
                              child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF7C3AED))),
                            ),
                          ],
                        ),
                      )
                    : _myJobs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.post_add_rounded, size: 48, color: Color(0xFFCBD5E1)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Anda belum memasang info magang.',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Pasang info program magang di perusahaan mitra Anda untuk diakses oleh asesi dan peserta sertifikasi.',
                                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _openForm(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7C3AED),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: const Text('Pasang Info Magang Baru'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                            itemCount: _myJobs.length,
                            itemBuilder: (context, idx) {
                              final job = _myJobs[idx];
                              return MagangJobCard(
                                job: job,
                                showManageActions: true,
                                onTap: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MagangDetailScreen(job: job),
                                    ),
                                  );
                                  if (updated == true) {
                                    _loadAllData();
                                  }
                                },
                                onEdit: () => _openForm(job: job),
                                onDelete: () => _deleteJob(job),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
