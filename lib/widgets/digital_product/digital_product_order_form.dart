import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../models/digital_product_models.dart';
import '../../models/digital_product_order_model.dart';
import '../../services/digital_product_cart_service.dart';

class DigitalProductOrderForm extends StatefulWidget {
  final DigitalProductItem product;
  final ValueChanged<DigitalProductOrder> onCreated;

  const DigitalProductOrderForm({
    super.key,
    required this.product,
    required this.onCreated,
  });

  @override
  State<DigitalProductOrderForm> createState() =>
      _DigitalProductOrderFormState();
}

class _DigitalProductOrderFormState extends State<DigitalProductOrderForm> {
  late final TextEditingController _priceController;
  final _notesController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product.priceValue > 0
          ? widget.product.priceValue.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final negotiated = widget.product.negotiable;
    final price = negotiated
        ? int.tryParse(_priceController.text)
        : widget.product.priceValue;
    if (price == null || (negotiated && price <= 0)) {
      setState(() => _error = 'Masukkan harga penawaran yang valid.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final order = await DigitalProductCartService.createOrderAndContract(
        product: widget.product,
        offeredPrice: price,
        isNegotiated: negotiated && price != widget.product.priceValue,
        notes: _notesController.text.trim(),
      );
      if (mounted) widget.onCreated(order);
    } catch (error) {
      if (mounted) {
        setState(() => _error = DigitalProductCartService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .88,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(LucideIcons.file_text, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Text(
                      product.negotiable ? 'Ajukan Pesanan' : 'Buat Pesanan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Harga katalog: ${product.price}${product.priceUnit}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                if (product.negotiable)
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Harga penawaran (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Harga tetap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(product.price),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan / ruang lingkup',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kirim pesanan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
