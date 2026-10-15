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
}
