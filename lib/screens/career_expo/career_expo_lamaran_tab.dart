import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import 'career_expo_detail_screen.dart';

class _ApplicationDisplayItem {
  final String id;
  final String title;
  final String company;
  final String date;
  final String status;
  final Color logoBgColor;
  final String logoText;
  final CareerJobItem job;

  const _ApplicationDisplayItem({
    required this.id,
    required this.title,
    required this.company,
    required this.date,
    required this.status,
    required this.logoBgColor,
    required this.logoText,
    required this.job,
  });
}

/// Tab Lamaran Saya di Career Expo sesuai Screen 2
class CareerExpoLamaranTab extends StatefulWidget {
  final VoidCallback? onBack;

  const CareerExpoLamaranTab({
    super.key,
    this.onBack,
  });

  @override
  State<CareerExpoLamaranTab> createState() => _CareerExpoLamaranTabState();
}

class _CareerExpoLamaranTabState extends State<CareerExpoLamaranTab> {
  String _selectedFilter = 'Semua (5)';

  final List<String> _filterCategories = [
    'Semua (5)',
    'Diproses (2)',
    'Diterima (1)',
    'Ditolak (2)',
  ];

  late final List<_ApplicationDisplayItem> _allApplications;

  @override
  void initState() {
    super.initState();
    final defaultJobs = CareerExpoMockData.getJobs();
    _allApplications = [
      _ApplicationDisplayItem(
        id: 'app-1',
        title: 'UI/UX Designer',
        company: 'PT. Kreatif Digital',
        date: 'Dilamar 12 Jun 2025',
        status: 'Diproses',
        logoBgColor: const Color(0xFF0284C7),
        logoText: 'KD',
        job: defaultJobs[0],
      ),
      _ApplicationDisplayItem(
        id: 'app-2',
        title: 'Front End Developer',
        company: 'CV. Solusi Tech',
        date: 'Dilamar 10 Jun 2025',
        status: 'Diproses',
        logoBgColor: const Color(0xFF2563EB),
        logoText: 'ST',
        job: defaultJobs[3],
      ),
      _ApplicationDisplayItem(
        id: 'app-3',
        title: 'Web Developer',
        company: 'PT. Inovasi Solusi Digital',
        date: 'Dilamar 7 Jun 2025',
        status: 'Diterima',
        logoBgColor: const Color(0xFF0369A1),
        logoText: 'IS',
        job: defaultJobs[4],
      ),
      _ApplicationDisplayItem(
        id: 'app-4',
        title: 'Graphic Designer',
        company: 'Ruang Digital Studio',
        date: 'Dilamar 3 Jun 2025',
        status: 'Ditolak',
        logoBgColor: const Color(0xFF0D9488),
        logoText: 'RD',
        job: defaultJobs[1],
      ),
      _ApplicationDisplayItem(
        id: 'app-5',
        title: 'Fullstack Developer',
        company: 'PT. Tech Nusantara',
        date: 'Dilamar 1 Jun 2025',
        status: 'Ditolak',
        logoBgColor: const Color(0xFF1E293B),
        logoText: 'TN',
        job: defaultJobs[2],
      ),
    ];
  }

  List<_ApplicationDisplayItem> _getFilteredApplications() {
    if (_selectedFilter.startsWith('Semua')) {
      return _allApplications;
    } else if (_selectedFilter.startsWith('Diproses')) {
      return _allApplications.where((a) => a.status == 'Diproses').toList();
    } else if (_selectedFilter.startsWith('Diterima')) {
      return _allApplications.where((a) => a.status == 'Diterima').toList();
    } else if (_selectedFilter.startsWith('Ditolak')) {
      return _allApplications.where((a) => a.status == 'Ditolak').toList();
    }
    return _allApplications;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredApplications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lamaran Saya',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                onPressed: widget.onBack,
              )
            : null,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filterCategories.map((cat) {
                final isSelected = _selectedFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = cat),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Applications List
          Expanded(
            child: filtered.isEmpty
                ? Center(
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
                            Icons.work_history_outlined,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tidak ada lamaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Belum ada lamaran dengan status ini.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CareerExpoDetailScreen(job: item.job),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  // Company logo emblem
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: item.logoBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.logoText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Texts
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.company,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.date,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status Badge
                                  _buildStatusBadge(item.status),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Diproses') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    } else if (status == 'Diterima') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else {
      // Ditolak
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
