import 'package:material_ui/material_ui.dart';

import '../../../models/magang_hub_models.dart';
import '../../../utils/number_format_helper.dart';
import 'magang_card.dart';
import 'magang_hub_common.dart';
import 'magang_perusahaan_card.dart';

class MagangHubJobsTab extends StatelessWidget {
  final List<CareerJobItem> jobs;
  final bool isLoading;
  final String? error;
  final TextEditingController searchController;
  final String searchQuery;
  final List<String> workplaceOptions;
  final String selectedWorkplace;
  final bool canCreate;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final ValueChanged<String> onWorkplaceSelected;
  final ValueChanged<CareerJobItem> onOpenJob;
  final ValueChanged<CareerJobItem>? onToggleBookmark;
  final VoidCallback onCreate;
  final VoidCallback? onSeeMore;

  const MagangHubJobsTab({
    super.key,
    required this.jobs,
    required this.isLoading,
    required this.error,
    required this.searchController,
    required this.searchQuery,
    required this.workplaceOptions,
    required this.selectedWorkplace,
    required this.canCreate,
    required this.onRefresh,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onWorkplaceSelected,
    required this.onOpenJob,
    this.onToggleBookmark,
    required this.onCreate,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: hubBlue,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF475569),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onSubmitted: onSearchSubmitted,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'search',
                          hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  color: const Color(0xFF475569),
                                  onPressed: onSearchCleared,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3 Category Cards Row (Semua Pekerjaan, Remote, Office)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryCard('Semua Pekerjaan', Icons.laptop_chromebook_rounded, label: 'Semua\nPekerjaan'),
                  _buildCategoryCard('Remote', Icons.laptop_chromebook_rounded),
                  _buildCategoryCard('Office', Icons.apartment_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Promo Banner: Magang Hub
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Magang Hub',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Temukan kesempatan magang terbaik untuk membangun karirmu.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: onSeeMore,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Lebih',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 9,
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const CustomPaint(
                            painter: _DiagonalPlaceholderPainter(color: Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section Header: Pekerjaan Paling Populer / Lihat Lainnya
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    onTap: onSeeMore,
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

            // 2-Column Grid
            _buildGridBody(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, {String? label}) {
    final wp = title == 'Office' ? 'On Site' : (title == 'Semua Pekerjaan' ? 'Semua' : title);
    final isSelected = selectedWorkplace.toLowerCase() == wp.toLowerCase() ||
        (title == 'Office' && (selectedWorkplace.toLowerCase() == 'office' || selectedWorkplace.toLowerCase() == 'on site'));
    return Expanded(
      child: GestureDetector(
        onTap: () => onWorkplaceSelected(wp),
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
              Icon(icon, color: const Color(0xFF0066F6), size: 24),
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

  Widget _buildGridBody(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: hubBlue)),
      );
    }
    if (error != null) {
      return MagangHubStateList(
        icon: Icons.cloud_off_rounded,
        title: 'Lowongan gagal dimuat',
        message: error,
        onRetry: () => onRefresh(),
      );
    }
    if (jobs.isEmpty) {
      return MagangHubStateList(
        icon: Icons.work_outline_rounded,
        title: 'Belum ada lowongan',
        message: searchQuery.isNotEmpty || selectedWorkplace != 'Semua'
            ? 'Tidak ada lowongan yang cocok dengan pencarian atau filter Anda.'
            : 'Belum ada info magang yang dipasang untuk saat ini.',
        action: canCreate
            ? MagangHubPrimaryAction(
                label: 'Pasang Info Magang',
                onTap: onCreate,
              )
            : null,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 196,
      ),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        final job = jobs[idx];
        return _buildGridCard(context, job);
      },
    );
  }

  Widget _buildGridCard(BuildContext context, CareerJobItem job) {
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
          onTap: () => onOpenJob(job),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const CustomPaint(
                        painter: _DiagonalPlaceholderPainter(
                          color: Color(0xFF475569),
                          strokeWidth: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onToggleBookmark?.call(job),
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
                    _buildChip('+${job.employmentType}'),
                    _buildChip('+${job.workplaceType}'),
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

  Widget _buildChip(String label) {
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

class _DiagonalPlaceholderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DiagonalPlaceholderPainter({
    this.color = const Color(0xFF475569),
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalPlaceholderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class MagangHubCompaniesTab extends StatelessWidget {
  final List<MagangPerusahaanItem> companies;
  final bool isLoading;
  final String? error;
  final TextEditingController searchController;
  final String searchQuery;
  final List<String> locationOptions;
  final String selectedLocation;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final ValueChanged<String> onLocationSelected;
  final ValueChanged<MagangPerusahaanItem> onOpenCompany;

  const MagangHubCompaniesTab({
    super.key,
    required this.companies,
    required this.isLoading,
    required this.error,
    required this.searchController,
    required this.searchQuery,
    required this.locationOptions,
    required this.selectedLocation,
    required this.onRefresh,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onLocationSelected,
    required this.onOpenCompany,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: hubBlue,
      onRefresh: onRefresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: MagangHubSearchField(
              controller: searchController,
              hint: 'Cari perusahaan atau kategori industri',
              onSubmitted: onSearchSubmitted,
              onClear: onSearchCleared,
            ),
          ),
          MagangHubSegmentedControl(
            options: locationOptions,
            selected: selectedLocation,
            onSelected: onLocationSelected,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: hubBlue));
    }
    if (error != null) {
      return MagangHubStateList(
        icon: Icons.cloud_off_rounded,
        title: 'Perusahaan gagal dimuat',
        message: error,
        onRetry: () => onRefresh(),
      );
    }
    if (companies.isEmpty) {
      return MagangHubStateList(
        icon: Icons.business_outlined,
        title: 'Belum ada perusahaan mitra',
        message: searchQuery.isNotEmpty || selectedLocation != 'Semua'
            ? 'Tidak ada perusahaan yang cocok dengan pencarian atau filter Anda.'
            : 'Belum ada profil perusahaan mitra magang untuk saat ini.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: companies.length,
      itemBuilder: (context, idx) {
        final item = companies[idx];
        return MagangPerusahaanCard(
          item: item,
          onTap: () => onOpenCompany(item),
        );
      },
    );
  }
}

class MagangHubMyJobsTab extends StatelessWidget {
  final List<CareerJobItem> jobs;
  final bool isLoading;
  final String? error;
  final String selectedStatus;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<CareerJobItem> onOpenJob;
  final ValueChanged<CareerJobItem> onEdit;
  final ValueChanged<CareerJobItem> onDelete;
  final VoidCallback onCreate;

  const MagangHubMyJobsTab({
    super.key,
    required this.jobs,
    required this.isLoading,
    required this.error,
    required this.selectedStatus,
    required this.onRefresh,
    required this.onStatusSelected,
    required this.onOpenJob,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: hubBlue,
      onRefresh: onRefresh,
      child: Column(
        children: [
          MagangHubSegmentedControl(
            options: const ['Semua', 'Publish', 'Draft'],
            selected: selectedStatus,
            onSelected: onStatusSelected,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: hubBlue));
    }
    if (error != null) {
      return MagangHubStateList(
        icon: Icons.cloud_off_rounded,
        title: 'Lowongan gagal dimuat',
        message: error,
        onRetry: () => onRefresh(),
      );
    }
    if (jobs.isEmpty) {
      return MagangHubStateList(
        icon: Icons.post_add_rounded,
        title: 'Belum ada info magang',
        message: selectedStatus == 'Semua'
            ? 'Pasang info program magang di perusahaan mitra agar bisa dilihat asesi dan peserta sertifikasi.'
            : 'Tidak ada lowongan dengan status $selectedStatus.',
        action: MagangHubPrimaryAction(
          label: 'Pasang Info Magang',
          onTap: onCreate,
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        final job = jobs[idx];
        return MagangJobCard(
          job: job,
          showManageActions: true,
          onTap: () => onOpenJob(job),
          onEdit: () => onEdit(job),
          onDelete: () => onDelete(job),
        );
      },
    );
  }
}
