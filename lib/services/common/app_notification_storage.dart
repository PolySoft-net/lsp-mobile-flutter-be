import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';
import '../../core/notifications/notification_guard.dart';
import '../../utils/json_helper.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? userId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.data,
    this.isRead = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'data': data,
        'isRead': isRead,
        'userId': userId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: JsonHelper.asString(json['type']),
      data: data,
      isRead: JsonHelper.asBool(json['isRead']),
      userId: json['userId']?.toString() ?? data['user_id']?.toString(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    String? userId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }
}

/// Penyimpanan notifikasi lokal, terisolasi per user (`t_users` id).
///
/// Aturan:
/// - Tanpa sesi login yang valid (access token + profil tersimpan), semua baca
///   mengembalikan kosong dan semua mutasi ditolak (fail closed) — termasuk
///   storage lama tanpa scope user.
/// - Semua mutasi hanya menyentuh kunci milik user yang sedang login.
class AppNotificationStorage {
  AppNotificationStorage._privateConstructor();
  static final AppNotificationStorage instance = AppNotificationStorage._privateConstructor();

  /// Dipancarkan setelah mutasi status baca/hapus supaya badge & panel ikut
  /// menyegarkan walau panel sedang terbuka.
  static final StreamController<void> onChanged = StreamController<void>.broadcast();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
  );

  static const _legacyKey = 'app_notifications_list';

  /// Identitas sesi login yang aktif.
  ///
  /// Profil tersimpan saja BUKAN sesi login: access token wajib ada. Ini juga
  /// satu-satunya jalur yang dipakai background isolate (di sana
  /// [AuthRepository.currentUserInstance] selalu null).
  Future<NotificationIdentity?> resolveSessionIdentity() async {
    final memory = AuthRepository.currentUserInstance;
    final memoryIdentity = NotificationIdentity.of(memory?.id, memory?.role);
    if (memoryIdentity != null) return memoryIdentity;

    try {
      final token = await TokenStorage.instance.getAccessToken();
      if (token == null || token.isEmpty) return null;
      final profile = await TokenStorage.instance.getUserProfile();
      if (profile == null) return null;
      return NotificationIdentity.of(profile.id, profile.role);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveCurrentUserId() async {
    return (await resolveSessionIdentity())?.userId;
  }

  Future<String> _getStorageKey({String? explicitUserId}) async {
    final uid = explicitUserId ?? await _resolveCurrentUserId();
    if (uid != null && uid.isNotEmpty) {
      return 'app_notifications_user_$uid';
    }
    return 'app_notifications_guest';
  }

  Future<List<AppNotification>> getNotifications({String? explicitUserId}) async {
    try {
      final session = await resolveSessionIdentity();
      if (session == null ||
          (explicitUserId != null && explicitUserId != session.userId)) {
        return [];
      }
      final currentUid = session.userId;

      final key = await _getStorageKey(explicitUserId: currentUid);
      final jsonStr = await _storage.read(key: key);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(jsonStr);
      final list = decodedList
          .whereType<Map>()
          .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
          .where((n) =>
              n.userId == currentUid &&
              NotificationIdentity.fromPushData(n.data)?.matches(session) == true)
          .toList();

      // Sort newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latestSession = await resolveSessionIdentity();
      if (!session.matches(latestSession)) return [];
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Menyimpan notifikasi milik user yang sedang login.
  ///
  /// Identitas dan role pada payload wajib cocok dengan sesi aktif.
  /// Payload tanpa scope tidak diberi identitas penerima secara otomatis.
  ///
  /// [markRead] dipakai jalur klik: notifikasi yang baru dibuka langsung
  /// berstatus terbaca dan tidak dikembalikan menjadi belum dibaca.
  Future<void> saveNotification(
    String title,
    String body,
    String type,
    Map<String, dynamic> data, {
    String? targetUserId,
    bool markRead = false,
  }) async {
    try {
      final session = await resolveSessionIdentity();
      if (session == null) return;

      final payloadIdentity = NotificationIdentity.fromPushData(data);
      if (payloadIdentity?.matches(session) != true ||
          (targetUserId != null && targetUserId != session.userId)) {
        return;
      }

      final storedData = Map<String, dynamic>.from(data)
        ..['user_id'] = session.userId
        ..['target_role'] = session.role;

      // Save to that specific user's isolated storage key
      final key = await _getStorageKey(explicitUserId: session.userId);
      final list = await getNotifications(explicitUserId: session.userId);

      final newNotif = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        data: storedData,
        isRead: markRead,
        userId: session.userId,
      );

      // Deduplicate: notifikasi identik yang datang berdekatan di-update,
      // bukan ditambah berulang. Status baca yang sudah ada TIDAK di-reset
      // kecuali pemanggil meminta [markRead].
      final existingIndex = list.indexWhere((n) =>
          n.title == title &&
          n.body == body &&
          n.type == type &&
          (markRead || DateTime.now().difference(n.timestamp).inMinutes < 15));

      if (existingIndex != -1) {
        final existing = list[existingIndex];
        list[existingIndex] = existing.copyWith(
          timestamp: markRead ? existing.timestamp : DateTime.now(),
          data: storedData,
          isRead: markRead ? true : existing.isRead,
          userId: session.userId,
        );
      } else {
        list.insert(0, newNotif);
      }

      // Keep only last 100 notifications to prevent memory issues
      if (list.length > 100) {
        list.removeRange(100, list.length);
      }

      await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      final currentUid = await _resolveCurrentUserId();
      if (currentUid == null || currentUid.isEmpty) return;

      final key = await _getStorageKey(explicitUserId: currentUid);
      final list = await getNotifications(explicitUserId: currentUid);
      final index = list.indexWhere((element) => element.id == id);
      if (index != -1 && !list[index].isRead) {
        list[index] = list[index].copyWith(isRead: true);
        await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
        onChanged.add(null);
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final currentUid = await _resolveCurrentUserId();
      if (currentUid == null || currentUid.isEmpty) return;

      final key = await _getStorageKey(explicitUserId: currentUid);
      final list = await getNotifications(explicitUserId: currentUid);
      if (list.isEmpty) return;

      final updatedList = list.map((e) => e.copyWith(isRead: true)).toList();
      await _storage.write(key: key, value: jsonEncode(updatedList.map((e) => e.toJson()).toList()));
      onChanged.add(null);
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      final currentUid = await _resolveCurrentUserId();
      if (currentUid == null || currentUid.isEmpty) return;

      final key = await _getStorageKey(explicitUserId: currentUid);
      final list = await getNotifications(explicitUserId: currentUid);
      final before = list.length;
      list.removeWhere((element) => element.id == id);
      if (list.length == before) return;

      await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
      onChanged.add(null);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final currentUid = await _resolveCurrentUserId();
      if (currentUid == null || currentUid.isEmpty) return;

      final key = await _getStorageKey(explicitUserId: currentUid);
      await _storage.delete(key: key);
      // Also clean up any legacy unscoped storage
      await _storage.delete(key: _legacyKey);
      onChanged.add(null);
    } catch (_) {}
  }

  Future<int> getUnreadCount({String? explicitUserId}) async {
    try {
      final list = await getNotifications(explicitUserId: explicitUserId);
      return list.where((element) => !element.isRead).length;
    } catch (_) {
      return 0;
    }
  }
}
