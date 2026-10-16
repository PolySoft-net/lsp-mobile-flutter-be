import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import 'career_expo_detail_screen.dart';

/// Tab Notifikasi Career Expo terhubung ke API backend
class CareerExpoNotifikasiTab extends StatefulWidget {
  const CareerExpoNotifikasiTab({super.key});

  @override
  State<CareerExpoNotifikasiTab> createState() => _CareerExpoNotifikasiTabState();
}

class _CareerExpoNotifikasiTabState extends State<CareerExpoNotifikasiTab> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Lamaran', 'Pembaruan', 'Sistem'];

  bool _isLoading = true;
  String? _error;
  List<CareerNotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await CareerExpoService.getNotifikasi(
        kategori: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException && e.response != null
            ? 'Gagal memuat notifikasi (kode ${e.response?.statusCode}).'
            : 'Tidak bisa terhubung ke server. Periksa koneksi internetmu.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onSelectCategory(String cat) async {
    if (_selectedCategory == cat) return;
    setState(() => _selectedCategory = cat);
    await _loadNotifications();
  }

  Future<void> _openNotification(CareerNotificationItem item) async {
    // Mark as read in background
    if (!item.isRead) {
      CareerExpoService.markNotifikasiRead(item.id).catchError((_) {});
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == item.id);
        if (idx != -1) {
          final old = _notifications[idx];
          _notifications[idx] = CareerNotificationItem(
            id: old.id,
            title: old.title,
            message: old.message,
            time: old.time,
            category: old.category,
            type: old.type,
            lowonganId: old.lowonganId,
            lamaranId: old.lamaranId,
            isRead: true,
            createdAt: old.createdAt,
          );
        }
      });
    }

    // If linked to lowongan, navigate to detail
    if (item.lowonganId != null && item.lowonganId!.isNotEmpty) {
      try {
        final job = await CareerExpoService.getDetail(item.lowonganId!);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CareerExpoDetailScreen(job: job),
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _markAllRead() async {
    try {
      await CareerExpoService.markAllNotifikasiRead();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications.map((n) {
          return CareerNotificationItem(
            id: n.id,
            title: n.title,
            message: n.message,
            time: n.time,
            category: n.category,
            type: n.type,
            lowonganId: n.lowonganId,
            lamaranId: n.lamaranId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi telah ditandai dibaca'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              tooltip: 'Tandai semua dibaca',
              icon: const Icon(
                Icons.done_all_rounded,
                color: Color(0xFF0066F6),
                size: 22,
              ),
              onPressed: _markAllRead,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _onSelectCategory(cat),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0066F6)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            // Notifications List
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0066F6),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        color: const Color(0xFF0066F6),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          children: const [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 54,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Belum Ada Notifikasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Notifikasi mengenai lamaran dan pembaruan lowongan pekerjaan akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: const Color(0xFF0066F6),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return InkWell(
            onTap: () => _openNotification(item),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.isRead
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFBFDBFE),
                  width: item.isRead ? 1 : 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: item.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Text(
                              item.time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
