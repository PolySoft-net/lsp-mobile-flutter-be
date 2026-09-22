import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';

class DigitalProductPortofolioScreen extends StatelessWidget {
  final List<DigitalProductMedia> media;
  final String sellerName;
  final String sellerPhone;

  const DigitalProductPortofolioScreen({
    super.key,
    required this.media,
    required this.sellerName,
    required this.sellerPhone,
  });

  Future<void> _contactSeller(BuildContext context) async {
    final phone = sellerPhone.trim();
    if (phone.isEmpty || !await launchUrl(Uri(scheme: 'tel', path: phone))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor penjual belum tersedia')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portofolio Produk'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            sellerName.isEmpty
                ? 'Portofolio Penjual'
                : 'Portofolio $sellerName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (media.isEmpty)
            const Center(child: Text('Belum ada portofolio yang diunggah'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: media.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 150,
              ),
              itemBuilder: (context, index) {
                final item = media[index];
                final isPdf = item.fileName.toLowerCase().endsWith('.pdf');
                return InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(DigitalProductService.absoluteUrl(item.url)),
                    mode: LaunchMode.externalApplication,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                            child: isPdf
                                ? const ColoredBox(
                                    color: Color(0xFFF1F5F9),
                                    child: Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 42,
                                    ),
                                  )
                                : Image.network(
                                    DigitalProductService.absoluteUrl(item.url),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const ColoredBox(
                                      color: Color(0xFFF1F5F9),
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            item.fileName.isEmpty
                                ? 'Portofolio ${index + 1}'
                                : item.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _contactSeller(context),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Hubungi Penjual'),
          ),
        ],
      ),
    );
  }
}
