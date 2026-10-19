class AuthUser {
  AuthUser({
    required this.id,
    required this.account,
    required this.name,
    required this.role,
    required this.roles,
    this.email,
    this.fotoProfil,
    this.fotoProfilUrl,
  });

  final String id;
  final String account;
  final String name;
  final String role;
  final List<String> roles;
  final String? email;
  final String? fotoProfil;
  final String? fotoProfilUrl;

  /// Deteksi asesi kanonikal. Backend mengirim `role` tunggal berdasarkan
  /// prioritas admin > asesor > asesi (`auth_shared.go:mapLegacyRoles`), jadi
  /// user yang punya role ganda (mis. Pemegang Sertifikat + Asesor) akan
  /// menerima `role: "asesor"` walaupun dia juga asesi. Mengecek `role` saja
  /// membuat fitur khusus asesi (Titik Koordinat, Status Pencari Kerja) hilang
  /// untuk user tersebut, karena itu keanggotaan `roles[]` WAJIB ikut dicek.
  bool get isAsesi => role == 'asesi' || roles.contains('asesi');
  bool get isAsesorOrAdmin {
    final r = role.toLowerCase();
    if (r == 'asesor' || r == 'admin' || r == 'pengelola' || r == 'superadmin') return true;
    return roles.any((e) {
      final el = e.toLowerCase();
      return el == 'asesor' || el == 'admin' || el == 'pengelola' || el == 'superadmin';
    });
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      account: json['account'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
      fotoProfil: json['foto_profil'] as String?,
      fotoProfilUrl: json['foto_profil_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'name': name,
      'role': role,
      'roles': roles,
      'email': email,
      'foto_profil': fotoProfil,
      'foto_profil_url': fotoProfilUrl,
    };
  }

  AuthUser copyWith({
    String? id,
    String? account,
    String? name,
    String? role,
    List<String>? roles,
    String? email,
    String? fotoProfil,
    String? fotoProfilUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      account: account ?? this.account,
      name: name ?? this.name,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      email: email ?? this.email,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      fotoProfilUrl: fotoProfilUrl ?? this.fotoProfilUrl,
    );
  }
}

class LoginResult {
  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class LoginSession {
  final int id;
  final String platform;
  final String deviceHint;
  final String createdAt;
  final String? updatedAt;
  final bool active;

  LoginSession({
    required this.id,
    required this.platform,
    required this.deviceHint,
    required this.createdAt,
    this.updatedAt,
    required this.active,
  });

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    return LoginSession(
      id: json['id'] as int? ?? 0,
      platform: json['platform'] as String? ?? json['device_name'] as String? ?? '',
      deviceHint: json['device_hint'] as String? ?? json['device_name'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? json['last_active'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? json['last_active'] as String?,
      active: (json['active'] as bool?) ?? (json['is_current'] as bool?) ?? false,
    );
  }
}
