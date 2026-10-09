import 'package:material_ui/material_ui.dart';

/// Tab Notifikasi di Career Expo
class CareerExpoNotifikasiTab extends StatelessWidget {
  const CareerExpoNotifikasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Undangan Wawancara!',
        'message':
            'Ruang Digital Studio telah meninjau portofolio Anda dan mengundang ke tahap wawancara.',
        'time': '2 jam yang lalu',
        'isUnread': true,
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF0066F6),
      },
      {
        'title': 'Lamaran Sedang Ditinjau',
        'message': 'PT. Kreatif Digital membuka berkas lamaran UI/UX Designer Anda.',
        'time': '1 hari yang lalu',
        'isUnread': false,
        'icon': Icons.mail_outline_rounded,
        'color': const Color(0xFF0D9488),
      },
      {
        'title': 'Lowongan Baru Cocok dengan Anda',
        'message':
            'Nusa Kreatif Teknologi membuka lowongan UI/UX Designer yang sesuai dengan sertifikasi Anda.',
        'time': '2 hari yang lalu',
        'isUnread': false,
        'icon': Icons.work_outline_rounded,
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isUnread = item['isUnread'] as bool;
          final color = item['color'] as Color;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['message'] as String,
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
    );
  }
}
