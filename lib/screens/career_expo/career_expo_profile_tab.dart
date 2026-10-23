import 'package:material_ui/material_ui.dart';
import '../../models/auth_models.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../utils/url_helper.dart';
import '../dashboard/faq_screen.dart';
import 'asesor_lowongan_screen.dart';
import 'career_expo_favorit_screen.dart';
import 'career_expo_notification_settings_screen.dart';
import 'career_expo_profile_edit_screen.dart';
import 'portal_banner_manage_screen.dart';
/// Tab Profil portal — asesi melihat profil pelamar, asesor melihat menu kelola.
class CareerExpoProfileTab extends StatefulWidget {
  final VoidCallback? onNavigateToLamaran;
  final VoidCallback? onNavigateToFavorit;

  /// True saat dipakai di Magang Hub, sehingga menu kelola mengarah ke portal magang.
  final bool isMagang;

  /// Dipanggil setelah layar kelola (lowongan/banner) ditutup agar portal
  /// menyegarkan daftar publik dan daftar milik asesor.
  final VoidCallback? onPortalDataChanged;

  const CareerExpoProfileTab({
    super.key,
    this.onNavigateToLamaran,
    this.onNavigateToFavorit,
    this.isMagang = false,
    this.onPortalDataChanged,
  });

  @override
  State<CareerExpoProfileTab> createState() => _CareerExpoProfileTabState();
}

class _CareerExpoProfileTabState extends State<CareerExpoProfileTab> {
  AuthUser? _authUser;
  Map<String, dynamic>? _asesiProfile;

  bool get _isAsesor =>
      AuthRepository.currentUserInstance?.isAsesorOrAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _authUser = AuthRepository.currentUserInstance;
    if (mounted) setState(() {});

    // Asesor tidak punya profil asesi; jangan panggil endpoint asesi.
    if (_isAsesor) return;

    try {
      final profile = await AsesiService.getProfile();
      if (mounted) {
        setState(() {
          _asesiProfile = profile;
        });
      }
    } catch (_) {}
  }

  Future<void> _openKelola(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (!mounted) return;
    widget.onPortalDataChanged?.call();
  }

  String get _displayName {
    final asesiName = _asesiProfile?['nama_lengkap']?.toString().trim();
    if (asesiName != null && asesiName.isNotEmpty) return asesiName;
    final authName = _authUser?.name.trim();
    if (authName != null && authName.isNotEmpty) return authName;
    return 'Pengguna LSP';
  }

  String get _photoUrl {
    final raw = _asesiProfile?['foto_profil_url']?.toString() ??
        _authUser?.fotoProfilUrl ??
        _authUser?.fotoProfil ??
        '';
    return raw.isNotEmpty ? UrlHelper.resolveUrl(raw) : '';
  }

  void _handleKeluar() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
                      clipBehavior: Clip.antiAlias,
                      child: _photoUrl.isNotEmpty
                          ? Image.network(
                              _photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.person,
                                size: 34,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
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

              // Section title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _isAsesor ? 'Kelola Portal' : 'Informasi',
                  style: const TextStyle(
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
                    if (_isAsesor)
                      ..._buildProviderMenuRows()
                    else ...[
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Keluar Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _handleKeluar,
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

  /// Menu khusus asesor: kelola lowongan/info magang dan banner portalnya.
  List<Widget> _buildProviderMenuRows() {
    final rows = <Widget>[
      _buildMenuItemRow(
        icon: Icons.business_center_outlined,
        title: widget.isMagang ? 'Kelola Info Magang' : 'Kelola Lowongan Kerja',
        onTap: () => _openKelola(AsesorLowonganScreen(isMagang: widget.isMagang)),
      ),
      _buildMenuItemRow(
        icon: Icons.image_outlined,
        title: 'Kelola Banner',
        onTap: () => _openKelola(PortalBannerManageScreen(isMagang: widget.isMagang)),
      ),
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
    ];
    final separated = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        separated.add(const Divider(height: 1, color: Color(0xFFCBD5E1)));
      }
      separated.add(rows[i]);
    }
    return separated;
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
