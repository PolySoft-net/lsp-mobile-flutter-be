import 'package:dio/dio.dart';

import '../models/digital_product_models.dart';
import '../utils/api_routes.dart';
import '../utils/image_compress_helper.dart';
import 'api_client.dart';

class DigitalProductService {
  static Dio get _dio => ApiClient.dio;

  static Future<List<DigitalProductItem>> getProducts({
    String search = '',
    String filter = '',
    String sortBy = 'latest',
  }) async {
    final response = await _dio.get(
      ApiRoutes.digitalProducts,
      queryParameters: {
        if (search.trim().isNotEmpty) 'q': search.trim(),
        if (filter.isNotEmpty && filter.toLowerCase() != 'semua')
          'filter': filter.toLowerCase(),
        if (sortBy.isNotEmpty) 'sort_by': sortBy,
      },
    );
    return _parseProducts(response.data);
  }

  static Future<List<DigitalProductItem>> getPopularProducts({
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiRoutes.digitalProductPopular(limit: limit),
      );
      return _parseProducts(response.data);
    } catch (_) {
      try {
        final fallbackResponse = await _dio.get(
          ApiRoutes.digitalProducts,
          queryParameters: {'filter': 'popular', 'limit': limit},
        );
        return _parseProducts(fallbackResponse.data);
      } catch (_) {
        return const [];
      }
    }
  }

  static Future<DigitalProductDetail> getDetail(String id) async {
    final response = await _dio.get(ApiRoutes.digitalProductDetail(id));
    return DigitalProductDetail.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static Future<List<DigitalProductItem>> getFavorites({
    String filter = '',
  }) async {
    final response = await _dio.get(
      ApiRoutes.digitalProductFavorites,
      queryParameters: {if (filter.isNotEmpty) 'filter': filter.toLowerCase()},
    );
    return _parseProducts(response.data);
  }

  static Future<List<DigitalProductItem>> getMine() async {
    final response = await _dio.get(ApiRoutes.digitalProductMine);
    return _parseProducts(response.data);
  }

  static Future<DigitalProductProfile> getProfile() async {
    final response = await _dio.get(ApiRoutes.digitalProductProfile);
    return DigitalProductProfile.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? photoPath,
  }) async {
    Response response;
    if (photoPath != null && photoPath.isNotEmpty) {
      final compressedPhotoPath =
          await ImageCompressHelper.compressImage(photoPath);
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'email': email,
        '_method': 'PUT',
        'profile_photo': await MultipartFile.fromFile(
          compressedPhotoPath,
          filename: _fileName(compressedPhotoPath),
        ),
      });
      response = await _dio.post(
        ApiRoutes.digitalProductProfile,
        data: formData,
      );
    } else {
      try {
        response = await _dio.put(
          ApiRoutes.digitalProductProfile,
          data: {
            'name': name,
            'phone': phone,
            'email': email,
          },
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          response = await _dio.post(
            ApiRoutes.digitalProductProfile,
            data: {
              'name': name,
              'phone': phone,
              'email': email,
            },
          );
        } else {
          rethrow;
        }
      }
    }
    return Map<String, dynamic>.from(
      response.data is Map ? response.data as Map : const {},
    );
  }
  static Future<void> setFavorite(String id, bool favorite) async {
    final route = ApiRoutes.digitalProductFavorite(id);
    if (favorite) {
      await _dio.post(route);
    } else {
      await _dio.delete(route);
    }
  }

  static Future<DigitalProductDetail> createProduct({
    required int schemeId,
    required String productType,
    required String category,
    required String serviceType,
    required String title,
    required String description,
    required int price,
    required bool negotiable,
    required List<String> productFiles,
    required List<String> portfolioFiles,
  }) async {
    final compressedProductFiles =
        await ImageCompressHelper.compressAll(productFiles);
    final compressedPortfolioFiles =
        await ImageCompressHelper.compressAll(portfolioFiles);

    final data = FormData.fromMap({
      'scheme_id': schemeId,
      'product_type': productType.toLowerCase(),
      'category': category,
      'service_type': serviceType.toLowerCase(),
      'title': title,
      'description': description,
      'price': price,
      'negotiable': negotiable,
      'seller_status': 'Open to hire / Freelance',
      'product_files': [
        for (final path in compressedProductFiles)
          await MultipartFile.fromFile(path, filename: _fileName(path)),
      ],
      'portfolio_files': [
        for (final path in compressedPortfolioFiles)
          await MultipartFile.fromFile(path, filename: _fileName(path)),
      ],
    });
    final response = await _dio.post(ApiRoutes.digitalProducts, data: data);
    return DigitalProductDetail.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map? ?? const {}),
    );
  }

  static String absoluteUrl(String value) {
    if (value.isEmpty ||
        value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }
    return '${ApiClient.baseUrl}${value.startsWith('/') ? value : '/$value'}';
  }

  static List<DigitalProductItem> _parseProducts(dynamic body) {
    final data = body is Map ? body['data'] : null;
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map(
          (item) =>
              DigitalProductItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;
}
