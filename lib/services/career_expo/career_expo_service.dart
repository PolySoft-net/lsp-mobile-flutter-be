import 'package:dio/dio.dart';

import '../../models/career_expo_models.dart';
import '../../utils/api_routes.dart';
import '../api_client.dart';

/// Service Career Expo: lowongan, lamaran, dan tersimpan (bookmark).
/// Semua method melempar DioException apa adanya — pemanggil (screen) yang
/// memutuskan UI error/retry-nya.
class CareerExpoService {
  CareerExpoService._();

  static Dio get _dio => ApiClient.dio;

  static List<CareerJobItem> _parseJobs(dynamic data) {
    final list = data is List ? data : const [];
    return list
        .map((e) =>
            CareerJobItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /api/career-expo/lowongan — daftar lowongan (guest boleh).
  /// Filter 'Semua' tidak dikirim ke server.
  static Future<List<CareerJobItem>> getLowongan({
    String search = '',
    String employmentType = 'Semua',
    String workplaceType = 'Semua',
    String location = 'Semua',
    String sortBy = 'relevan',
    bool popularOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.careerExpoLowongan,
      queryParameters: {
        if (search.trim().isNotEmpty) 'q': search.trim(),
        if (employmentType.isNotEmpty && employmentType != 'Semua')
          'tipe_pekerjaan': employmentType,
        if (workplaceType.isNotEmpty && workplaceType != 'Semua')
          'jenis_tempat': workplaceType,
        if (location.isNotEmpty && location != 'Semua') 'lokasi': location,
        if (sortBy.isNotEmpty) 'sort_by': sortBy,
        if (popularOnly) 'popular': 'true',
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    return _parseJobs(response.data['data']);
  }

  /// GET /api/career-expo/lowongan/:id — detail lowongan.
  static Future<CareerJobItem> getDetail(String id) async {
    final response = await _dio.get(ApiRoutes.careerExpoLowonganDetail(id));
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// GET /api/career-expo/lamaran — lamaran user yang sedang login.
  static Future<List<CareerApplicationItem>> getLamaran({
    String status = 'Semua',
  }) async {
    final response = await _dio.get(
      ApiRoutes.careerExpoLamaran,
      queryParameters: {if (status.isNotEmpty && status != 'Semua') 'status': status},
    );
    final list = response.data['data'] is List ? response.data['data'] as List : const [];
    return list
        .map((e) => CareerApplicationItem.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/career-expo/lowongan/:id/lamar — kirim lamaran.
  /// 401 = belum login, 409 = sudah pernah melamar.
  static Future<void> lamar(
    String lowonganId, {
    required String namaLengkap,
    required String email,
    required String noHp,
    String coverLetter = '',
    String linkPortofolio = '',
    String fileCv = '',
    String namaFileCv = '',
    bool sertakanSertifikat = false,
  }) async {
    await _dio.post(
      ApiRoutes.careerExpoLamar(lowonganId),
      data: {
        'nama_lengkap': namaLengkap,
        'email': email,
        'no_hp': noHp,
        'cover_letter': coverLetter,
        'link_portofolio': linkPortofolio,
        'file_cv': fileCv,
        'nama_file_cv': namaFileCv,
        'sertakan_sertifikat': sertakanSertifikat,
      },
    );
  }

  /// POST/DELETE /api/career-expo/lowongan/:id/tersimpan — bookmark.
  static Future<void> setTersimpan(String lowonganId, bool bookmarked) async {
    if (bookmarked) {
      await _dio.post(ApiRoutes.careerExpoTersimpan(lowonganId));
    } else {
      await _dio.delete(ApiRoutes.careerExpoTersimpan(lowonganId));
    }
  }

  /// DELETE /api/career-expo/lowongan/:id/lamar — batalkan lamaran.
  static Future<void> batalLamar(String lowonganId) async {
    await _dio.delete(ApiRoutes.careerExpoLamar(lowonganId));
  }

  /// DELETE /api/career-expo/lamaran/:id — hapus riwayat lamaran.
  static Future<void> hapusLamaran(String lamaranId) async {
    await _dio.delete(ApiRoutes.careerExpoDeleteLamaran(lamaranId));
  }

  /// GET /api/career-expo/tersimpan — daftar lowongan yang disimpan/favorit.
  static Future<List<CareerJobItem>> getTersimpan({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.careerExpoTersimpanList,
      queryParameters: {
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    return _parseJobs(response.data['data']);
  }

  /// GET /api/career-expo/notifikasi — daftar notifikasi Career Expo.
  static Future<List<CareerNotificationItem>> getNotifikasi({
    String kategori = 'Semua',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.careerExpoNotifikasi,
      queryParameters: {
        if (kategori.isNotEmpty && kategori != 'Semua') 'kategori': kategori,
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    final list = response.data['data'] is List ? response.data['data'] as List : const [];
    return list
        .map((e) => CareerNotificationItem.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /api/career-expo/notifikasi/unread-count — jumlah notifikasi belum dibaca.
  static Future<int> getUnreadNotifikasiCount() async {
    final response = await _dio.get(ApiRoutes.careerExpoNotifikasiUnreadCount);
    final data = response.data['data'];
    if (data is Map && data['unread_count'] != null) {
      final count = data['unread_count'];
      if (count is int) return count;
      if (count is num) return count.toInt();
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }

  /// PUT /api/career-expo/notifikasi/:id/read — tandai notifikasi dibaca.
  static Future<void> markNotifikasiRead(String id) async {
    await _dio.put(ApiRoutes.careerExpoNotifikasiRead(id));
  }

  /// PUT /api/career-expo/notifikasi/read-all — tandai semua notifikasi dibaca.
  static Future<void> markAllNotifikasiRead() async {
    await _dio.put(ApiRoutes.careerExpoNotifikasiReadAll);
  }

  /// GET /api/career-expo/filter-options — opsi filter dinamis dari API.
  static Future<CareerFilterOptions> getFilterOptions() async {
    try {
      final response = await _dio.get(ApiRoutes.careerExpoFilterOptions);
      final data = response.data['data'];
      if (data is Map) {
        return CareerFilterOptions.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return const CareerFilterOptions();
  }

  /// POST /api/career-expo/upload — upload berkas PDF / gambar untuk Career Expo
  static Future<Map<String, String>> uploadFile(String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      ApiRoutes.careerExpoUpload,
      data: formData,
    );
    final data = response.data['data'] as Map? ?? {};
    return {
      'file_name': data['file_name']?.toString() ?? fileName,
      'file_url': data['file_url']?.toString() ?? '',
    };
  }

  /// POST /api/career-expo/lowongan — asesor/admin input lowongan pekerjaan baru
  static Future<CareerJobItem> createLowongan(Map<String, dynamic> payload) async {
    final response = await _dio.post(
      ApiRoutes.careerExpoLowongan,
      data: payload,
    );
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// PUT /api/career-expo/lowongan/:id — edit lowongan
  static Future<CareerJobItem> updateLowongan(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put(
      ApiRoutes.careerExpoLowonganDetail(id),
      data: payload,
    );
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// DELETE /api/career-expo/lowongan/:id — hapus lowongan
  static Future<void> deleteLowongan(String id) async {
    await _dio.delete(ApiRoutes.careerExpoLowonganDetail(id));
  }

  /// GET /api/career-expo/lowongan-saya — daftar lowongan yang dipasang oleh asesor ini
  static Future<List<CareerJobItem>> getMyLowongan({
    String status = 'Semua',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.careerExpoMyLowongan,
      queryParameters: {
        if (status.isNotEmpty && status != 'Semua') 'status': status,
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    return _parseJobs(response.data['data']);
  }
}
