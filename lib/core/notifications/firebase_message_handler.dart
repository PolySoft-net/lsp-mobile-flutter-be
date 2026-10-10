import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'notification_guard.dart';
import '../../services/common/app_notification_storage.dart';

/// Background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    debugPrint('📨 Background message received!');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }

  final data = message.data;

  // Fail closed: notifikasi hanya diproses bila identitas penerima
  // (user_id + target_role) lengkap DAN cocok dengan sesi login tersimpan.
  // Di isolate ini AuthRepository.currentUserInstance selalu null, jadi sesi
  // dipulihkan dari access token + profil yang tersimpan.
  final notifIdentity = NotificationIdentity.fromPushData(data);
  final sessionIdentity =
      await AppNotificationStorage.instance.resolveSessionIdentity();
  if (!(notifIdentity?.matches(sessionIdentity) ?? false)) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ Ignored background notification: identity mismatch '
        '(notif: ${notifIdentity?.userId}/${notifIdentity?.role}, '
        'current: ${sessionIdentity?.userId}/${sessionIdentity?.role})',
      );
    }
    return;
  }

  final type = NotificationGuard.normalizeType(data['type']);

  String getTitle() {
    if (message.notification?.title != null) {
      return message.notification!.title!;
    }
    switch (type) {
      case NotificationGuard.statusKompeten:
        return 'Status Kelulusan';
      case NotificationGuard.rekomendasiAsesor:
        return 'Rekomendasi Asesor';
      case NotificationGuard.sertifikatTerbit:
        return 'Sertifikat Terbit';
      default:
        return 'Notifikasi Baru';
    }
  }

  String getBody() {
    if (message.notification?.body != null) {
      return message.notification!.body!;
    }
    final skema = data['skema'] ?? 'Skema';
    final asesor = data['asesor'] ?? 'Asesor';
    switch (type) {
      case NotificationGuard.statusKompeten:
        return 'Selamat! Anda dinyatakan kompeten pada skema $skema.';
      case NotificationGuard.rekomendasiAsesor:
        return 'Asesor $asesor telah memberikan rekomendasi.';
      case NotificationGuard.sertifikatTerbit:
        return 'Sertifikat untuk skema $skema telah diterbitkan.';
      default:
        return 'Ketuk untuk melihat detail selengkapnya.';
    }
  }

  final title = getTitle();
  final body = getBody();

  await AppNotificationStorage.instance.saveNotification(
    title,
    body,
    type,
    data,
    targetUserId: sessionIdentity!.userId,
  );
}
