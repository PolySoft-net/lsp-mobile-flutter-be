import 'package:material_ui/material_ui.dart';

class DigitalProductBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const DigitalProductBanner({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE0EDFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Left thumbnail: IoT illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 120,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5C0DC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background doodle accents
                      Positioned(
                        top: 6,
                        left: 8,
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Icon(
                          Icons.cloud_outlined,
                          size: 14,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Icon(
                          Icons.laptop_chromebook_rounded,
                          size: 14,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Icon(
                          Icons.build_outlined,
                          size: 14,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                        ),
                      ),
                      // Center Title & Icon
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'INTERNET',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'OF',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              SizedBox(width: 2),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'THINGS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Right Text
              Expanded(
                child: const Text(
                  'Temukan Produk dan Jasa yang Sesuai Denganmu',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

