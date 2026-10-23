class PortalBanner {
  final int id;
  final String imageUrl;
  final String ownerId;
  final int durationValue;
  final String durationUnit;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool isActive;
  final int remainingSeconds;

  const PortalBanner({
    this.id = 0,
    this.imageUrl = '',
    this.ownerId = '',
    this.durationValue = 0,
    this.durationUnit = '',
    this.startsAt,
    this.expiresAt,
    this.isActive = false,
    this.remainingSeconds = 0,
  });

  factory PortalBanner.fromJson(Map<String, dynamic> json) => PortalBanner(
    id: int.tryParse('${json['id']}') ?? 0,
    imageUrl: json['image_url']?.toString() ?? '',
    ownerId: json['owner_id']?.toString() ?? '',
    durationValue: int.tryParse('${json['duration_value']}') ?? 0,
    durationUnit: json['duration_unit']?.toString() ?? '',
    startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? ''),
    expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    isActive: json['is_active'] == true,
    remainingSeconds: int.tryParse('${json['remaining_seconds']}') ?? 0,
  );
}
