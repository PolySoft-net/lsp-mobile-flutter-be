import 'package:material_ui/material_ui.dart';

import '../../services/auth/auth_repository.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../dashboard/faq_screen.dart';
import '../dashboard/tentang_sistem_screen.dart';
import '../profile/data_diri_screen.dart';

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DataDiriScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Metode Pembayaran',
                    onTap: () => _showInfoSheet(
                      context,
                      'Metode Pembayaran',
                      'Metode pembayaran aktif mencakup Transfer Bank, E-wallet (GoPay, OVO, DANA), dan Virtual Account (BCA, BNI, Mandiri, BRI).',
                      Icons.credit_card_rounded,
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Transaksi',
                    onTap: () => _showInfoSheet(
                      context,
                      'Riwayat Transaksi',
                      'Seluruh riwayat pembayaran dan komitmen investasi Anda pada startup lokal tercatat aman di sistem LSP Digital.',
                      Icons.receipt_long_rounded,
                    ),
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
                    onTap: () => _showInfoSheet(
                      context,
                      'Pengaturan Portal',
                      'Pengaturan notifikasi, preferensi sektor investasi, dan keamanan akun dapat disesuaikan pada pembaruan mendatang.',
                      Icons.settings_outlined,
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & FAQ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FaqScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang LSP Teknologi Digital',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TentangSistemScreen(),
                        ),
                      );
                    },
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
  void _showInfoSheet(BuildContext context, String title, String message, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.paddingOf(ctx).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0066F6), size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
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
