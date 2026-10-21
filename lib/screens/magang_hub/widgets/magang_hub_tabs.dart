import 'package:material_ui/material_ui.dart';

import '../../../models/magang_hub_models.dart';
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
  final VoidCallback onCreate;

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
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: hubBlue,
      onRefresh: onRefresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: MagangHubSearchField(
              controller: searchController,
              hint: 'Cari posisi atau perusahaan',
              onSubmitted: onSearchSubmitted,
              onClear: onSearchCleared,
            ),
          ),
          MagangHubSegmentedControl(
            options: workplaceOptions,
            selected: selectedWorkplace,
            onSelected: onWorkplaceSelected,
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
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (context, idx) {
        final job = jobs[idx];
        return MagangJobCard(job: job, onTap: () => onOpenJob(job));
      },
    );
  }
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
