import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/digital_product_order_model.dart';
import '../models/digital_product_models.dart';

class DigitalProductCartService {
  static const _storage = FlutterSecureStorage();
  static const _cartKey = 'digital_product_cart_orders_v1';
  static final List<DigitalProductOrder> _inMemoryOrders = [];
  static bool _isLoaded = false;

  static Future<List<DigitalProductOrder>> getOrders() async {
    if (!_isLoaded) {
      await _loadFromStorage();
    }
    return List.unmodifiable(_inMemoryOrders);
  }

  static Future<void> _loadFromStorage() async {
    try {
      final raw = await _storage.read(key: _cartKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _inMemoryOrders.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _inMemoryOrders.add(DigitalProductOrder.fromJson(item));
            } else if (item is Map) {
              _inMemoryOrders.add(
                DigitalProductOrder.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }
    } catch (_) {}
    _isLoaded = true;
  }

  static Future<void> _saveToStorage() async {
    try {
      final encoded = jsonEncode(_inMemoryOrders.map((e) => e.toJson()).toList());
      await _storage.write(key: _cartKey, value: encoded);
    } catch (_) {}
  }

  static Future<DigitalProductOrder> createOrderAndContract({
    required DigitalProductItem product,
    required String buyerName,
    required int offeredPrice,
    required bool isNegotiated,
    required String notes,
  }) async {
    if (!_isLoaded) {
      await _loadFromStorage();
    }

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final contractNo = generateContractNumber();
    final contractTerms = generateContractTemplate(
      contractNumber: contractNo,
      buyerName: buyerName,
      sellerName: product.sellerName.isNotEmpty ? product.sellerName : 'Penyedia',
      productTitle: product.title,
      price: offeredPrice,
      notes: notes,
    );

    final order = DigitalProductOrder(
      id: orderId,
      product: product,
      offeredPrice: offeredPrice,
      originalPrice: product.priceValue,
      isNegotiated: isNegotiated,
      notes: notes,
      status: isNegotiated ? 'Menunggu Negosiasi' : 'Kontrak Dibuat',
      contractNumber: contractNo,
      contractDate: DateTime.now(),
      buyerName: buyerName,
      sellerName: product.sellerName,
      contractTerms: contractTerms,
    );

    // Remove older duplicate order for the same product if any, and add latest on top
    _inMemoryOrders.removeWhere((o) => o.product.id == product.id);
    _inMemoryOrders.insert(0, order);
    await _saveToStorage();

    return order;
  }

  static Future<void> removeOrder(String orderId) async {
    if (!_isLoaded) {
      await _loadFromStorage();
    }
    _inMemoryOrders.removeWhere((o) => o.id == orderId);
    await _saveToStorage();
  }

  static String generateContractNumber() {
    final now = DateTime.now();
    final year = now.year;
    final randomSuffix = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'KTR/LSP-TD/$year/$randomSuffix';
  }

  static String generateContractTemplate({
    required String contractNumber,
    required String buyerName,
    required String sellerName,
    required String productTitle,
    required int price,
    required String notes,
  }) {
    final dateStr = DateTime.now().toLocal().toString().split(' ')[0];
    final formattedPrice = 'Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

    return '''
PERJANJIAN KERJASAMA PEMESANAN PRODUK/JASA DIGITAL
Nomor: $contractNumber
Tanggal: $dateStr

Antara:
1. PIHAK PERTAMA (Penyedia):
   Nama: $sellerName
   Status: Penyedia Layanan / Penjual Resmi LSP Digital

2. PIHAK KEDUA (Pengguna / Pembeli):
   Nama: $buyerName
   Status: Pengguna Layanan / Pembeli

PASAL 1: OBJEK PERJANJIAN
Pihak Pertama sepakat untuk menyediakan dan menyerahkan produk/jasa digital berupa "$productTitle" kepada Pihak Kedua sesuai dengan spesifikasi dan standar kompetensi LSP.

PASAL 2: NILAI KESEPAKATAN
Nilai kesepakatan transaksi yang telah disepakati oleh Kedua Pihak adalah sebesar $formattedPrice.
${notes.trim().isNotEmpty ? "Catatan / Ruang Lingkup Tambahan: $notes\n" : ""}
PASAL 3: HAK DAN KEWAJIBAN
1. Pihak Pertama berkewajiban menyerahkan hasil karya/jasa secara penuh dengan kualitas terjamin.
2. Pihak Kedua berhak menerima hasil produk/jasa digital dan melakukan verifikasi hasil serah terima.
3. Seluruh komunikasi dan negosiasi transaksi ini dilakukan melalui kontak layanan resmi.

Perjanjian digital ini dibuat secara elektronik dan dinyatakan sah serta mengikat kedua belah pihak sejak tanggal pemesanan dikonfirmasi.
''';
  }
}
