import '../utils/json_helper.dart';
import 'digital_product_models.dart';

class DigitalProductOrder {
  final String id;
  final DigitalProductItem product;
  final int offeredPrice;
  final int originalPrice;
  final bool isNegotiated;
  final String notes;
  final String status; // 'Menunggu Konfirmasi', 'Kontrak Dibuat', 'Disetujui', 'Selesai'
  final String contractNumber;
  final DateTime contractDate;
  final String buyerName;
  final String sellerName;
  final String contractTerms;

  const DigitalProductOrder({
    required this.id,
    required this.product,
    required this.offeredPrice,
    required this.originalPrice,
    this.isNegotiated = false,
    this.notes = '',
    this.status = 'Kontrak Dibuat',
    required this.contractNumber,
    required this.contractDate,
    required this.buyerName,
    required this.sellerName,
    this.contractTerms = '',
  });

  String get formattedOfferedPrice {
    final digits = offeredPrice.toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String get formattedOriginalPrice {
    final digits = originalPrice.toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': {
          'id': product.id,
          'title': product.title,
          'price': product.priceValue,
          'seller_name': product.sellerName,
          'seller_phone': product.sellerPhone,
          'thumbnail_url': product.thumbnailUrl,
          'category': product.category,
          'service_type': product.serviceType,
          'product_type': product.productType,
          'negotiable': product.negotiable,
          'price_unit': product.unit,
          'show_phone': product.showPhone,
        },
        'offered_price': offeredPrice,
        'original_price': originalPrice,
        'is_negotiated': isNegotiated,
        'notes': notes,
        'status': status,
        'contract_number': contractNumber,
        'contract_date': contractDate.toIso8601String(),
        'buyer_name': buyerName,
        'seller_name': sellerName,
        'contract_terms': contractTerms,
      };

  factory DigitalProductOrder.fromJson(Map<String, dynamic> json) {
    final prodJson = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : <String, dynamic>{};

    return DigitalProductOrder(
      id: json['id']?.toString() ?? '',
      product: DigitalProductItem.fromJson(prodJson),
      offeredPrice: JsonHelper.asInt(json['offered_price']),
      originalPrice: JsonHelper.asInt(json['original_price']),
      isNegotiated: JsonHelper.asBool(json['is_negotiated']),
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Kontrak Dibuat',
      contractNumber: json['contract_number']?.toString() ?? '',
      contractDate: DateTime.tryParse(json['contract_date']?.toString() ?? '') ??
          DateTime.now(),
      buyerName: json['buyer_name']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? '',
      contractTerms: json['contract_terms']?.toString() ?? '',
    );
  }
}
