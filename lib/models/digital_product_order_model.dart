import '../utils/json_helper.dart';
import 'digital_product_models.dart';

class DigitalProductOrder {
  final String id;
  final String orderNumber;
  final DigitalProductItem product;
  final int buyerId;
  final int sellerId;
  final String buyerName;
  final String sellerName;
  final int offeredPrice;
  final int originalPrice;
  final bool isNegotiated;
  final String notes;
  final String status;
  final String contractNumber;
  final String createdAt;
  final String updatedAt;
  final bool canCounter;
  final bool canNegotiate;
  final int lastOfferBy;

  const DigitalProductOrder({
    required this.id,
    required this.orderNumber,
    required this.product,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    required this.offeredPrice,
    required this.originalPrice,
    required this.isNegotiated,
    required this.notes,
    required this.status,
    required this.contractNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.canCounter,
    required this.canNegotiate,
    required this.lastOfferBy,
  });

  String get formattedOfferedPrice => _rupiah(offeredPrice);
  String get formattedOriginalPrice => _rupiah(originalPrice);
  String get statusLabel => _statusLabel(status);

  factory DigitalProductOrder.fromJson(Map<String, dynamic> json) {
    return DigitalProductOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      product: DigitalProductItem.fromJson({
        'id': json['product_id'],
        'user_id': json['seller_id'],
        'title': json['product_title'],
        'product_type': json['product_type'],
        'category': json['product_category'],
        'thumbnail_url': json['product_thumbnail'],
        'seller_name': json['seller_name'],
        'price': json['original_price'],
        'show_phone': false,
      }),
      buyerId: JsonHelper.asInt(json['buyer_id']),
      sellerId: JsonHelper.asInt(json['seller_id']),
      buyerName: json['buyer_name']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? '',
      offeredPrice: JsonHelper.asInt(json['offered_price']),
      originalPrice: JsonHelper.asInt(json['original_price']),
      isNegotiated: JsonHelper.asBool(json['is_negotiated']),
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString().trim().toLowerCase() ?? '',
      contractNumber: json['contract_number']?.toString() ?? '',
      canCounter: JsonHelper.asBool(json['can_counter']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      canNegotiate: JsonHelper.asBool(json['can_negotiate']),
      lastOfferBy: JsonHelper.asInt(json['last_offer_by']),
    );
  }
}

class DigitalProductContract {
  final String id;
  final String orderId;
  final String contractNumber;
  final String orderNumber;
  final String productTitle;
  final DigitalProductSeller buyer;
  final DigitalProductSeller seller;
  final int agreedPrice;
  final String contractDate;
  final String contractTerms;
  final String status;
  final bool isSignedByBuyer;
  final bool isSignedBySeller;

  const DigitalProductContract({
    required this.id,
    required this.orderId,
    required this.contractNumber,
    required this.orderNumber,
    required this.productTitle,
    required this.buyer,
    required this.seller,
    required this.agreedPrice,
    required this.contractDate,
    required this.contractTerms,
    required this.status,
    required this.isSignedByBuyer,
    required this.isSignedBySeller,
  });

  String get formattedAgreedPrice => _rupiah(agreedPrice);
  String get statusLabel => _statusLabel(status);

  factory DigitalProductContract.fromJson(Map<String, dynamic> json) {
    return DigitalProductContract(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      contractNumber: json['contract_number']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      productTitle: json['product_title']?.toString() ?? '',
      buyer: DigitalProductSeller.fromJson(_object(json['buyer'])),
      seller: DigitalProductSeller.fromJson(_object(json['seller'])),
      agreedPrice: JsonHelper.asInt(json['agreed_price']),
      contractDate: json['contract_date']?.toString() ?? '',
      contractTerms: json['contract_terms']?.toString() ?? '',
      status: json['status']?.toString().trim().toLowerCase() ?? '',
      isSignedByBuyer: JsonHelper.asBool(json['is_signed_by_buyer']),
      isSignedBySeller: JsonHelper.asBool(json['is_signed_by_seller']),
    );
  }
}

Map<String, dynamic> _object(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

String _rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

String _statusLabel(String status) => switch (status) {
  'pending' => 'Menunggu konfirmasi',
  'negotiating' => 'Dalam negosiasi',
  'contract_created' => 'Kontrak dibuat',
  'accepted' => 'Disetujui',
  'rejected' => 'Ditolak',
  'completed' => 'Selesai',
  '' => 'Status belum tersedia',
  _ => status,
};
