import '../utils/json_helper.dart';

class InvestmentStartupItem {
  final String id;
  final int userId;
  final String nama;
  final String tagline;
  final String kategori;
  final String stage;
  final String lokasi;
  final String logoUrl;
  final String bannerUrl;
  final int targetFunding;
  final int collectedFunding;
  final int minimumTicket;
  final int valuation;
  final double equityOffered;
  final String deskripsi;
  final String traction;
  final String founderName;
  final String founderRole;
  final String founderPhoto;
  final String founderEmail;
  final String founderPhone;
  final String pitchDeckUrl;
  final String websiteUrl;
  final bool isVerified;
  final String status;
  final String createdAt;
  final bool isFavorite;

  const InvestmentStartupItem({
    required this.id,
    this.userId = 0,
    required this.nama,
    this.tagline = '',
    this.kategori = 'Teknologi',
    this.stage = 'Seed',
    this.lokasi = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.targetFunding = 0,
    this.collectedFunding = 0,
    this.minimumTicket = 0,
    this.valuation = 0,
    this.equityOffered = 0.0,
    this.deskripsi = '',
    this.traction = '',
    this.founderName = '',
    this.founderRole = 'Founder & CEO',
    this.founderPhoto = '',
    this.founderEmail = '',
    this.founderPhone = '',
    this.pitchDeckUrl = '',
    this.websiteUrl = '',
    this.isVerified = true,
    this.status = 'active',
    this.createdAt = '',
    this.isFavorite = false,
  });

  factory InvestmentStartupItem.fromJson(Map<String, dynamic> json) {
    return InvestmentStartupItem(
      id: JsonHelper.asString(json['id']),
      userId: JsonHelper.asInt(json['user_id']),
      nama: JsonHelper.asString(json['nama'], 'Startup'),
      tagline: JsonHelper.asString(json['tagline']),
      kategori: JsonHelper.asString(json['kategori'], 'Teknologi'),
      stage: JsonHelper.asString(json['stage'], 'Seed'),
      lokasi: JsonHelper.asString(json['lokasi']),
      logoUrl: JsonHelper.asString(json['logo_url']),
      bannerUrl: JsonHelper.asString(json['banner_url']),
      targetFunding: JsonHelper.asInt(json['target_funding']),
      collectedFunding: JsonHelper.asInt(json['collected_funding']),
      minimumTicket: JsonHelper.asInt(json['minimum_ticket']),
      valuation: JsonHelper.asInt(json['valuation']),
      equityOffered: JsonHelper.asDouble(json['equity_offered']),
      deskripsi: JsonHelper.asString(json['deskripsi']),
      traction: JsonHelper.asString(json['traction']),
      founderName: JsonHelper.asString(json['founder_name']),
      founderRole: JsonHelper.asString(json['founder_role'], 'Founder & CEO'),
      founderPhoto: JsonHelper.asString(json['founder_photo']),
      founderEmail: JsonHelper.asString(json['founder_email']),
      founderPhone: JsonHelper.asString(json['founder_phone']),
      pitchDeckUrl: JsonHelper.asString(json['pitch_deck_url']),
      websiteUrl: JsonHelper.asString(json['website_url']),
      isVerified: JsonHelper.asBool(json['is_verified'], true),
      status: JsonHelper.asString(json['status'], 'active'),
      createdAt: JsonHelper.asString(json['created_at']),
      isFavorite: JsonHelper.asBool(json['is_favorite']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'tagline': tagline,
      'kategori': kategori,
      'stage': stage,
      'lokasi': lokasi,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'target_funding': targetFunding,
      'collected_funding': collectedFunding,
      'minimum_ticket': minimumTicket,
      'valuation': valuation,
      'equity_offered': equityOffered,
      'deskripsi': deskripsi,
      'traction': traction,
      'founder_name': founderName,
      'founder_role': founderRole,
      'founder_photo': founderPhoto,
      'founder_email': founderEmail,
      'founder_phone': founderPhone,
      'pitch_deck_url': pitchDeckUrl,
      'website_url': websiteUrl,
      'is_verified': isVerified ? 1 : 0,
      'status': status,
      'created_at': createdAt,
      'is_favorite': isFavorite,
    };
  }

  InvestmentStartupItem copyWith({
    String? id,
    int? userId,
    String? nama,
    String? tagline,
    String? kategori,
    String? stage,
    String? lokasi,
    String? logoUrl,
    String? bannerUrl,
    int? targetFunding,
    int? collectedFunding,
    int? minimumTicket,
    int? valuation,
    double? equityOffered,
    String? deskripsi,
    String? traction,
    String? founderName,
    String? founderRole,
    String? founderPhoto,
    String? founderEmail,
    String? founderPhone,
    String? pitchDeckUrl,
    String? websiteUrl,
    bool? isVerified,
    String? status,
    String? createdAt,
    bool? isFavorite,
  }) {
    return InvestmentStartupItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      tagline: tagline ?? this.tagline,
      kategori: kategori ?? this.kategori,
      stage: stage ?? this.stage,
      lokasi: lokasi ?? this.lokasi,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      targetFunding: targetFunding ?? this.targetFunding,
      collectedFunding: collectedFunding ?? this.collectedFunding,
      minimumTicket: minimumTicket ?? this.minimumTicket,
      valuation: valuation ?? this.valuation,
      equityOffered: equityOffered ?? this.equityOffered,
      deskripsi: deskripsi ?? this.deskripsi,
      traction: traction ?? this.traction,
      founderName: founderName ?? this.founderName,
      founderRole: founderRole ?? this.founderRole,
      founderPhoto: founderPhoto ?? this.founderPhoto,
      founderEmail: founderEmail ?? this.founderEmail,
      founderPhone: founderPhone ?? this.founderPhone,
      pitchDeckUrl: pitchDeckUrl ?? this.pitchDeckUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class InvestmentInterestSubmission {
  final int startupId;
  final String investorName;
  final String investorEmail;
  final String investorPhone;
  final int offeredAmount;
  final String notes;

  const InvestmentInterestSubmission({
    required this.startupId,
    required this.investorName,
    this.investorEmail = '',
    this.investorPhone = '',
    this.offeredAmount = 0,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'startup_id': startupId,
      'investor_name': investorName,
      'investor_email': investorEmail,
      'investor_phone': investorPhone,
      'offered_amount': offeredAmount,
      'notes': notes,
    };
  }
}

class InvestmentStats {
  final int totalStartups;
  final int totalFunding;
  final int activeSectors;

  const InvestmentStats({
    this.totalStartups = 0,
    this.totalFunding = 0,
    this.activeSectors = 0,
  });

  factory InvestmentStats.fromJson(Map<String, dynamic> json) {
    return InvestmentStats(
      totalStartups: JsonHelper.asInt(json['total_startups']),
      totalFunding: JsonHelper.asInt(json['total_funding']),
      activeSectors: JsonHelper.asInt(json['active_sectors']),
    );
  }
}
