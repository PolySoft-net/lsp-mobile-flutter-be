import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_service.dart';

class DigitalProductOrderCard extends StatelessWidget {
  final DigitalProductOrder order;
  final String role;
  final bool responding;
  final ValueChanged<String> onRespond;
  final VoidCallback onOpenContract;

  const DigitalProductOrderCard({
    super.key,
    required this.order,
    required this.role,
    required this.responding,
    required this.onRespond,
    required this.onOpenContract,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: order.product.thumbnailUrl.isEmpty
                        ? const ColoredBox(
                            color: Color(0xFFF1F5F9),
                            child: Icon(LucideIcons.package),
                          )
                        : Image.network(
                            DigitalProductService.absoluteUrl(
                              order.product.thumbnailUrl,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(LucideIcons.package),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role == 'buyer'
                            ? 'Penjual: ${order.sellerName}'
                            : 'Pembeli: ${order.buyerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.formattedOfferedPrice,
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.statusLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenContract,
                icon: const Icon(LucideIcons.file_text, size: 15),
                label: const Text('Lihat kontrak'),
              ),
            ),
            if (order.canNegotiate) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: responding ? null : () => onRespond('accept'),
                    child: const Text('Terima'),
                  ),
                  TextButton(
                    onPressed: responding ? null : () => onRespond('reject'),
                    child: const Text('Tolak'),
                  ),
                  if (order.canCounter)
                    TextButton(
                      onPressed: responding ? null : () => onRespond('counter'),
                      child: const Text('Ajukan harga'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
