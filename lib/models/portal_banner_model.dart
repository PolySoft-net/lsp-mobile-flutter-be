class PortalBanner {
  final int id;
  final String portal;
  final String imageUrl;
  final String ownerId;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final String durationText;
  final bool isActive;
  final int remainingSeconds;

  const PortalBanner({
    this.id = 0,
    this.portal = '',
    this.imageUrl = '',
    this.ownerId = '',
    this.startsAt,
    this.expiresAt,
    this.durationText = '',
    this.isActive = false,
    this.remainingSeconds = 0,
  });

  factory PortalBanner.fromJson(Map<String, dynamic> json) => PortalBanner(
    id: int.tryParse('${json['id']}') ?? 0,
    portal: json['portal']?.toString() ?? '',
    imageUrl: json['image_url']?.toString() ?? '',
    ownerId: json['owner_id']?.toString() ?? '',
    startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '')?.toLocal(),
    expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? '')?.toLocal(),
    durationText: json['duration_text']?.toString() ?? '',
    isActive: json['is_active'] == true,
    remainingSeconds: int.tryParse('${json['remaining_seconds']}') ?? 0,
  );
}
