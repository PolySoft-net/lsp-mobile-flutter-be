import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/asesi/asesi_portofolio_model.dart';
import '../../utils/api_routes.dart';
import '../api_client.dart';

class AsesiPortofolioService {
  static Dio get _dio => ApiClient.dio;

  /// Mengambil daftar portofolio mandiri asesi (t_repositori)
  static Future<List<AsesiPortofolioItem>> getPortofolioList() async {
    try {
      final response = await _dio.get(ApiRoutes.asesiPortofolioList);
      if (response.data != null && response.data['data'] is List) {
        final list = response.data['data'] as List;
        return list
            .map((e) => AsesiPortofolioItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getPortofolioList: $e');
      }
      return const [];
    }
  }

  /// Menyimpan portofolio berbentuk tautan/link (misal GitHub, Figma, Website)
  static Future<AsesiPortofolioItem?> createPortofolioLink({
    required String judul,
    required String linkUrl,
    required String tanggal,
    required String deskripsi,
  }) async {
    try {
      final normalizedLink = linkUrl.trim().startsWith('http://') ||
              linkUrl.trim().startsWith('https://')
          ? linkUrl.trim()
          : 'https://${linkUrl.trim()}';

      final formData = FormData.fromMap({
        'tipe': 'link',
        'judul': judul.trim(),
        'link_url': normalizedLink,
        'tanggal': tanggal.trim(),
        'deskripsi': deskripsi.trim(),
      });

      final response = await _dio.post(
        ApiRoutes.asesiPortofolioList,
        data: formData,
      );

      if (response.data != null && response.data['data'] != null) {
        return AsesiPortofolioItem.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error createPortofolioLink: $e');
      }
      rethrow;
    }
  }

  /// Mengunggah berkas portofolio (Dokumen PDF atau Foto/Gambar)
  static Future<AsesiPortofolioItem?> createPortofolioFile({
    required String judul,
    required String filePath,
    required String tanggal,
    required String deskripsi,
    required String tipe, // "dokumen" atau "gambar"
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Berkas tidak ditemukan pada perangkat.');
      }

      final fileName = filePath.contains('/')
          ? filePath.split('/').last
          : filePath.split('\\').last;

      final formData = FormData.fromMap({
        'tipe': tipe,
        'judul': judul.trim(),
        'tanggal': tanggal.trim(),
        'deskripsi': deskripsi.trim(),
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiRoutes.asesiPortofolioList,
        data: formData,
      );

      if (response.data != null && response.data['data'] != null) {
        return AsesiPortofolioItem.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error createPortofolioFile: $e');
      }
      rethrow;
    }
  }

  /// Menghapus portofolio milik asesi
  static Future<bool> deletePortofolio(int id) async {
    try {
      final response = await _dio.delete(ApiRoutes.asesiPortofolioDelete(id));
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deletePortofolio: $e');
      }
      return false;
    }
  }
}
