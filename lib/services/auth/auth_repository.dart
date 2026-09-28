import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../../utils/api_routes.dart';
import '../../models/auth_models.dart';
import 'token_storage.dart';
import '../common/notification_service.dart';

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  static AuthRepository get instance => AuthRepository(
    dio: ApiClient.dio,
    tokenStorage: TokenStorage.instance,
  );
  static Future<Map<String, dynamic>?> uploadProfilePhoto(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await ApiClient.dio.post(
        ApiRoutes.uploadFotoProfil,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode != 200 || response.data == null) return null;

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        await updateCurrentUserPhoto(
          fotoProfil: data['foto_profil']?.toString() ?? '',
          fotoProfilUrl: data['foto_profil_url']?.toString() ?? '',
        );
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  static AuthUser? currentUserInstance;

  static Future<void> updateCurrentUserPhoto({
    required String fotoProfil,
    required String fotoProfilUrl,
  }) async {
    if (currentUserInstance != null) {
      currentUserInstance = currentUserInstance!.copyWith(
        fotoProfil: fotoProfil,
        fotoProfilUrl: fotoProfilUrl,
      );
      await TokenStorage.instance.saveUserProfile(currentUserInstance!);
    }
  }

  static final List<Future<void> Function()> preLogoutHooks = [];

  static final List<void Function()> onTokenExpiredCallbacks = [];

  Future<LoginResult> login({
    required String account,
    required String password,
    String? platform,
    String? deviceToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authLogin,
      data: {
        'account': account,
        'password': password,
        'platform': ?platform,
        'device_token': ?deviceToken,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    final result = LoginResult.fromJson(data);

    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _tokenStorage.saveUserProfile(result.user);

    currentUserInstance = result.user;

    return result;
  }

  Future<LoginResult> loginWithGoogle({
    required String idToken,
    String? platform,
    String? deviceToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authGoogle,
      data: {
        'id_token': idToken,
        'platform': platform,
        'device_token': deviceToken,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    final result = LoginResult.fromJson(data);

    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _tokenStorage.saveUserProfile(result.user);

    currentUserInstance = result.user;

    return result;
  }

  /// Request password recovery instruction for Asesor / Asesi (POST /api/auth/forgot-password)
  Future<Map<String, dynamic>> forgotPassword({
    required String identity,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authForgotPassword,
      data: {
        'identity': identity.trim(),
      },
    );

    return response.data ?? {};
  }

  /// Auto-create asesi (default password 123456) if missing, then save session.
  /// [account] = NIM or NIK (max 18 chars).
  Future<LoginResult> ensureAsesi({
    required String account,
    String password = '123456',
    String? namaLengkap,
    String? email,
    String? hp,
    String? platform,
    String? deviceToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiRoutes.authEnsureAsesi,
      data: {
        'account': account.trim(),
        'password': password,
        if (namaLengkap != null && namaLengkap.isNotEmpty)
          'nama_lengkap': namaLengkap,
        if (email != null && email.isNotEmpty) 'email': email,
        if (hp != null && hp.isNotEmpty) 'hp': hp,
        'platform': ?platform,
        'device_token': ?deviceToken,
      },
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body?['message']?.toString() ?? 'ensure-asesi gagal',
      );
    }
    final result = LoginResult.fromJson(data);

    await _tokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _tokenStorage.saveUserProfile(result.user);
    currentUserInstance = result.user;

    if (kDebugMode) {
      debugPrint(
        '✅ ensure-asesi account=$account created=${body?['created']} role=${result.user.role}',
      );
    }
    return result;
  }

  Future<AuthUser> currentUser() async {
    final token = await _tokenStorage.getAccessToken();
    // Discard legacy demo tokens (pre-API mock login)
    if (token != null && token.startsWith('fake-')) {
      await _tokenStorage.clear();
      currentUserInstance = null;
      throw Exception('Sesi demo tidak valid. Silakan login ulang.');
    }

    final response = await _dio.get<Map<String, dynamic>>(ApiRoutes.authCurrent);
    final data = response.data?['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data);
    
    await _tokenStorage.saveUserProfile(user);
    currentUserInstance = user;
    return user;
  }

  Future<void> logout({String? deviceToken}) async {
    try {
      await _dio.post(
        ApiRoutes.authLogout,
        data: deviceToken != null ? {
          'device_token': deviceToken,
        } : {},
      );
      if (kDebugMode) {
        debugPrint('✅ Logout API called successfully with deviceToken: $deviceToken');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error calling logout API: $e');
      }
    }

    for (final hook in preLogoutHooks) {
      try {
        await hook();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error executing pre-logout hook: $e');
        }
      }
    }
    await _tokenStorage.clear();
    currentUserInstance = null;
    NotificationService.onNotificationReceived.add(null);
  }

  /// Dipakai ApiClient saat refresh gagal karena server bermasalah (bukan
  /// session mati). UI mendengarkan ini untuk menjelaskan ke user kenapa data
  /// gagal dimuat — tanpa menendang dia keluar dari aplikasi.
  static final ValueNotifier<int> onTransientServerTrouble =
      ValueNotifier<int>(0);

  static DateTime? _lastTransientNoticeAt;

  /// Throttle 20 detik supaya satu DB spike (banyak request gagal sekaligus)
  /// hanya memunculkan satu banner, bukan puluhan.
  static void notifyTransientServerTrouble() {
    final now = DateTime.now();
    final last = _lastTransientNoticeAt;
    if (last != null && now.difference(last) < const Duration(seconds: 20)) {
      return;
    }
    _lastTransientNoticeAt = now;
    onTransientServerTrouble.value++;
  }

  static void notifyTokenExpired() {
    if (kDebugMode) {
      debugPrint('🔴 Token expired - notifying ${onTokenExpiredCallbacks.length} callbacks');
    }
    for (final callback in onTokenExpiredCallbacks) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error executing token expired callback: $e');
        }
      }
    }
    NotificationService.onNotificationReceived.add(null);
  }

  static void registerTokenExpiredCallback(void Function() callback) {
    onTokenExpiredCallbacks.add(callback);
  }

  static void unregisterTokenExpiredCallback(void Function() callback) {
    onTokenExpiredCallbacks.remove(callback);
  }

  /// Fetch active login sessions
  static Future<List<LoginSession>> getActiveSessions({Dio? dio}) async {
    final client = dio ?? ApiClient.dio;
    try {
      final response = await client.get(ApiRoutes.sessions);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((item) => LoginSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error fetching active sessions: $e');
      return [];
    }
  }

  /// Delete a login session by session ID
  static Future<bool> deleteSession(int id, {Dio? dio}) async {
    final client = dio ?? ApiClient.dio;
    try {
      final response = await client.delete(
        ApiRoutes.sessions,
        data: {'id': id},
      );
      if (response.statusCode == 200) {
        if (response.data != null && response.data is Map) {
          final data = response.data as Map;
          return data['status'] == 'success' ||
              data['data'] == true ||
              data['success'] == true;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔴 Error deleting session: $e');
      return false;
    }
  }
}
