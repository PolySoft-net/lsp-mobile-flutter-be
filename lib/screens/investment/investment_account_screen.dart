import 'package:material_ui/material_ui.dart';

import '../../services/auth/auth_repository.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

class InvestmentAccountScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToFavorites;

  const InvestmentAccountScreen({
    super.key,
    this.onBack,
    this.onNavigateToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUserInstance;
    final userName = user?.name.trim() ?? '';
    final userEmail = user?.email?.trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Akun',
              onBack: onBack ?? () => Navigator.maybePop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // User Profile Header Card (Image 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFEFF6FF),
                    backgroundImage: user?.fotoProfilUrl != null &&
                            user!.fotoProfilUrl!.isNotEmpty
                        ? NetworkImage(UrlHelper.resolveUrl(user.fotoProfilUrl))
                        : null,
                    onBackgroundImageError: user?.fotoProfilUrl != null &&
                            user!.fotoProfilUrl!.isNotEmpty
                        ? (_, _) {}
                        : null,
                    child: (user?.fotoProfilUrl == null ||
                            user!.fotoProfilUrl!.isEmpty)
                        ? const Icon(Icons.person,
                            color: Color(0xFF0066F6), size: 34)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Pengguna LSP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userEmail.isNotEmpty
                              ? userEmail
                              : 'investor@lspdigital.id',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu List Items (Image 3)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Informasi Akun',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Metode Pembayaran',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Transaksi',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorit',
                    onTap: onNavigateToFavorites,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & FAQ',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang LSP Teknologi Digital',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF64748B), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      color: Color(0xFFF1F5F9),
    );
  }
}
