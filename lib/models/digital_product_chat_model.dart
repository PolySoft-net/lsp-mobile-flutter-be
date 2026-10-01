import '../utils/url_helper.dart';

class DigitalProductChatParty {
  final int id;
  final String name;
  final String photo;

  const DigitalProductChatParty({
    required this.id,
    required this.name,
    required this.photo,
  });

  String get photoUrl =>
      photo.trim().isNotEmpty ? UrlHelper.resolveUrl(photo) : '';

  factory DigitalProductChatParty.fromJson(Map<String, dynamic> json) {
    return DigitalProductChatParty(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      photo: (json['photo'] as String?)?.trim() ?? '',
    );
  }
}

class DigitalProductChatRoom {
  final int id;
  final int productId;
  final String productTitle;
  final String productThumbnail;
  final int productPrice;
  final DigitalProductChatParty buyer;
  final DigitalProductChatParty seller;
  final int? orderId;
  final String lastMessageText;
  final String lastMessageAt;
  final int unreadCount;
  final String createdAt;
  final String updatedAt;

  const DigitalProductChatRoom({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productThumbnail,
    required this.productPrice,
    required this.buyer,
    required this.seller,
    this.orderId,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  String get productThumbnailUrl => productThumbnail.trim().isNotEmpty
      ? UrlHelper.resolveUrl(productThumbnail)
      : '';

  DigitalProductChatParty counterparty(int currentUserId) {
    return currentUserId == buyer.id ? seller : buyer;
  }

  factory DigitalProductChatRoom.fromJson(Map<String, dynamic> json) {
    return DigitalProductChatRoom(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productTitle: (json['product_title'] as String?)?.trim() ?? '',
      productThumbnail: (json['product_thumbnail'] as String?)?.trim() ?? '',
      productPrice:
          int.tryParse(json['product_price']?.toString() ?? '0') ?? 0,
      buyer: DigitalProductChatParty.fromJson(
        Map<String, dynamic>.from(json['buyer'] as Map? ?? {}),
      ),
      seller: DigitalProductChatParty.fromJson(
        Map<String, dynamic>.from(json['seller'] as Map? ?? {}),
      ),
      orderId: json['order_id'] != null
          ? int.tryParse(json['order_id'].toString())
          : null,
      lastMessageText: (json['last_message_text'] as String?)?.trim() ?? '',
      lastMessageAt: (json['last_message_at'] as String?)?.trim() ?? '',
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      createdAt: (json['created_at'] as String?)?.trim() ?? '',
      updatedAt: (json['updated_at'] as String?)?.trim() ?? '',
    );
  }
}

class DigitalProductChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String senderPhoto;
  final String messageType;
  final String message;
  final String attachmentUrl;
  final dynamic metadata;
  final bool isRead;
  final String readAt;
  final String createdAt;
  final bool isMe;

  const DigitalProductChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderPhoto,
    required this.messageType,
    required this.message,
    required this.attachmentUrl,
    this.metadata,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.isMe,
  });

  String get resolvedAttachmentUrl => attachmentUrl.trim().isNotEmpty
      ? UrlHelper.resolveUrl(attachmentUrl)
      : '';

  factory DigitalProductChatMessage.fromJson(Map<String, dynamic> json) {
    return DigitalProductChatMessage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      roomId: int.tryParse(json['room_id']?.toString() ?? '0') ?? 0,
      senderId: int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      senderName: (json['sender_name'] as String?)?.trim() ?? '',
      senderPhoto: (json['sender_photo'] as String?)?.trim() ?? '',
      messageType: (json['message_type'] as String?)?.trim() ?? 'text',
      message: (json['message'] as String?)?.trim() ?? '',
      attachmentUrl: (json['attachment_url'] as String?)?.trim() ?? '',
      metadata: json['metadata'],
      isRead: json['is_read'] == true || json['is_read'] == 1,
      readAt: (json['read_at'] as String?)?.trim() ?? '',
      createdAt: (json['created_at'] as String?)?.trim() ?? '',
      isMe: json['is_me'] == true,
    );
  }
}
