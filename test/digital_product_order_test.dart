import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_digital_mobile/models/digital_product_models.dart';
import 'package:lsp_digital_mobile/models/digital_product_order_model.dart';
import 'package:lsp_digital_mobile/services/api_client.dart';
import 'package:lsp_digital_mobile/services/digital_product_cart_service.dart';

void main() {
  test('Order database ID never falls back to the display order number', () {
    final order = DigitalProductOrder.fromJson({
      'order_number': 'ORD-20261001-A1B2',
      'product_id': '12',
      'seller_id': '2',
      'offered_price': '18000000',
      'is_negotiated': '1',
      'can_negotiate': '0',
      'status': 'REJECTED',
    });
    expect(order.id, isEmpty);
    expect(order.statusLabel, 'Ditolak');
    expect(order.canNegotiate, isFalse);
    expect(order.offeredPrice, 18000000);
    expect(order.product.sellerPhone, isEmpty);
    expect(order.product.showPhone, isFalse);
  });

  test(
    'Contract distinguishes buyer and seller consent for mixed API types',
    () {
      final contract = DigitalProductContract.fromJson({
        'order_id': 41,
        'buyer': {'id': '5', 'name': 'Pembeli'},
        'seller': null,
        'is_signed_by_buyer': 'false',
        'is_signed_by_seller': 1,
        'agreed_price': '18000000',
      });
      expect(contract.orderId, '41');
      expect(contract.buyer.id, 5);
      expect(contract.seller.id, 0);
      expect(contract.isSignedByBuyer, isFalse);
      expect(contract.isSignedBySeller, isTrue);
      expect(contract.agreedPrice, 18000000);
      expect(contract.contractDate, isEmpty);
    },
  );

  group('Failed create must never become a local successful order', () {
    late List<Interceptor> interceptors;
    late Map<String, String> environment;
    late bool initialized;
    setUpAll(() {
      initialized = dotenv.isInitialized;
      environment = initialized ? Map.of(dotenv.env) : {};
      dotenv.loadFromString(envString: 'BASE_URL=http://localhost');
      interceptors = List.of(ApiClient.dio.interceptors);
    });
    setUp(() => ApiClient.dio.interceptors.clear());
    tearDownAll(() {
      ApiClient.dio.interceptors
        ..clear()
        ..addAll(interceptors);
      if (initialized) {
        dotenv.loadFromString(isOptional: true, mergeWith: environment);
      } else {
        dotenv.clean();
      }
    });

    for (final status in [400, 403, 500]) {
      test('HTTP $status propagates and preserves backend error', () async {
        ApiClient.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: status,
                  data: {'message': 'Pesanan tidak dapat dibuat'},
                ),
              ),
            ),
          ),
        );
        await expectLater(
          DigitalProductCartService.createOrderAndContract(
            product: const DigitalProductItem(id: '12', title: 'Produk'),
            offeredPrice: 18000000,
            isNegotiated: true,
            notes: '',
          ),
          throwsA(
            isA<DioException>().having(
              DigitalProductCartService.errorMessage,
              'backend error',
              'Pesanan tidak dapat dibuat',
            ),
          ),
        );
      });
    }

    test(
      'HTTP success without database ID is not a successful order',
      () async {
        ApiClient.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'data': {'order_number': 'ORD-server-without-id'},
                },
              ),
            ),
          ),
        );
        await expectLater(
          DigitalProductCartService.createOrderAndContract(
            product: const DigitalProductItem(id: '12', title: 'Produk'),
            offeredPrice: 100,
            isNegotiated: false,
            notes: '',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
