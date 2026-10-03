import 'package:material_ui/material_ui.dart';

class MenuProfilWidget extends StatelessWidget {
  final VoidCallback? onDataDiriTap;
  final VoidCallback? onPortofolioTap;
  final VoidCallback? onInstansiTap;
  final VoidCallback? onInstansiEditTap;
  final bool isInstansiExpanded;
  final String instansiType;
  final Map<String, String> instansiData;
  final VoidCallback? onKeamananTap;
  final VoidCallback? onReviewAppTap;
  final VoidCallback? onKeluarTap;
  const MenuProfilWidget({
    super.key,
    this.onDataDiriTap,
    this.onPortofolioTap,
    this.onInstansiTap,
    this.onInstansiEditTap,
    this.isInstansiExpanded = false,
    this.instansiType = 'Mahasiswa',
    this.instansiData = const {},
    this.onKeamananTap,
    this.onReviewAppTap,
    this.onKeluarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFF1F5F9),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Data Diri',
                  iconColor: const Color(0xFF378CE7),
                  onTap: onDataDiriTap,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildMenuItem(
                  icon: Icons.folder_shared_rounded,
                  title: 'Portofolio Saya',
                  iconColor: const Color(0xFF7C3AED),
                  onTap: onPortofolioTap,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildMenuItem(
                  icon: Icons.apartment_rounded,
                  title: 'Instansi / Lembaga',
                  iconColor: const Color(0xFF378CE7),
                  onTap: onInstansiTap,
                  trailing: Icon(
                    isInstansiExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: const Color(0xFF378CE7),
                    size: 22,
                  ),
                ),
                if (isInstansiExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Informasi Instansi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              GestureDetector(
                                onTap: onInstansiEditTap,
                                child: const Icon(
                                  Icons.edit_note_rounded,
                                  color: Color(0xFF378CE7),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          ...instansiData.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
                _buildMenuItem(
                  icon: Icons.shield_rounded,
                  title: 'Keamanan',
                  iconColor: const Color(0xFF378CE7),
                  onTap: onKeamananTap,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildMenuItem(
                  icon: Icons.star_rounded,
                  title: 'Beri Rating & Ulasan',
                  iconColor: const Color(0xFF378CE7),
                  onTap: onReviewAppTap,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Keluar',
                  iconColor: const Color(0xFFEF4444),
                  textColor: const Color(0xFFEF4444),
                  onTap: onKeluarTap,
                  showChevron: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    Color textColor = const Color(0xFF1E293B),
    required VoidCallback? onTap,
    bool showChevron = true,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      trailing: trailing ?? (showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: iconColor,
              size: 22,
            )
          : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
