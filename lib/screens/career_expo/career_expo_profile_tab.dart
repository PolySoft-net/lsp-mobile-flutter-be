import 'package:material_ui/material_ui.dart';
import '../../models/auth_models.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/auth/auth_repository.dart';
import '../dashboard/faq_screen.dart';
import 'career_expo_favorit_screen.dart';
import 'career_expo_notification_settings_screen.dart';
import 'career_expo_profile_edit_screen.dart';
/// Tab Profil Pelamar Career Expo — mengambil data profil user yang sedang login
class CareerExpoProfileTab extends StatefulWidget {
  final VoidCallback? onNavigateToLamaran;
  final VoidCallback? onNavigateToFavorit;

  const CareerExpoProfileTab({
    super.key,
    this.onNavigateToLamaran,
    this.onNavigateToFavorit,
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await AuthRepository.instance.logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  @override
  Widget build(BuildContext context) {

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
              // Top User Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_authUser?.email != null && _authUser!.email!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              _authUser!.email!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section title "Informasi"
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Information Menu Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuItemRow(
                      icon: Icons.account_circle_outlined,
                      title: 'Pengaturan Profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CareerExpoProfileEditScreen(),
                          ),
                        ).then((_) => _loadProfile());
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFCBD5E1)),
                    _buildMenuItemRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CareerExpoNotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFCBD5E1)),
                    _buildMenuItemRow(
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Koleksi',
                      onTap: () {
                        if (widget.onNavigateToFavorit != null) {
                          widget.onNavigateToFavorit!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CareerExpoFavoritScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFCBD5E1)),
                    _buildMenuItemRow(
                      icon: Icons.assignment_outlined,
                      title: 'Lamaran',
                      onTap: widget.onNavigateToLamaran ?? () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFCBD5E1)),
                    _buildMenuItemRow(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FaqScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Keluar Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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

  Widget _buildMenuItemRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F172A), size: 20),
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
          ],
        ),
      ),
    );
  }
}
