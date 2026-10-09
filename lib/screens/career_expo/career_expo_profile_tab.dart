import 'package:material_ui/material_ui.dart';

/// Tab Profil Pelamar Career Expo sesuai Screen 4
class CareerExpoProfileTab extends StatelessWidget {
  final VoidCallback? onNavigateToLamaran;

  const CareerExpoProfileTab({
    super.key,
    this.onNavigateToLamaran,
  });

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0066F6), size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Pengaturan Profil...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar silhouette
                  Container(
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
                  ),
                  const SizedBox(width: 14),
                  // Name and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nurmalia Dwi Cahyani',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'UI/UX Designer',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Edit Profil Button
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Membuka Edit Profil...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
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
              onTap: onNavigateToLamaran ?? () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.favorite_border_rounded,
              title: 'Favorit',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Pengaturan Notifikasi',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Pusat Bantuan',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'Tentang LSP Teknologi Digital',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Syarat & Ketentuan',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Kebijakan Privasi',
              onTap: () {},
            ),
            const SizedBox(height: 18),
            // Keluar Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Keluar'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
                        color: Color(0xFF0066F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
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
