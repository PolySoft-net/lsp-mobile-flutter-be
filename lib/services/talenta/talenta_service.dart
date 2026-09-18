import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../../utils/api_routes.dart';
import '../../models/talenta_models.dart';

class TalentaService {
  static Dio get _dio => ApiClient.dio;

  /// Fetch talents / certificate holders with optional location, skema, and query filters.
  static Future<TalentaResponse> getTalenta({
    double? lat,
    double? lng,
    double? radiusKm,
    String? kabupatenId,
    String? provinsiId,
    int? skemaId,
    int? statusPencariKerja,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (radiusKm != null && radiusKm > 0) queryParams['radius_km'] = radiusKm;
      if (kabupatenId != null && kabupatenId.isNotEmpty) {
        queryParams['kabupaten_id'] = kabupatenId;
      }
      if (provinsiId != null && provinsiId.isNotEmpty) {
        queryParams['provinsi_id'] = provinsiId;
      }
      if (skemaId != null && skemaId > 0) {
        queryParams['skema_id'] = skemaId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['q'] = search.trim();
      }
      if (statusPencariKerja != null && statusPencariKerja > 0) {
        queryParams['status_pencari_kerja'] = statusPencariKerja;
      }

      final response = await _dio.get(
        ApiRoutes.talenta,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return TalentaResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return TalentaResponse.empty;
    } on DioException catch (e) {
      debugPrint('🔴 Error fetching talenta: $e');
      rethrow;
    } catch (e) {
      debugPrint('🔴 Error fetching talenta: $e');
      return TalentaResponse.empty;
    }
  }

  /// Search asesi for admin plotting
  static Future<List<Map<String, dynamic>>> searchAsesiAdmin(String query) async {
    try {
      final response = await _dio.get(
        '/api/admin/asesi/search',
        queryParameters: {'q': query},
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'] as List<dynamic>?;
        return list?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Error search asesi admin: $e');
      return [];
    }
  }

  /// Update asesi location and job status by admin
  static Future<bool> updateAsesiLokasiAdmin({
    required int id,
    required double latitude,
    required double longitude,
    required int statusPencariKerja,
  }) async {
    try {
      final response = await _dio.put(
        '/api/admin/asesi/$id/lokasi',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'status_pencari_kerja': statusPencariKerja,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 Error update asesi lokasi admin: $e');
      return false;
    }
  }

  /// Submit job offer to a talent / asesi
  static Future<bool> tawarkanPekerjaan(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        '/api/talenta/tawaran-pekerjaan',
        data: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 Error submitting job offer: $e');
      return false;
    }
  }
}
