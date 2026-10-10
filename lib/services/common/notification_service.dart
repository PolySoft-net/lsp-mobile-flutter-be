import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:januscaler_flutter_ringtone_player/flutter_ringtone_player.dart';
import '../api_service.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';
import '../../utils/api_routes.dart';
import '../../models/jadwal_models.dart';
import '../../screens/jadwal/jadwal_detail_screen.dart';
import '../../screens/dashboard/faq_screen.dart';
import '../../screens/asesi/asesi_ak03_form_screen.dart';
import '../../core/navigation/main_navigator.dart';
import '../../core/notifications/notification_guard.dart';
import '../../widgets/common/top_notification_banner.dart';
import 'app_notification_storage.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  static final StreamController<void> onNotificationReceived = StreamController<void>.broadcast();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Register hooks to clear FCM token on logout or token expiration
    AuthRepository.preLogoutHooks.add(() async {
      await deleteToken();
    });
    AuthRepository.registerTokenExpiredCallback(() {
      deleteToken();
    });

    // 1. Request Permission
    await requestPermission();

    // 2. Set up foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📨 Foreground FCM: ${message.notification?.title}');
      }
      _showForegroundNotification(message);
    });

    // 4. Listen to Notification Clicks (App in background but running)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📨 FCM Clicked (Background): ${message.data}');
      }
      _handleNotificationClick(message);
    });

    // 5. Check if app was opened from a terminated state via notification
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('📨 FCM Clicked (Terminated): ${initialMessage.data}');
      }
      // Delay click handling slightly to ensure navigation tree is fully built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _handleNotificationClick(initialMessage);
      });
    }
    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('User notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        debugPrint('✅ FCM Token deleted successfully from Firebase.');
      }
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  Future<void> registerCurrentToken() async {
    final user = AuthRepository.currentUserInstance;
    if (user == null) {
      if (kDebugMode) {
        debugPrint('ℹ️ FCM Token Registration skipped: User is null.');
      }
      return;
    }

    final fcmToken = await getToken();
    if (fcmToken == null) {
      debugPrint('⚠️ Cannot register FCM token: token is null.');
      return;
    }

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await ApiService.dio.post(
        ApiRoutes.notificationsRegister,
        data: {
          'device_token': fcmToken,
          'platform': platform,
        },
      );
      if (kDebugMode) {
        debugPrint('✅ FCM Token registered successfully: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error registering FCM Token to backend: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Fail closed: hanya notifikasi untuk user + role kanonikal sesi aktif.
    final notifIdentity = NotificationIdentity.fromPushData(message.data);
    final sessionIdentity =
        await AppNotificationStorage.instance.resolveSessionIdentity();
    if (!(notifIdentity?.matches(sessionIdentity) ?? false)) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Ignored foreground notification: identity mismatch '
          '(notif: ${notifIdentity?.userId}/${notifIdentity?.role}, '
          'current: ${sessionIdentity?.userId}/${sessionIdentity?.role})',
        );
      }
      return;
    }

    final title = message.notification?.title ?? _getTitleFromData(message.data);
    final body = message.notification?.body ?? _getBodyFromData(message.data);
    final type = NotificationGuard.normalizeType(message.data['type']);

    // Choose icon and color based on notification type
    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF4A9EDF);

    if (type == NotificationGuard.sptAsesor) {
      iconData = Icons.assignment_ind_rounded;
      iconColor = const Color(0xFF0284C7); // Sky Blue
    } else if (type == NotificationGuard.rekomendasiAsesor) {
      iconData = Icons.rate_review_rounded;
      iconColor = const Color(0xFFFF9800); // Orange
    } else if (type == NotificationGuard.linkPersetujuanAsesmen) {
      iconData = Icons.fact_check_rounded;
      iconColor = const Color(0xFF10B981); // Emerald
    } else if (type == NotificationGuard.linkUmpanBalik) {
      iconData = Icons.feedback_rounded;
      iconColor = const Color(0xFF8B5CF6); // Purple
    } else if (type == NotificationGuard.linkTugasPraktek) {
      iconData = Icons.draw_rounded;
      iconColor = const Color(0xFF06B6D4); // Cyan
    } else if (type == NotificationGuard.linkKegiatanTerstruktur) {
      iconData = Icons.view_timeline_rounded;
      iconColor = const Color(0xFFF59E0B); // Amber
    } else if (type == NotificationGuard.pendaftaranAsesor) {
      iconData = Icons.person_add_alt_1_rounded;
      iconColor = const Color(0xFF3B82F6); // Blue
    } else if (type == NotificationGuard.faq) {
      iconData = Icons.help_outline_rounded;
      iconColor = const Color(0xFF64748B); // Slate
    } else if (type == NotificationGuard.statusKompeten) {
      iconData = Icons.verified_user_rounded;
      iconColor = const Color(0xFF2E7D32); // Competent Green
    } else if (type == NotificationGuard.sertifikatTerbit) {
      iconData = Icons.workspace_premium_rounded;
      iconColor = const Color(0xFFE0A96D); // Certificate Gold
    }

    // 1. Save to local notifications storage so they can be viewed again
    await AppNotificationStorage.instance.saveNotification(
      title,
      body,
      type,
      message.data,
      targetUserId: sessionIdentity!.userId,
    );

    // Notify listeners that a new notification has been saved
    onNotificationReceived.add(null);

    // Play default notification sound in foreground
    try {
      FlutterRingtonePlayer().playNotification();
    } catch (e) {
      debugPrint('⚠️ Error playing notification sound: $e');
    }

    // Retrieve OverlayState using the global navigatorKey to display banner above any active screen/dialog
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // Verifikasi ulang: sesi bisa berganti selama proses async di atas, dan
    // banner akun lama tidak boleh muncul di akun yang baru login.
    final stillCurrent = await AppNotificationStorage.instance
        .resolveSessionIdentity();
    if (!(notifIdentity?.matches(stillCurrent) ?? false)) return;

    // 2. Show top notification banner (overlay)
    TopNotificationBanner.show(
      overlayState: overlayState,
      title: title,
      body: body,
      icon: iconData,
      color: iconColor,
      onTap: () {
        _handleNotificationClick(message);
      },
    );
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    // Fail closed: klik hanya diproses untuk user + role kanonikal sesi aktif.
    final notifIdentity = NotificationIdentity.fromPushData(message.data);
    final sessionIdentity =
        await AppNotificationStorage.instance.resolveSessionIdentity();
    if (!(notifIdentity?.matches(sessionIdentity) ?? false)) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Ignored notification click: identity mismatch '
          '(notif: ${notifIdentity?.userId}/${notifIdentity?.role}, '
          'current: ${sessionIdentity?.userId}/${sessionIdentity?.role})',
        );
      }
      return;
    }

    final type = NotificationGuard.normalizeType(message.data['type']);
    if (kDebugMode) {
      debugPrint('Handling notification click: type=$type, data=${message.data}');
    }

    final title = message.notification?.title ?? _getTitleFromData(message.data);
    final body = message.notification?.body ?? _getBodyFromData(message.data);

    // Simpan sebagai SUDAH DIBACA: notifikasi yang baru dibuka tidak boleh
    // muncul kembali sebagai belum dibaca (termasuk saat ini hanya klik dari
    // tray/background tanpa pernah tersimpan sebelumnya).
    await AppNotificationStorage.instance.saveNotification(
      title,
      body,
      type,
      message.data,
      targetUserId: sessionIdentity!.userId,
      markRead: true,
    );

    await navigateFromNotificationData(
      null,
      type: type,
      data: message.data,
    );
  }

  /// Centralized notification routing for both push notifications and in-app clicks.
  ///
  /// Hanya tipe yang punya tujuan nyata di aplikasi yang dinavigasikan:
  /// tipe tak dikenal, `tawaran_pekerjaan`, dan produk digital tetap bisa
  /// dibaca di daftar notifikasi tapi tidak pernah membuka Jadwal.
  static Future<void> navigateFromNotificationData(
    BuildContext? context, {
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final cleanType = NotificationGuard.normalizeType(type);

    // Identitas penerima wajib lengkap dan cocok dengan sesi login aktif.
    final notifIdentity = NotificationIdentity.fromPushData(data);
    final sessionIdentity =
        await AppNotificationStorage.instance.resolveSessionIdentity();
    if (!(notifIdentity?.matches(sessionIdentity) ?? false)) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Skipped notification navigation: identity mismatch '
          '(notif: ${notifIdentity?.userId}/${notifIdentity?.role}, '
          'current: ${sessionIdentity?.userId}/${sessionIdentity?.role})',
        );
      }
      return;
    }

    final role = sessionIdentity!.role;
    final isAsesi = role == 'asesi';
    final destination = NotificationGuard.destinationFor(
      cleanType,
      isAsesi: isAsesi,
    );
    if (destination == NotificationDestination.none) {
      if (kDebugMode) {
        debugPrint('ℹ️ Notification type "$cleanType" has no destination');
      }
      return;
    }

    final jadwalIdStr = (data['jadwal_id'] ?? '').toString().trim();
    final jadwalId = int.tryParse(jadwalIdStr);

    final state = mainNavigatorKey.currentState;
    final tabIndex = NotificationGuard.tabIndexFor(
      cleanType,
      primaryRole: role,
      isAsesi: isAsesi,
    );
    if (tabIndex >= 0 && state != null && state.mounted) {
      state.setTab(tabIndex);
    } else if (tabIndex >= 0 && kDebugMode) {
      debugPrint('⚠️ MainNavigator not mounted, skipping setTab for notification');
    }

    final navContext = context ?? navigatorKey.currentContext;

    // 1. FAQ punya layar sendiri dan tidak pernah jatuh ke detail jadwal.
    if (destination == NotificationDestination.faq) {
      if (navContext != null) {
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder: (context) => const FaqScreen(),
          ),
        );
      }
      return;
    }

    // 2. Sertifikat hanya berpindah tab — berhenti di sini walau payload
    //    membawa jadwal_id, supaya tidak salah membuka detail jadwal.
    if (destination == NotificationDestination.sertifikat) {
      return;
    }

    // 3. Detail/form hanya bila tipe memang tipe jadwal DAN jadwal_id valid.
    if (jadwalId != null && jadwalId > 0 && navContext != null) {
      final currentUser = AuthRepository.currentUserInstance;
      UserRole userRole;
      if (currentUser != null) {
        userRole = UserRole(
          role: currentUser.role,
          name: currentUser.name,
          email: currentUser.email ?? '',
        );
      } else {
        // Sesi yang baru dipulihkan: ambil role kanonikal dari profil tersimpan.
        final profile = await TokenStorage.instance.getUserProfile();
        // Tanpa role yang jelas, jangan pernah menebak (mis. asesor).
        if (profile == null) return;
        userRole = UserRole(
          role: profile.role,
          name: profile.name,
          email: profile.email ?? '',
        );
      }

      final rawNamaJadwal = (data['nama_jadwal'] ?? '').toString().trim();
      final rawSkema = (data['skema'] ?? '').toString().trim();
      final displayTitle = rawNamaJadwal.isNotEmpty
          ? rawNamaJadwal
          : (rawSkema.isNotEmpty ? rawSkema : 'Jadwal Asesmen');

      final jadwalItem = JadwalItem(
        id: jadwalId,
        skema: displayTitle,
        tuk: (data['tuk'] ?? 'TUK Mandiri').toString(),
        tanggalMulai: (data['tanggal'] ?? '').toString(),
        tanggalSelesai: (data['tanggal'] ?? '').toString(),
        createdWhen: '',
        status: 'running',
        statusJadwal: '3',
        statusLabel: 'Aktif',
        statusJadwalLabel: 'Aktif',
        statusRekaman: '',
        statusBlanko: '',
        statusPengiriman: '',
        jumlahAsesi: 0,
        asesor: [],
        sisaHari: 0,
        totalAsesi: 0,
        jumlahKompeten: 0,
        jumlahBelumKompeten: 0,
        needsAcc: false,
      );

      if (destination == NotificationDestination.umpanBalikForm) {
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder: (context) => AsesiAK03FormScreen(
              jadwal: jadwalItem,
            ),
          ),
        );
      } else {
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder: (context) => JadwalDetailScreen(
              jadwal: jadwalItem,
              userRole: userRole,
            ),
          ),
        );
      }
    }
  }

  String _getTitleFromData(Map<String, dynamic> data) {
    final type = NotificationGuard.normalizeType(data['type']);
    switch (type) {
      case NotificationGuard.sptAsesor:
        return 'SPT Asesor';
      case NotificationGuard.rekomendasiAsesor:
        return 'Rekomendasi Asesor';
      case NotificationGuard.linkPersetujuanAsesmen:
        return 'Persetujuan Asesmen';
      case NotificationGuard.linkUmpanBalik:
        return 'Mengisi Umpan Balik';
      case NotificationGuard.linkTugasPraktek:
        return 'Tugas Praktek';
      case NotificationGuard.linkKegiatanTerstruktur:
        return 'Kegiatan Terstruktur';
      case NotificationGuard.pendaftaranAsesor:
        return 'Pendaftaran Asesor';
      case NotificationGuard.faq:
        return 'Bantuan FAQ';
      case NotificationGuard.statusKompeten:
        return 'Status Kelulusan';
      case NotificationGuard.sertifikatTerbit:
        return 'Sertifikat Terbit';
      default:
        return 'Notifikasi Baru';
    }
  }

  String _getBodyFromData(Map<String, dynamic> data) {
    final type = NotificationGuard.normalizeType(data['type']);
    final skema = data['skema'] ?? 'Skema';
    final asesor = data['asesor'] ?? 'Asesor';

    switch (type) {
      case NotificationGuard.sptAsesor:
        return 'SPT Melaksanakan Asesmen Jadwal ${data['nama_jadwal'] ?? skema}';
      case NotificationGuard.rekomendasiAsesor:
        return 'Asesor $asesor telah memberikan rekomendasi asesmen.';
      case NotificationGuard.linkPersetujuanAsesmen:
        return 'Silakan lakukan persetujuan asesmen untuk skema $skema.';
      case NotificationGuard.linkUmpanBalik:
        return 'Lakukan umpan balik terhadap proses sertifikasi $skema.';
      case NotificationGuard.linkTugasPraktek:
        return 'Silakan kerjakan tugas praktek untuk skema $skema.';
      case NotificationGuard.linkKegiatanTerstruktur:
        return 'Silakan lengkapi kegiatan terstruktur untuk skema $skema.';
      case NotificationGuard.pendaftaranAsesor:
        return 'Pendaftaran penugasan asesor telah diperbarui.';
      case NotificationGuard.faq:
        return 'Informasi bantuan dan pertanyaan umum terbaru.';
      case NotificationGuard.statusKompeten:
        return 'Selamat! Anda dinyatakan kompeten pada skema $skema.';
      case NotificationGuard.sertifikatTerbit:
        return 'Sertifikat untuk skema $skema telah diterbitkan.';
      default:
        return 'Ketuk untuk melihat detail selengkapnya.';
    }
  }

  // Simulates an incoming notification (useful for testing/demo)
  void simulateIncomingNotification(RemoteMessage message) {
    _showForegroundNotification(message);
  }

  // Simulates a notification click (useful for testing/demo)
  void simulateNotificationClick(RemoteMessage message) {
    _handleNotificationClick(message);
  }
}
