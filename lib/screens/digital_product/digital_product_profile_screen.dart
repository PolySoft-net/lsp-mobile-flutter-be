import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/auth_models.dart';
import '../../models/digital_product_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/auth/token_storage.dart';
import '../../services/digital_product_service.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/notification_panel.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import '../profile/tiket_bantuan_screen.dart';
import 'digital_product_favorit_screen.dart';
import 'digital_product_pengaturan_profil_screen.dart';
import 'digital_product_produk_jasa_screen.dart';

class DigitalProductProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductProfileScreen({super.key, this.onBackToHome});

  @override
  State<DigitalProductProfileScreen> createState() =>
      _DigitalProductProfileScreenState();
}

class _DigitalProductProfileScreenState
    extends State<DigitalProductProfileScreen> {
  DigitalProductProfile? _profile;
  AuthUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = AuthRepository.currentUserInstance;
    _load();
  }

  Future<void> _load() async {
    final cachedUser = AuthRepository.currentUserInstance;
    if (cachedUser != null && mounted) {
      setState(() => _user = cachedUser);
    }

    try {
      final profile = await DigitalProductService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}

    try {
      final user = await TokenStorage.instance.getUserProfile();
      if (mounted && user != null) setState(() => _user = user);
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _handleKeluar() {
    // Balik ke Aplikasi LSP (bukan keluar dari akun)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      widget.onBackToHome?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = _profile?.seller ?? DigitalProductSeller.empty;
    final name = seller.name.trim().isNotEmpty
        ? seller.name
        : (_user?.name.trim().isNotEmpty == true
            ? _user!.name
            : 'Jendela_Website');
    final email = seller.email.trim().isNotEmpty
        ? seller.email
        : (_user?.email?.trim().isNotEmpty == true
            ? _user!.email!
            : 'Jendelawebsite@gmial.com');
    final rawPhoto = seller.profilePhoto.trim().isNotEmpty
        ? seller.profilePhoto.trim()
        : (_user?.fotoProfilUrl?.trim().isNotEmpty == true
            ? _user!.fotoProfilUrl!.trim()
            : (_user?.fotoProfil?.trim().isNotEmpty == true
                ? _user!.fotoProfil!.trim()
                : ''));
    final photoUrl = rawPhoto.isNotEmpty ? UrlHelper.resolveUrl(rawPhoto) : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileCard(name, email, photoUrl),
                            const SizedBox(height: 20),
                            const Text(
                              'Informasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildMenuCard(),
                            const SizedBox(height: 24),
                            _buildKeluarButton(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                widget.onBackToHome?.call();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    LucideIcons.chevron_left,
                    size: 22,
                    color: Color(0xFF0F172A),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.sliders_horizontal,
              size: 22,
              color: Color(0xFF0F172A),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String email, String photoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFDFEDFA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipOval(
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFF94A3B8),
                      child: const Icon(
                        LucideIcons.user,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF94A3B8),
                    child: const Icon(
                      LucideIcons.user,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: const Icon(
              LucideIcons.circle_user_round,
              size: 22,
              color: Color(0xFF0F172A),
            ),
            title: 'Pengaturan Profil',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DigitalProductPengaturanProfilScreen(),
                ),
              );
              if (mounted) _load();
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          _menuItem(
            icon: const Icon(
              LucideIcons.bell,
              size: 22,
              color: Color(0xFF0F172A),
            ),
            title: 'Notifikasi',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const NotificationPanel(),
              );
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          _menuItem(
            icon: const Icon(
              Icons.bookmark,
              size: 22,
              color: Color(0xFF0F172A),
            ),
            title: 'Koleksi',
            onTap: () => Navigator.of(context).push(
              FadePageRoute(page: const DigitalProductFavoritScreen()),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          _menuItem(
            icon: _buildProdukJasaIcon(),
            title: 'Produk/Jasa',
            onTap: () => Navigator.of(context).push(
              FadePageRoute(page: const DigitalProductProdukJasaScreen()),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          _menuItem(
            icon: const Icon(
              LucideIcons.settings,
              size: 22,
              color: Color(0xFF0F172A),
            ),
            title: 'Bantuan',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TiketBantuanScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukJasaIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.person,
              size: 20,
              color: Color(0xFF0F172A),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 0,
            child: Icon(
              Icons.shopping_bag,
              size: 11,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Center(child: icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevron_right,
              size: 18,
              color: Color(0xFF0F172A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeluarButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleKeluar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              LucideIcons.log_out,
              size: 20,
              color: Color(0xFF0F172A),
            ),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
