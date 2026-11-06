import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/jadwal_models.dart';
import '../../services/auth/auth_repository.dart';

class AsesiScheduleInfoCard extends StatelessWidget {
  final String jadwalTitle;

  const AsesiScheduleInfoCard({super.key, required this.jadwalTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F1FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB3D7F4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Sertifikasi',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF2C6C9C),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            jadwalTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D70),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AsesiFilterTabs extends StatelessWidget {
  final AsesiListResponse response;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const AsesiFilterTabs({
    super.key,
    required this.response,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAsesor = AuthRepository.currentUserInstance?.role == 'asesor';
    final totalCount = response.data.length;
    final tidakHadirCount = response.data.where((a) => a.isAbsent).length;
    final myAsesiCount = response.data.where((a) => a.isMyAsesi && !a.isAbsent).length;
    final presentCount = totalCount - tidakHadirCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (isAsesor)
              _FilterTabItem(
                label: 'Asesi Saya ($myAsesiCount)',
                isSelected: selectedTab == 0,
                onTap: () {
                  if (selectedTab != 0) {
                    onTabSelected(0);
                  }
                },
              ),
            _FilterTabItem(
              label: 'Semua Peserta ($presentCount)',
              isSelected: selectedTab == 1,
              onTap: () {
                if (selectedTab != 1) {
                  onTabSelected(1);
                }
              },
            ),
            _FilterTabItem(
              label: 'Tidak Hadir ($tidakHadirCount)',
              isSelected: selectedTab == 2,
              activeTextColor: const Color(0xFFDC2626),
              onTap: () {
                if (selectedTab != 2) {
                  onTabSelected(2);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeTextColor;

  const _FilterTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (activeTextColor ?? const Color(0xFF2C6C9C))
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AsesiSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const AsesiSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari nama atau NIK peserta...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon:
              const Icon(LucideIcons.search, size: 18, color: Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child:
                      const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class AsesiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AsesiErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.circle_exclamation_point,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class AsesiEmptyWidget extends StatelessWidget {
  const AsesiEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F1FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.users,
              color: Color(0xFF2C6C9C),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada asesi ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pastikan kata kunci pencarian Anda benar.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AsesiSaveFooter extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const AsesiSaveFooter({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline_rounded,
                  size: 20, color: Colors.white),
          label: Text(
            isSaving
                ? 'Menyimpan Rekomendasi...'
                : 'Simpan Rekomendasi Kolektif',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
