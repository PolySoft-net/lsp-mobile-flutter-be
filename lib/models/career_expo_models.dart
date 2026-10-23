import 'package:material_ui/material_ui.dart';

/// Model untuk lowongan pekerjaan di Career Expo
class CareerJobItem {
  final String id;
  final String title;
  final String companyName;
  final String companyCategory;
  final String employmentType; // Full Time, Magang, Kontrak, Part Time
  final String workplaceType; // Remote, On Site, Hybrid
  final String location;
  final int salaryMin;
  final int salaryMax;
  final String salaryPeriod;
  final String postedAt;
  final bool isBookmarked;
  final bool isPopular;
  final bool isApplied;
  final String applicationStatus;
  final String category; // Semua, Remote, On Site, Magang
  final String experience;
  final String education;
  final String aboutCompany;
  final List<String> jobDescription;
  final List<String> requirements;
  final List<String> benefits;

  /// Path gambar logo perusahaan hasil upload (JPG/PNG).
  final String companyLogo;
  final String filePdf;
  final String filePdfUrl;
  final String createdBy;
  final int? idSkema;
  final String shortDescription;
  final String statusLowongan;

  const CareerJobItem({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyCategory,
    required this.employmentType,
    required this.workplaceType,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    this.salaryPeriod = 'bulan',
    required this.postedAt,
    this.isBookmarked = false,
    this.isPopular = false,
    this.isApplied = false,
    this.applicationStatus = '',
    required this.category,
    required this.experience,
    required this.education,
    required this.aboutCompany,
    required this.jobDescription,
    required this.requirements,
    required this.benefits,
    this.companyLogo = '',
    this.filePdf = '',
    this.filePdfUrl = '',
    this.createdBy = '',
    this.idSkema,
    this.shortDescription = '',
    this.statusLowongan = 'publish',
  });
  /// Endpoint API: GET /api/career-expo/lowongan (list) dan /:id (detail).
  factory CareerJobItem.fromJson(Map<String, dynamic> json) {
    return CareerJobItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      companyCategory: json['company_category']?.toString() ?? '',
      employmentType: json['employment_type']?.toString() ?? 'Full Time',
      workplaceType: json['workplace_type']?.toString() ?? 'On Site',
      location: json['location']?.toString() ?? '',
      salaryMin: _asInt(json['salary_min']),
      salaryMax: _asInt(json['salary_max']),
      salaryPeriod: json['salary_period']?.toString() ?? 'bulan',
      postedAt: json['posted_label']?.toString() ?? '',
      isBookmarked: _asBool(json['is_bookmarked'] ?? json['is_favorite']),
      isApplied: _asBool(json['is_applied']),
      applicationStatus: json['application_status']?.toString() ?? '',
      isPopular: _asBool(json['is_popular']),
      category: json['category']?.toString() ?? 'Remote',
      experience: json['experience']?.toString() ?? '',
      education: json['education']?.toString() ?? '',
      aboutCompany: json['about_company']?.toString() ?? '',
      jobDescription: _asStringList(json['job_description']),
      requirements: _asStringList(json['requirements']),
      benefits: _asStringList(json['benefits']),
      companyLogo: json['company_logo']?.toString() ??
          json['logo_url']?.toString() ??
          json['logo']?.toString() ??
          json['company_logo_url']?.toString() ??
          '',
      filePdf: json['file_pdf']?.toString() ?? '',
      filePdfUrl: json['file_pdf_url']?.toString() ?? json['file_pdf']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      idSkema: json['id_skema'] != null ? int.tryParse(json['id_skema'].toString()) : null,
      shortDescription: json['short_description']?.toString() ?? '',
      statusLowongan: json['status_lowongan']?.toString() ?? 'publish',
    );
  }
  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    final raw = value?.toString().toLowerCase();
    return raw == 'true' || raw == '1';
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  CareerJobItem copyWith({
    String? id,
    String? title,
    String? companyName,
    String? companyCategory,
    String? employmentType,
    String? workplaceType,
    String? location,
    int? salaryMin,
    int? salaryMax,
    String? salaryPeriod,
    String? postedAt,
    bool? isBookmarked,
    bool? isPopular,
    bool? isApplied,
    String? category,
    String? experience,
    String? education,
    String? aboutCompany,
    List<String>? jobDescription,
    List<String>? requirements,
    List<String>? benefits,
    String? companyLogo,
    String? filePdf,
    String? filePdfUrl,
    String? createdBy,
    int? idSkema,
    String? shortDescription,
    String? statusLowongan,
  }) {
    return CareerJobItem(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyCategory: companyCategory ?? this.companyCategory,
      employmentType: employmentType ?? this.employmentType,
      workplaceType: workplaceType ?? this.workplaceType,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      postedAt: postedAt ?? this.postedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isPopular: isPopular ?? this.isPopular,
      isApplied: isApplied ?? this.isApplied,
      category: category ?? this.category,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      aboutCompany: aboutCompany ?? this.aboutCompany,
      jobDescription: jobDescription ?? this.jobDescription,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      companyLogo: companyLogo ?? this.companyLogo,
      filePdf: filePdf ?? this.filePdf,
      filePdfUrl: filePdfUrl ?? this.filePdfUrl,
      createdBy: createdBy ?? this.createdBy,
      idSkema: idSkema ?? this.idSkema,
      shortDescription: shortDescription ?? this.shortDescription,
      statusLowongan: statusLowongan ?? this.statusLowongan,
    );
  }
}

/// Model untuk status lamaran pekerjaan
class CareerApplicationItem {
  final String id;
  final CareerJobItem job;
  final DateTime appliedDate;
  final String status; // 'Terkirim', 'Diproses', 'Wawancara', 'Diterima', 'Ditolak'
  final String? note;
  final String fileCv;
  final String namaFileCv;

  /// Label siap tampil dari backend, mis. 'Dilamar 12 Jun 2025'.
  final String appliedLabel;

  const CareerApplicationItem({
    required this.id,
    required this.job,
    required this.appliedDate,
    required this.status,
    this.note,
    this.fileCv = '',
    this.namaFileCv = '',
    this.appliedLabel = '',
  });

  /// Endpoint API: GET /api/career-expo/lamaran.
  factory CareerApplicationItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['applied_at']?.toString() ?? '';
    DateTime parsed =
        DateTime.tryParse(rawDate) ??
        DateTime.tryParse(rawDate.replaceFirst(' ', 'T')) ??
        DateTime.now();
    return CareerApplicationItem(
      id: json['id']?.toString() ?? '',
      job: CareerJobItem.fromJson(
        Map<String, dynamic>.from(json['job'] as Map? ?? const {}),
      ),
      appliedDate: parsed,
      status: json['status']?.toString() ?? 'Terkirim',
      note: json['note']?.toString(),
      fileCv: json['file_cv']?.toString() ?? '',
      namaFileCv: json['nama_file_cv']?.toString() ?? '',
      appliedLabel: json['applied_label']?.toString() ?? '',
    );
  }
}
/// Model untuk notifikasi di Career Expo
class CareerNotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'Lamaran', 'Pembaruan', 'Sistem'
  final String type;
  final String? lowonganId;
  final String? lamaranId;
  final bool isRead;
  final String createdAt;

  const CareerNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.type = 'general',
    this.lowonganId,
    this.lamaranId,
    this.isRead = false,
    this.createdAt = '',
  });

  factory CareerNotificationItem.fromJson(Map<String, dynamic> json) {
    return CareerNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Lamaran',
      type: json['type']?.toString() ?? 'general',
      lowonganId: json['lowongan_id']?.toString(),
      lamaranId: json['lamaran_id']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read']?.toString() == 'true',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  IconData get icon {
    if (category == 'Lamaran') {
      if (type.contains('diterima') || message.toLowerCase().contains('diterima')) {
        return Icons.check_circle_outline_rounded;
      }
      return Icons.work_outline_rounded;
    }
    if (category == 'Pembaruan') {
      return Icons.notifications_none_rounded;
    }
    if (type.contains('pengingat') || title.toLowerCase().contains('pengingat')) {
      return Icons.alarm_rounded;
    }
    return Icons.lightbulb_outline_rounded;
  }

  Color get iconColor {
    if (category == 'Lamaran') {
      if (type.contains('diterima') || message.toLowerCase().contains('diterima')) {
        return const Color(0xFF16A34A);
      }
      return const Color(0xFF0066F6);
    }
    if (category == 'Pembaruan') {
      return const Color(0xFF0284C7);
    }
    if (type.contains('pengingat') || title.toLowerCase().contains('pengingat')) {
      return const Color(0xFF7C3AED);
    }
    return const Color(0xFF0066F6);
  }

  Color get iconBgColor {
    if (category == 'Lamaran') {
      if (type.contains('diterima') || message.toLowerCase().contains('diterima')) {
        return const Color(0xFFDCFCE7);
      }
      return const Color(0xFFEFF6FF);
    }
    if (category == 'Pembaruan') {
      return const Color(0xFFE0F2FE);
    }
    if (type.contains('pengingat') || title.toLowerCase().contains('pengingat')) {
      return const Color(0xFFF3E8FF);
    }
    return const Color(0xFFEFF6FF);
  }
}

/// Model untuk opsi filter dinamis dari API Career Expo
class CareerFilterOptions {
  final List<String> employmentTypes;
  final List<String> workplaceTypes;
  final List<String> locations;

  static const List<String> defaultEmploymentTypes = [
    'Semua',
    'Full Time',
    'Magang',
    'Kontrak',
    'Part Time',
  ];
  static const List<String> defaultWorkplaceTypes = [
    'Semua',
    'Remote',
    'On Site',
    'Hybrid',
  ];
  static const List<String> defaultLocations = [
    'Semua',
    'Jakarta',
    'Yogyakarta',
    'Bandung',
    'Surabaya',
  ];

  const CareerFilterOptions({
    this.employmentTypes = defaultEmploymentTypes,
    this.workplaceTypes = defaultWorkplaceTypes,
    this.locations = defaultLocations,
  });

  factory CareerFilterOptions.fromJson(Map<String, dynamic> json) {
    return CareerFilterOptions(
      employmentTypes: _parseList(json['employment_types'], defaultEmploymentTypes),
      workplaceTypes: _parseList(json['workplace_types'], defaultWorkplaceTypes),
      locations: _parseList(json['locations'], defaultLocations),
    );
  }

  static List<String> _parseList(dynamic raw, List<String> fallback) {
    if (raw is List && raw.isNotEmpty) {
      final list = raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      if (!list.contains('Semua')) {
        list.insert(0, 'Semua');
      }
      return list.isNotEmpty ? list : fallback;
    }
    return fallback;
  }
}
