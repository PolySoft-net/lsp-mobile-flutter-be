import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_cart_service.dart';

class DigitalProductContractViewer extends StatefulWidget {
  final String orderId;

  const DigitalProductContractViewer({super.key, required this.orderId});

  static Future<void> show(BuildContext context, {required String orderId}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => DigitalProductContractViewer(orderId: orderId),
      );

  @override
  State<DigitalProductContractViewer> createState() =>
      _DigitalProductContractViewerState();
}

class _DigitalProductContractViewerState
    extends State<DigitalProductContractViewer> {
  DigitalProductContract? _contract;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final contract = await DigitalProductCartService.getContract(
        widget.orderId,
      );
      if (mounted) setState(() => _contract = contract);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contract = _contract;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.file_text, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kontrak pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DigitalProductCartService.errorMessage(_error!),
                          textAlign: TextAlign.center,
                        ),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (contract == null)
                const Expanded(
                  child: Center(child: Text('Kontrak tidak tersedia.')),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      _detail('Nomor pesanan', contract.orderNumber),
                      _detail('Nomor kontrak', contract.contractNumber),
                      _detail('Produk / jasa', contract.productTitle),
                      _detail('Pembeli', contract.buyer.name),
                      _detail('Penjual', contract.seller.name),
                      _detail(
                        contract.isSignedByBuyer && contract.isSignedBySeller
                            ? 'Harga disepakati'
                            : 'Nilai penawaran / kontrak',
                        contract.formattedAgreedPrice,
                      ),
                      _detail('Tanggal kontrak', contract.contractDate),
                      _detail('Status', contract.statusLabel),
                      _detail(
                        'Tanda tangan pembeli',
                        contract.isSignedByBuyer
                            ? 'Ditandatangani'
                            : 'Belum ditandatangani',
                      ),
                      _detail(
                        'Tanda tangan penjual',
                        contract.isSignedBySeller
                            ? 'Ditandatangani'
                            : 'Belum ditandatangani',
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'Ketentuan kontrak',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SelectableText(
                        contract.contractTerms.isEmpty
                            ? 'Ketentuan kontrak belum dicantumkan oleh server.'
                            : contract.contractTerms,
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
