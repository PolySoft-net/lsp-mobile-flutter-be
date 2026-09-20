import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import 'digital_product_favorit_screen.dart';
import 'digital_product_pengaturan_profil_screen.dart';
import 'digital_product_produk_jasa_screen.dart';

class DigitalProductProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductProfileScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<DigitalProductProfileScreen> createState() =>
      _DigitalProductProfileScreenState();
}

class _DigitalProductProfileScreenState
    extends State<DigitalProductProfileScreen> {
  static const int _currentBottomNavIndex = 4;

  void _onBottomNavTap(int index) {
    if (index == 4) {
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context, index);
    } else if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu $title segera hadir'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    _buildProfileHeaderCard(),

                    const SizedBox(height: 12),

                    // Section: Informasi
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Menu Card
                    _buildMenuCard(),

                    const SizedBox(height: 16),

                    // Logout Button
                    _buildLogoutButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DigitalProductBottomBar(
        selectedIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                LucideIcons.sliders_horizontal,
                size: 20,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EDFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&auto=format&fit=crop&q=80',
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 68,
                height: 68,
                color: const Color(0xFF94A3B8),
                child: const Icon(Icons.pets, color: Colors.white, size: 34),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Jendela_Website',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Jendelawebsite@gmial.com',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.account_circle_outlined,
            title: 'Pengaturan Profil',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DigitalProductPengaturanProfilScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildMenuItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifikasi',
            onTap: () => _showComingSoon('Notifikasi'),
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildMenuItem(
            icon: Icons.bookmark_border_rounded,
            title: 'Koleksi',
            onTap: () async {
              final targetIndex = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (_) => const DigitalProductFavoritScreen(),
                ),
              );
              if (targetIndex != null && mounted) {
                _onBottomNavTap(targetIndex);
              }
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildMenuItem(
            icon: Icons.group_work_outlined,
            title: 'Produk/Jasa',
            onTap: () async {
              final targetIndex = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (_) => const DigitalProductProdukJasaScreen(),
                ),
              );
              if (targetIndex != null && mounted) {
                _onBottomNavTap(targetIndex);
              }
            },
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Bantuan',
            onTap: () => _showComingSoon('Bantuan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0F172A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil keluar dari sesi'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        icon: const Icon(
          LucideIcons.log_out,
          size: 16,
          color: Color(0xFF0F172A),
        ),
        label: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2E8F0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

