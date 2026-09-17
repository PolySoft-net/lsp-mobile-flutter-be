import 'package:material_ui/material_ui.dart';

class PortofolioHighlightCard extends StatelessWidget {
  const PortofolioHighlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Portofolio Produk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 10),

          // Author / Creator Row
          Row(
            children: const [
              Icon(
                Icons.account_circle_outlined,
                size: 22,
                color: Color(0xFF334155),
              ),
              SizedBox(width: 8),
              Text(
                'Jendela_Website',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Showcase Images Row
          Row(
            children: [
              // Image 1: Retro Computer Illustration
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background accents
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF87171),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'JAN',
                              style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Monitor box
                        Container(
                          width: 86,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'PORTOFOLIO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(width: 24, height: 2, color: const Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Image 2: Creative Scrapbook Illustration
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 6,
                          left: 8,
                          child: Icon(Icons.star_rounded, size: 14, color: const Color(0xFFFDE047)),
                        ),
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE047),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Center banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF08A),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: const Text(
                            'PORTFOLIO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF1E293B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Dots indicator under first image
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: Row(
                  children: List.generate(4, (index) {
                    return Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Deskripsi
          const Text(
            'Deskripsi :',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekitar 2 bulan dan secara online atau daring...',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Kategori
          const Text(
            'Kategori :',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: const [
              _CategoryTag(tag: '#Online'),
              _CategoryTag(tag: '#Produk'),
              _CategoryTag(tag: '#Website'),
              _CategoryTag(tag: '#Design'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String tag;

  const _CategoryTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class PortofolioLainnyaCard extends StatelessWidget {
  final String title;
  final String price;
  final String type;
  final bool isFavorite;
  final VoidCallback? onTap;

  const PortofolioLainnyaCard({
    super.key,
    required this.title,
    this.price = 'Rp 400.000',
    this.type = '/Online',
    this.isFavorite = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // Two preview images
            Row(
              children: [
                // Image A: Retro Web UI Windows
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFB923C),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBAE6FD),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color(0xFF7DD3FC), width: 1.2),
                            ),
                            child: const Center(
                              child: Icon(Icons.sentiment_satisfied_alt_rounded, size: 22, color: Color(0xFF0369A1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Image B: Portfolio Typography + Adobe Icons
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'porto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'folio',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text('Ps', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text('Ai', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$price  $type',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (isFavorite)
                  const Icon(
                    Icons.favorite,
                    size: 13,
                    color: Color(0xFF0F172A),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

