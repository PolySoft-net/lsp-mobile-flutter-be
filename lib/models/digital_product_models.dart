import '../utils/json_helper.dart';

class DigitalProductItem {
  final String id;
  final int userId;
  final int schemeId;
  final String schemeCode;
  final String schemeName;
  final String productType;
  final String category;
  final String serviceType;
  final String title;
  final int priceValue;
  final String author;
  final String status;
  final bool isFavorite;
  final String sellerName;
  final String sellerEmail;
  final String sellerPhone;
  final String sellerPhoto;
  final String thumbnailUrl;
  final String description;
  final String publicationStatus;

  const DigitalProductItem({
    required this.id,
    this.userId = 0,
    this.schemeId = 0,
    this.schemeCode = '',
    this.schemeName = '',
    this.productType = '',
    this.category = '',
    this.serviceType = '',
    required this.title,
    this.priceValue = 0,
    this.author = '',
    this.status = 'Open to hire / Freelance',
    this.isFavorite = false,
    this.sellerName = '',
    this.sellerEmail = '',
    this.sellerPhone = '',
    this.sellerPhoto = '',
    this.thumbnailUrl = '',
    this.description = '',
    this.publicationStatus = 'published',
  });

  factory DigitalProductItem.fromJson(Map<String, dynamic> json) {
    return DigitalProductItem(
      id: json['id']?.toString() ?? '',
      userId: JsonHelper.asInt(json['user_id']),
      schemeId: JsonHelper.asInt(json['scheme_id']),
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      productType: json['product_type']?.toString().toLowerCase() ?? '',
      category: json['category']?.toString() ?? '',
      serviceType: json['service_type']?.toString().toLowerCase() ?? '',
      title: json['title']?.toString() ?? '',
      priceValue: JsonHelper.asInt(json['price']),
      author: json['seller_name']?.toString() ?? '',
      status: json['seller_status']?.toString() ?? 'Open to hire / Freelance',
      isFavorite: JsonHelper.asBool(json['is_favorite']),
      sellerName: json['seller_name']?.toString() ?? '',
      sellerEmail: json['seller_email']?.toString() ?? '',
      sellerPhone: json['seller_phone']?.toString() ?? '',
      sellerPhoto: json['seller_photo']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      publicationStatus: json['publication_status']?.toString() ?? 'published',
    );
  }

  String get price {
    final digits = priceValue.toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String get priceUnit => priceValue == 0
      ? ''
      : '/${status.toLowerCase().contains('nego') ? 'Nego' : 'Tetap'}';

  String get thumbnailType => thumbnailUrl.isEmpty ? 'iot' : 'network';

  List<String> get tags => [
    if (serviceType.isNotEmpty) '#${_titleCase(serviceType)}',
    if (productType.isNotEmpty) '#${_titleCase(productType)}',
    if (category.isNotEmpty) '#$category',
    if (schemeCode.isNotEmpty) '#$schemeCode',
  ];

  bool matchesFilter(String? filter) {
    final value = filter?.toLowerCase();
    return value == null ||
        value.isEmpty ||
        value == serviceType ||
        value == productType;
  }

  DigitalProductItem copyWith({bool? isFavorite}) {
    return DigitalProductItem(
      id: id,
      userId: userId,
      schemeId: schemeId,
      schemeCode: schemeCode,
      schemeName: schemeName,
      productType: productType,
      category: category,
      serviceType: serviceType,
      title: title,
      priceValue: priceValue,
      author: author,
      status: status,
      isFavorite: isFavorite ?? this.isFavorite,
      sellerName: sellerName,
      sellerEmail: sellerEmail,
      sellerPhone: sellerPhone,
      sellerPhoto: sellerPhoto,
      thumbnailUrl: thumbnailUrl,
      description: description,
      publicationStatus: publicationStatus,
    );
  }

  static String _titleCase(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class DigitalProductMedia {
  final int id;
  final String type;
  final String url;
  final String fileName;
  final bool isPrimary;

  const DigitalProductMedia({
    required this.id,
    required this.type,
    required this.url,
    required this.fileName,
    required this.isPrimary,
  });

  factory DigitalProductMedia.fromJson(Map<String, dynamic> json) {
    return DigitalProductMedia(
      id: JsonHelper.asInt(json['id']),
      type: json['type']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      isPrimary: JsonHelper.asBool(json['is_primary']),
    );
  }
}

class DigitalProductCertificate {
  final int schemeId;
  final String schemeCode;
  final String schemeName;
  final String competencyStatus;
  final String certificateNo;

  const DigitalProductCertificate({
    required this.schemeId,
    required this.schemeCode,
    required this.schemeName,
    required this.competencyStatus,
    required this.certificateNo,
  });

  factory DigitalProductCertificate.fromJson(Map<String, dynamic> json) {
    return DigitalProductCertificate(
      schemeId: JsonHelper.asInt(json['scheme_id']),
      schemeCode: json['scheme_code']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      competencyStatus: json['competency_status']?.toString() ?? '',
      certificateNo: json['certificate_no']?.toString() ?? '',
    );
  }
}

class DigitalProductSeller {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String profilePhoto;

  const DigitalProductSeller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePhoto,
  });

  factory DigitalProductSeller.fromJson(Map<String, dynamic> json) {
    return DigitalProductSeller(
      id: JsonHelper.asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString() ?? '',
    );
  }

  static const empty = DigitalProductSeller(
    id: 0,
    name: '',
    email: '',
    phone: '',
    profilePhoto: '',
  );
}

class DigitalProductDetail {
  final DigitalProductItem product;
  final DigitalProductSeller seller;
  final List<DigitalProductMedia> media;
  final List<DigitalProductCertificate> certificates;
  final List<DigitalProductItem> sellerProducts;

  const DigitalProductDetail({
    required this.product,
    required this.seller,
    required this.media,
    required this.certificates,
    required this.sellerProducts,
  });

  factory DigitalProductDetail.fromJson(Map<String, dynamic> json) {
    return DigitalProductDetail(
      product: DigitalProductItem.fromJson(json),
      seller: DigitalProductSeller.fromJson(
        Map<String, dynamic>.from(json['seller'] as Map? ?? const {}),
      ),
      media: _mapList(json['media'], DigitalProductMedia.fromJson),
      certificates: _mapList(
        json['certificates'],
        DigitalProductCertificate.fromJson,
      ),
      sellerProducts: _mapList(
        json['seller_products'],
        DigitalProductItem.fromJson,
      ),
    );
  }
}

class DigitalProductProfile {
  final DigitalProductSeller seller;
  final List<DigitalProductCertificate> certificates;
  final List<DigitalProductItem> products;

  const DigitalProductProfile({
    required this.seller,
    required this.certificates,
    required this.products,
  });

  factory DigitalProductProfile.fromJson(Map<String, dynamic> json) {
    return DigitalProductProfile(
      seller: DigitalProductSeller.fromJson(
        Map<String, dynamic>.from(json['seller'] as Map? ?? const {}),
      ),
      certificates: _mapList(
        json['certificates'],
        DigitalProductCertificate.fromJson,
      ),
      products: _mapList(json['products'], DigitalProductItem.fromJson),
    );
  }
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  final list = value is List ? value : const [];
  return list
      .whereType<Map>()
      .map((item) => parser(Map<String, dynamic>.from(item)))
      .toList();
}
