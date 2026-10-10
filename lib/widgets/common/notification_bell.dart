import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../services/common/app_notification_storage.dart';
import '../../services/common/notification_service.dart';
import '../../services/auth/auth_repository.dart';
import 'notification_panel.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  int _notificationCount = 0;
  StreamSubscription<void>? _pushSubscription;
  StreamSubscription<void>? _storageSubscription;

  @override
  void initState() {
    super.initState();
    // Skip notification setup for guests to avoid 401 Unauthorized errors
    if (AuthRepository.currentUserInstance == null) return;

    WidgetsBinding.instance.addObserver(this);

    // Defer notification loading by 1s to avoid initial API burst
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadNotificationCount();
      }
    });

    // Notifikasi push baru (foreground) + perubahan sesi (logout/token mati).
    _pushSubscription = NotificationService.onNotificationReceived.stream.listen(
      (_) {
        _loadNotificationCount();
      },
    );

    // Perubahan lokal (tandai dibaca / hapus / bersihkan) — badge tetap
    // tersinkron walau panel notifikasi sedang terbuka.
    _storageSubscription = AppNotificationStorage.onChanged.stream.listen((_) {
      _loadNotificationCount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pushSubscription?.cancel();
    _storageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Notifikasi yang masuk saat aplikasi di background disimpan oleh isolate
    // background; segarkan badge begitu aplikasi aktif kembali.
    if (state == AppLifecycleState.resumed) {
      _loadNotificationCount();
    }
  }

  Future<void> _loadNotificationCount() async {
    if (!mounted) return;

    final session = await AppNotificationStorage.instance
        .resolveSessionIdentity();
    if (!mounted) return;
    if (session == null) {
      // Sesi hilang (logout / token mati) -> badge langsung bersih.
      setState(() => _notificationCount = 0);
      return;
    }

    final unreadLocalCount = await AppNotificationStorage.instance
        .getUnreadCount();
    // Count backend hanya berisi pengingat ACC jadwal (admin-only), jadi role
    // lain tidak boleh memanggil endpoint ini sama sekali.
    final backendCount = session.role == 'admin'
        ? await ApiService.getNotificationCount()
        : 0;

    if (!mounted) return;

    // Akun berubah selama await -> hasil akun lama tidak boleh bocor.
    final after = await AppNotificationStorage.instance
        .resolveSessionIdentity();
    if (after == null ||
        after.userId != session.userId ||
        after.role != session.role) {
      return;
    }

    setState(() {
      _notificationCount = backendCount + unreadLocalCount;
    });
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    ).then((_) {
      // Refresh count after closing panel
      _loadNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hide UI icon and disable modal panel entirely for guest users
    if (AuthRepository.currentUserInstance == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _showNotificationPanel,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _notificationCount > 99 ? '99+' : '$_notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
