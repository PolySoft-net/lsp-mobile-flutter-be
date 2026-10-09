import 'package:material_ui/material_ui.dart';

class _NotificationItemData {
  final String title;
  final String message;
  final String time;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _NotificationItemData({
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

/// Tab Notifikasi Career Expo sesuai Screen 3
class CareerExpoNotifikasiTab extends StatefulWidget {
  const CareerExpoNotifikasiTab({super.key});

  @override
  State<CareerExpoNotifikasiTab> createState() => _CareerExpoNotifikasiTabState();
}

class _CareerExpoNotifikasiTabState extends State<CareerExpoNotifikasiTab> {
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Lamaran', 'Pembaruan', 'Sistem'];

  final List<_NotificationItemData> _allNotifications = const [
    _NotificationItemData(
      title: 'Lamaran Anda diproses',
      message:
          'Posisi UI/UX Designer di PT. Kreatif Digital saat ini sedang dalam proses seleksi.',
      time: '2 jam lalu',
      category: 'Lamaran',
      icon: Icons.work_outline_rounded,
      iconColor: Color(0xFF0066F6),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    _NotificationItemData(
      title: 'Lowongan baru',
      message:
          'PT. Solusi Teknologi membuka lowongan untuk posisi Front End Developer.',
      time: '5 jam lalu',
      category: 'Pembaruan',
      icon: Icons.notifications_none_rounded,
      iconColor: Color(0xFF0284C7),
      iconBgColor: Color(0xFFE0F2FE),
    ),
    _NotificationItemData(
      title: 'Status lamaran',
      message:
          'Selamat! Anda diterima di PT. Inovasi Solusi Digital untuk posisi Web Developer.',
      time: '1 hari lalu',
      category: 'Lamaran',
      icon: Icons.check_circle_outline_rounded,
      iconColor: Color(0xFF16A34A),
      iconBgColor: Color(0xFFDCFCE7),
    ),
    _NotificationItemData(
      title: 'Tips Karier',
      message:
          'Simak tips membuat CV yang menarik untuk posisi di bidang teknologi.',
      time: '1 hari lalu',
      category: 'Sistem',
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFF0066F6),
      iconBgColor: Color(0xFFEFF6FF),
    ),
    _NotificationItemData(
      title: 'Pengingat',
      message:
          'Jangan lupa lengkapi profil kamu agar lebih mudah dilirik perusahaan.',
      time: '2 hari lalu',
      category: 'Sistem',
      icon: Icons.alarm_rounded,
      iconColor: Color(0xFF7C3AED),
      iconBgColor: Color(0xFFF3E8FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _allNotifications.where((n) {
      if (_selectedCategory == 'Semua') return true;
      return n.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Notifications List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Text(
                                  item.time,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
