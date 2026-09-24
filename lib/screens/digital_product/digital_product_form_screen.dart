import 'package:material_ui/material_ui.dart';

import '../../models/master_models.dart';
import '../../services/common/master_service.dart';
import 'digital_product_media_upload_screen.dart';

class DigitalProductFormScreen extends StatefulWidget {
  final String productType;

  const DigitalProductFormScreen({super.key, this.productType = 'Produk'});

  @override
  State<DigitalProductFormScreen> createState() =>
      _DigitalProductFormScreenState();
}

class _DigitalProductFormScreenState extends State<DigitalProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  List<MasterSkema> _schemes = const [];
  MasterSkema? _selectedScheme;
  String _category = 'Software';
  String _serviceType = 'Online';
  bool _negotiable = false;
  bool _loadingSchemes = true;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadSchemes() async {
    final schemes = await MasterService.getMasterSkemaList();
    if (mounted) {
      setState(() {
        _schemes = schemes;
        _loadingSchemes = false;
      });
    }
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final scheme = _selectedScheme;
    if (scheme == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalProductMediaUploadScreen(
          productType: widget.productType,
          productName: _nameController.text.trim(),
          schemeId: scheme.id,
          category: _category,
          serviceType: _serviceType,
          description: _descriptionController.text.trim(),
          price: int.parse(_priceController.text.trim()),
          negotiable: _negotiable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Buat ${widget.productType}'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              children: [
                _label('Skema Sertifikasi'),
                _loadingSchemes
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<MasterSkema>(
                        initialValue: _selectedScheme,
                        isExpanded: true,
                        decoration: _decoration('Pilih skema'),
                        items: _schemes
                            .map(
                              (scheme) => DropdownMenuItem(
                                value: scheme,
                                child: Text(
                                  scheme.displayName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedScheme = value),
                        validator: (value) =>
                            value == null ? 'Skema wajib dipilih' : null,
                      ),
                const SizedBox(height: 14),
                _label('Nama ${widget.productType}'),
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration('Masukkan nama'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _label('Deskripsi'),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _decoration('Jelaskan produk/jasa'),
                ),
                const SizedBox(height: 14),
                _label('Kategori'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _decoration('Kategori'),
                  items: const ['Software', 'Ebook', 'Video', 'Template', 'Musik']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 14),
                _label('Tipe Layanan'),
                DropdownButtonFormField<String>(
                  initialValue: _serviceType,
                  decoration: _decoration('Tipe layanan'),
                  items: const ['Online', 'Offline', 'Hybrid']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _serviceType = value ?? _serviceType),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _card(
              children: [
                _label('Harga'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Masukkan harga dalam rupiah'),
                  validator: (value) {
                    final price = int.tryParse(value?.trim() ?? '');
                    return price == null || price < 0
                        ? 'Harga tidak valid'
                        : null;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Harga bisa nego'),
                  value: _negotiable,
                  onChanged: (value) => setState(() => _negotiable = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _next, child: const Text('Selanjutnya')),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      value,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
    ),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
