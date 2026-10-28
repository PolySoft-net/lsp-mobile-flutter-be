import 'package:material_ui/material_ui.dart';

import '../../services/common/app_notification_storage.dart';
import '../../widgets/common/custom_app_bar.dart';

class InvestmentNotificationScreen extends StatefulWidget {
  const InvestmentNotificationScreen({super.key});

  @override
  State<InvestmentNotificationScreen> createState() =>
      _InvestmentNotificationScreenState();
}

class _InvestmentNotificationScreenState
    extends State<InvestmentNotificationScreen> {
  int _selectedFilter = 0; // 0: Semua, 1: Investasi, 2: Sistem
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifs = await AppNotificationStorage.instance.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 1) {
      return _notifications
          .where((n) =>
              n.type.toLowerCase().contains('invest') ||
              n.title.toLowerCase().contains('invest') ||
              n.title.toLowerCase().contains('pembayaran'))
          .toList();
    }
    if (_selectedFilter == 2) {
      return _notifications
          .where((n) =>
              !n.type.toLowerCase().contains('invest') &&
              !n.title.toLowerCase().contains('invest'))
          .toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Notifikasi',
              onBack: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: const Color(0xFF0066F6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Pills: Semua / Investasi / Sistem (Image 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'Semua'),
                    const SizedBox(width: 8),
                    _buildFilterTab(1, 'Investasi'),
                    const SizedBox(width: 8),
                    _buildFilterTab(2, 'Sistem'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Notification Items List (Image 2)
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF0066F6)),
                  ),
                )
              else if (_filteredNotifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 54,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 14),
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
                          'Semua pemberitahuan mengenai perkembangan investasi, pembayaran, dan informasi sistem akan muncul di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = _filteredNotifications[index];
                    return _buildNotificationCard(notif);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final isSelected = _selectedFilter == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final IconData icon = _resolveIcon(notif.type);
    final Color color = _resolveColor(notif.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(notif.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Chevron Right
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes > 0 ? diff.inMinutes : 1} menit lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    }
    return '${diff.inDays} hari lalu';
  }

  IconData _resolveIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('pay') || lower.contains('bayar')) {
      return Icons.check_circle_rounded;
    }
    if (lower.contains('update') || lower.contains('tumbuh')) {
      return Icons.trending_up_rounded;
    }
    if (lower.contains('report') || lower.contains('lapor')) {
      return Icons.assignment_outlined;
    }
    return Icons.campaign_rounded;
  }

  Color _resolveColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('pay') || lower.contains('bayar')) {
      return const Color(0xFF22C55E);
    }
    if (lower.contains('update') || lower.contains('tumbuh')) {
      return const Color(0xFF06B6D4);
    }
    if (lower.contains('report') || lower.contains('lapor')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF8B5CF6);
  }
}
