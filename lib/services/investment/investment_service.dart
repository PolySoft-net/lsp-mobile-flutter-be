import 'package:dio/dio.dart';

import '../../models/investment_models.dart';
import '../../utils/api_routes.dart';
import '../api_client.dart';

class InvestmentService {
  InvestmentService._();

  static Dio get _dio => ApiClient.dio;

  static List<InvestmentStartupItem> _parseStartups(dynamic data) {
    final raw = data is Map ? data['data'] : data;
    final list = raw is List ? raw : const [];
    return list
        .map((e) =>
            InvestmentStartupItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<List<InvestmentStartupItem>> getStartups({
    String search = '',
    String category = '',
    String stage = '',
    String sortBy = '',
  }) async {
    final query = <String, dynamic>{};
    if (search.trim().isNotEmpty) query['search'] = search.trim();
    if (category.trim().isNotEmpty && category.trim().toLowerCase() != 'semua') {
      query['category'] = category.trim();
    }
    if (stage.trim().isNotEmpty && stage.trim().toLowerCase() != 'semua') {
      query['stage'] = stage.trim();
    }
    if (sortBy.trim().isNotEmpty) query['sort_by'] = sortBy.trim();

    final response = await _dio.get(
      ApiRoutes.investmentStartups,
      queryParameters: query,
    );
    return _parseStartups(response.data);
  }

  static Future<InvestmentStartupItem> getStartupDetail(String id) async {
    final response = await _dio.get(ApiRoutes.investmentStartupDetail(id));
    final raw = response.data is Map ? response.data['data'] : response.data;
    return InvestmentStartupItem.fromJson(
        Map<String, dynamic>.from(raw as Map? ?? const {}));
  }

  static Future<List<InvestmentStartupItem>> getMyStartups() async {
    final response = await _dio.get(ApiRoutes.investmentMyStartups);
    return _parseStartups(response.data);
  }

  static Future<InvestmentStartupItem> createStartup(
      InvestmentStartupItem startup) async {
    final response = await _dio.post(
      ApiRoutes.investmentStartups,
      data: startup.toJson(),
    );
    final raw = response.data is Map ? response.data['data'] : response.data;
    return InvestmentStartupItem.fromJson(
        Map<String, dynamic>.from(raw as Map? ?? const {}));
  }

  static Future<bool> toggleFavorite(String startupId, bool currentIsFavorite) async {
    if (currentIsFavorite) {
      await _dio.delete(ApiRoutes.investmentFavoriteDetail(startupId));
      return false;
    } else {
      await _dio.post(ApiRoutes.investmentFavoriteDetail(startupId));
      return true;
    }
  }

  static Future<List<InvestmentStartupItem>> getFavoriteStartups() async {
    final response = await _dio.get(ApiRoutes.investmentFavorites);
    return _parseStartups(response.data);
  }

  static Future<void> submitInterest(
      InvestmentInterestSubmission submission) async {
    await _dio.post(
      ApiRoutes.investmentInterest,
      data: submission.toJson(),
    );
  }

  static Future<InvestmentStats> getStats() async {
    try {
      final response = await _dio.get(ApiRoutes.investmentStats);
      final raw = response.data is Map ? response.data['data'] : response.data;
      return InvestmentStats.fromJson(
          Map<String, dynamic>.from(raw as Map? ?? const {}));
    } catch (_) {
      return const InvestmentStats();
    }
  }
}
