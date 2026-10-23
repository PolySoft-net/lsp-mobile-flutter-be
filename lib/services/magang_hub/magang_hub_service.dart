import 'package:dio/dio.dart';

import '../../models/magang_hub_models.dart';
import '../../models/portal_banner_model.dart';
import '../../utils/api_routes.dart';
import '../api_client.dart';

/// Service untuk fitur Magang Hub (lowongan magang, perusahaan mitra, statistik).
class MagangHubService {
  MagangHubService._();

  static Dio get _dio => ApiClient.dio;

  static Future<PortalBanner> getBanner() async {
    final response = await _dio.get(ApiRoutes.magangHubBanner);
    return PortalBanner.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static Future<PortalBanner> getMyBanner() async {
    final response = await _dio.get(ApiRoutes.magangHubMyBanner);
    return PortalBanner.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static Future<PortalBanner> updateBanner(
    String imageUrl, {
    required int durationValue,
    required String durationUnit,
  }) async {
    final response = await _dio.put(
      ApiRoutes.magangHubBanner,
      data: {
        'image_url': imageUrl,
        'duration_value': durationValue,
        'duration_unit': durationUnit,
      },
    );
    return PortalBanner.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static List<CareerJobItem> _parseJobs(dynamic data) {
    final list = data is List ? data : const [];
    return list
        .map((e) =>
            CareerJobItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /api/magang-hub/lowongan — daftar lowongan magang.
  static Future<List<CareerJobItem>> getLowongan({
    String search = '',
    String workplaceType = 'Semua',
    String location = 'Semua',
    String company = '',
    String sortBy = 'terbaru',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.magangHubLowongan,
      queryParameters: {
        if (search.trim().isNotEmpty) 'q': search.trim(),
        if (workplaceType.isNotEmpty && workplaceType != 'Semua')
          'jenis_tempat': workplaceType,
        if (location.isNotEmpty && location != 'Semua') 'lokasi': location,
        if (company.trim().isNotEmpty) 'perusahaan': company.trim(),
        if (sortBy.isNotEmpty) 'sort_by': sortBy,
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    return _parseJobs(response.data['data']);
  }

  /// GET /api/magang-hub/perusahaan — daftar perusahaan mitra magang.
  static Future<List<MagangPerusahaanItem>> getPerusahaan({
    String search = '',
    String location = 'Semua',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.magangHubPerusahaan,
      queryParameters: {
        if (search.trim().isNotEmpty) 'q': search.trim(),
        if (location.isNotEmpty && location != 'Semua') 'lokasi': location,
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    final list = response.data['data'] is List ? response.data['data'] as List : const [];
    return list
        .map((e) => MagangPerusahaanItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /api/magang-hub/stats — ringkasan statistik Magang Hub.
  static Future<MagangStats> getStats() async {
    final response = await _dio.get(ApiRoutes.magangHubStats);
    final data = response.data['data'];
    if (data is Map) {
      return MagangStats.fromJson(Map<String, dynamic>.from(data));
    }
    return const MagangStats();
  }

  /// GET /api/magang-hub/lowongan/:id — detail lowongan magang.
  static Future<CareerJobItem> getDetail(String id) async {
    final response = await _dio.get(ApiRoutes.magangHubDetail(id));
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// GET /api/magang-hub/lowongan-saya — daftar magang yang dipasang asesor login.
  static Future<List<CareerJobItem>> getMyLowongan({
    String status = 'Semua',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.magangHubMyLowongan,
      queryParameters: {
        if (status.isNotEmpty && status != 'Semua') 'status': status,
        'limit': limit,
        if (offset > 0) 'offset': offset,
      },
    );
    return _parseJobs(response.data['data']);
  }

  /// POST /api/magang-hub/lowongan — asesor membuat lowongan magang baru.
  static Future<CareerJobItem> createMagang(Map<String, dynamic> payload) async {
    final response = await _dio.post(
      ApiRoutes.magangHubLowongan,
      data: payload,
    );
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// PUT /api/magang-hub/lowongan/:id — edit lowongan magang.
  static Future<CareerJobItem> updateMagang(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put(
      ApiRoutes.magangHubDetail(id),
      data: payload,
    );
    return CareerJobItem.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  /// DELETE /api/magang-hub/lowongan/:id — hapus lowongan magang.
  static Future<void> deleteMagang(String id) async {
    await _dio.delete(ApiRoutes.magangHubDetail(id));
  }

  /// POST /api/magang-hub/upload — upload berkas PDF / gambar pendukung magang.
  static Future<Map<String, String>> uploadFile(String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      ApiRoutes.magangHubUpload,
      data: formData,
    );
    final data = response.data['data'] as Map? ?? const {};
    return {
      'file_name': data['file_name']?.toString() ?? fileName,
      'file_url': data['file_url']?.toString() ?? '',
    };
  }
}
