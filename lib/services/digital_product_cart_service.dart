import 'package:dio/dio.dart';

import '../models/digital_product_models.dart';
import '../models/digital_product_order_model.dart';
import '../utils/api_routes.dart';
import 'api_client.dart';

class DigitalProductCartService {
  static Dio get _dio => ApiClient.dio;
  static Options get _options => Options(receiveDataWhenStatusError: true);

  static Future<List<DigitalProductOrder>> getOrders({
    String? status,
    String? role,
    int? productId,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiRoutes.digitalProductOrders,
      queryParameters: {
        if (status != null && status.isNotEmpty && status != 'all')
          'status': status,
        if (role != null && role.isNotEmpty) 'role': role,
        if (productId != null && productId > 0) 'product_id': productId,
        'limit': limit,
        'offset': offset,
      },
      options: _options,
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) {
      throw const FormatException('Respons daftar pesanan tidak valid');
    }
    return data.map((value) {
      final order = DigitalProductOrder.fromJson(_object(value));
      _requireId(order.id);
      return order;
    }).toList();
  }

  static Future<DigitalProductOrder> createOrderAndContract({
    required DigitalProductItem product,
    required int offeredPrice,
    required bool isNegotiated,
    required String notes,
  }) async {
    _requireId(product.id);
    final response = await _dio.post(
      ApiRoutes.digitalProductOrders,
      data: {
        'product_id': int.parse(product.id),
        'offered_price': offeredPrice,
        'is_negotiated': isNegotiated,
        'notes': notes,
      },
      options: _options,
    );
    final order = DigitalProductOrder.fromJson(_data(response));
    _requireId(order.id);
    return order;
  }

  static Future<DigitalProductContract> getContract(String orderId) async {
    _requireId(orderId);
    final response = await _dio.get(
      ApiRoutes.digitalProductOrderContract(orderId),
      options: _options,
    );
    final contract = DigitalProductContract.fromJson(_data(response));
    _requireId(contract.id);
    if (contract.orderId != orderId || contract.contractTerms.trim().isEmpty) {
      throw const FormatException('Respons kontrak pesanan tidak valid');
    }
    return contract;
  }

  static Future<DigitalProductOrder> negotiateOrder(
    String orderId, {
    required String action,
    int? counterPrice,
    String notes = '',
  }) async {
    _requireId(orderId);
    if (!const ['accept', 'counter', 'reject'].contains(action)) {
      throw ArgumentError.value(action, 'action');
    }
    if (action == 'counter' && (counterPrice == null || counterPrice <= 0)) {
      throw ArgumentError('Harga penawaran wajib lebih dari nol');
    }
    final response = await _dio.put(
      ApiRoutes.digitalProductOrderNegotiate(orderId),
      data: {
        'action': action,
        if (action == 'counter') 'counter_price': counterPrice,
        'notes': notes,
      },
      options: _options,
    );
    final order = DigitalProductOrder.fromJson(_data(response));
    if (order.id != orderId) {
      throw const FormatException('Respons negosiasi pesanan tidak valid');
    }
    return order;
  }

  static String errorMessage(Object error) {
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final message = (body['message'] ?? body['error'])?.toString();
        if (message != null && message.trim().isNotEmpty) return message;
      }
      if (error.response?.statusCode == 401) {
        return 'Silakan login kembali untuk mengakses pesanan.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Koneksi gagal. Periksa daftar pesanan sebelum mengirim ulang.';
      }
      return 'Permintaan pesanan gagal. Silakan coba lagi.';
    }
    if (error is FormatException) return error.message;
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Data pesanan tidak valid.';
    }
    return 'Permintaan pesanan gagal. Silakan coba lagi.';
  }

  static Map<String, dynamic> _data(Response<dynamic> response) =>
      _object(response.data is Map ? response.data['data'] : null);

  static Map<String, dynamic> _object(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Respons transaksi tidak valid');
    }
    return Map<String, dynamic>.from(value);
  }

  static void _requireId(String id) {
    if ((int.tryParse(id) ?? 0) <= 0) {
      throw const FormatException('ID transaksi tidak valid');
    }
  }
}
