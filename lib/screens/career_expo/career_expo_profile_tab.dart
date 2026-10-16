import 'package:material_ui/material_ui.dart';
import '../../models/auth_models.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../utils/url_helper.dart';
import '../dashboard/faq_screen.dart';
import '../profile/data_diri_screen.dart';
import '../profile/tentang_lsp_screen.dart';
import 'career_expo_favorit_screen.dart';
import 'career_expo_notification_settings_screen.dart';

/// Tab Profil Pelamar Career Expo — mengambil data profil user yang sedang login
class CareerExpoProfileTab extends StatefulWidget {
  final VoidCallback? onNavigateToLamaran;

  const CareerExpoProfileTab({
    super.key,
    this.onNavigateToLamaran,
  });

  @override
  State<CareerExpoProfileTab> createState() => _CareerExpoProfileTabState();
}

class _CareerExpoProfileTabState extends State<CareerExpoProfileTab> {
  AuthUser? _authUser;
  Map<String, dynamic>? _asesiProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _authUser = AuthRepository.currentUserInstance;
    if (mounted) setState(() {});

    try {
      final profile = await AsesiService.getProfile();
      if (mounted) {
        setState(() {
          _asesiProfile = profile;
        });
      }
    } catch (_) {}
  }

  String get _displayName {
    final asesiName = _asesiProfile?['nama_lengkap']?.toString().trim();
    if (asesiName != null && asesiName.isNotEmpty) return asesiName;
    final authName = _authUser?.name.trim();
    if (authName != null && authName.isNotEmpty) return authName;
    return 'Pengguna LSP';
  }

  String get _displayTitle {
    final pekerjaan = _asesiProfile?['nama_pekerjaan']?.toString().trim();
    if (pekerjaan != null && pekerjaan.isNotEmpty) return pekerjaan;
    final jabatan = _asesiProfile?['jabatan']?.toString().trim();
    if (jabatan != null && jabatan.isNotEmpty) return jabatan;
    final email = _authUser?.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'Talenta Digital';
  }

  String get _photoUrl {
    final rawPhoto = _asesiProfile?['foto_profil_url']?.toString() ??
        _authUser?.fotoProfilUrl ??
        _authUser?.fotoProfil ??
        '';
    return rawPhoto.isNotEmpty ? UrlHelper.resolveUrl(rawPhoto) : '';
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFBFDBFE),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 40,
        color: Color(0xFF1D4ED8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _photoUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0066F6), size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataDiriScreen()),
              ).then((_) => _loadProfile());
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: const Color(0xFF0066F6),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // Avatar
                    ClipOval(
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              width: 62,
                              height: 62,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                    const SizedBox(width: 14),
                    // Name and title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _displayTitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Edit Profil Button
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DataDiriScreen()),
                              ).then((_) => _loadProfile());
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 13, color: Color(0xFF0066F6)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit Profil',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0066F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu Items List (matching Screen 4)
              _buildProfileMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Riwayat Lamaran',
                onTap: widget.onNavigateToLamaran ?? () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'Favorit',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareerExpoFavoritScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Pengaturan Notifikasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareerExpoNotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Pusat Bantuan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FaqScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Tentang LSP Teknologi Digital',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TentangLspScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                onTap: () => UrlHelper.launchURL('https://mobile.lspdigital.id/privacy-policy'),
              ),
              _buildProfileMenuItem(
                icon: Icons.verified_user_outlined,
                title: 'Kebijakan Privasi',
                onTap: () => UrlHelper.launchURL('https://mobile.lspdigital.id/privacy-policy'),
              ),
              const SizedBox(height: 18),
              // Keluar Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    foregroundColor: const Color(0xFF0066F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFBFDBFE), width: 0.8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Color(0xFF0066F6)),
                      SizedBox(width: 8),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0066F6), size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
