import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/api_routes.dart';
import 'auth/token_storage.dart';
import 'auth/auth_repository.dart';

// ============================================================================
// API Client — Shared Dio singleton with interceptors
// ============================================================================

class ApiClient {
  ApiClient._();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Expose publicly for any repo that still needs raw Dio access
  static Dio get dio => _dio;

  static Dio? _dioInstance;
  static bool _isRefreshing = false;

  static Dio get _dio {
    return _dioInstance ??=
        Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
              receiveDataWhenStatusError: false,
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                if (kDebugMode) {
                  debugPrint(
                    '🔵 API Request: ${options.method} ${options.uri}',
                  );
                }
                final token = await TokenStorage.instance.getAccessToken();
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                options.headers['Accept-Encoding'] = 'gzip, deflate';
                return handler.next(options);
              },
              onResponse: (response, handler) {
                if (kDebugMode) {
                  debugPrint(
                    '🟢 API Response: ${response.statusCode} ${response.requestOptions.uri}',
                  );
                }
                return handler.next(response);
              },
              onError: (error, handler) async {
                if (kDebugMode) {
                  debugPrint('🔴 API Error: ${error.message}');
                  debugPrint('🔴 URL: ${error.requestOptions.uri}');
                }

                final isAuthPath =
                    error.requestOptions.path.contains(ApiRoutes.authLogin) ||
                    error.requestOptions.path.contains(ApiRoutes.authGoogle) ||
                    error.requestOptions.path.contains(ApiRoutes.authRefresh) ||
                    error.requestOptions.path.contains(ApiRoutes.authLogout);

                if (error.response?.statusCode == 401 && !isAuthPath) {
                  // A request that was already retried after a refresh and still
                  // got 401 means the session is truly gone. Stop the refresh
                  // loop and force a clean re-login instead of hanging forever.
                  if (error.requestOptions.headers['X-Refreshed'] == '1') {
                    await TokenStorage.instance.clear();
                    AuthRepository.notifyTokenExpired();
                    return handler.next(error);
                  }
                  if (_isRefreshing) {
                    return handler.next(error);
                  }
                  _isRefreshing = true;
                  try {
                    final refreshToken = await TokenStorage.instance
                        .getRefreshToken();
                    if (refreshToken != null && refreshToken.isNotEmpty) {
                      final refreshResponse =
                          await Dio(BaseOptions(baseUrl: baseUrl)).post(
                            ApiRoutes.authRefresh,
                            data: {'refresh_token': refreshToken},
                          );

                      if (refreshResponse.statusCode == 200) {
                        final newAccessToken =
                            refreshResponse.data['data']['access_token'];
                        final newRefreshToken =
                            refreshResponse.data['data']['refresh_token']
                                as String? ??
                            refreshToken;
                        await TokenStorage.instance.saveTokens(
                          accessToken: newAccessToken,
                          refreshToken: newRefreshToken,
                        );

                        error.requestOptions.headers['Authorization'] =
                            'Bearer $newAccessToken';
                        // Mark the retried request so a second 401 does not
                        // re-enter the refresh loop.
                        error.requestOptions.headers['X-Refreshed'] = '1';
                        _isRefreshing = false;

                        if (kDebugMode) {
                          debugPrint(
                            '🔄 Token refreshed successfully, retrying request',
                          );
                        }
                        return handler.resolve(
                          await _dioInstance!.fetch(error.requestOptions),
                        );
                      } else {
                        // 401/403 = refresh token benar-benar ditolak (session mati).
                        // Selain itu (429/5xx) = backend sedang bermasalah: token
                        // dipertahankan supaya user tidak di-logout massal.
                        final status = refreshResponse.statusCode ?? 0;
                        if (status == 401 || status == 403) {
                          await TokenStorage.instance.clear();
                          AuthRepository.notifyTokenExpired();
                        } else {
                          // Server bermasalah (5xx/429): session tetap hidup, tapi
                          // user harus tahu kenapa data gagal dimuat.
                          AuthRepository.notifyTransientServerTrouble();
                          if (kDebugMode) {
                            debugPrint(
                              '⚠️ Refresh sementara gagal (HTTP $status), session dipertahankan',
                            );
                          }
                        }
                        return handler.next(error);
                      }
                    } else {
                      throw DioException(
                        requestOptions: error.requestOptions,
                        message: 'No refresh token available',
                      );
                    }
                  } catch (e) {
                    if (kDebugMode) debugPrint('🔴 Token refresh failed: $e');
                    // Hanya hapus session kalau refresh memang DITOLAK backend atau
                    // refresh token tidak ada. Network error / 5xx (DB spike) bukan
                    // alasan menghapus login user — cukup gagalkan request ini.
                    final status = e is DioException
                        ? e.response?.statusCode
                        : null;
                    final rejected =
                        status == 401 ||
                        status == 403 ||
                        (e is DioException &&
                            e.message == 'No refresh token available');
                    if (rejected) {
                      await TokenStorage.instance.clear();
                      AuthRepository.notifyTokenExpired();
                    } else {
                      // Server/jaringan bermasalah: session tetap hidup, tapi user
                      // harus tahu kenapa data gagal dimuat supaya tidak dikira bug.
                      AuthRepository.notifyTransientServerTrouble();
                      if (kDebugMode) {
                        debugPrint(
                          '⚠️ Refresh gagal sementara (network/HTTP $status), token dipertahankan',
                        );
                      }
                    }
                  } finally {
                    _isRefreshing = false;
                  }
                }

                // DB/server bermasalah pada request biasa (500/503/timeout):
                // tidak ada 401, jadi blok refresh di atas tidak jalan dan user
                // hanya melihat "Gagal memuat" tanpa penjelasan. Banner dipasang
                // di sini; throttle 20 detik di notifier menahan spam.
                if (!isAuthPath &&
                    (error.response == null ||
                        (error.response?.statusCode ?? 0) >= 500)) {
                  AuthRepository.notifyTransientServerTrouble();
                }

                return handler.next(error);
              },
            ),
          );
  }
}
