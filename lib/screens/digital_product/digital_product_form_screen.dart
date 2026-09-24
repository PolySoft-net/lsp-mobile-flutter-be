import 'package:material_ui/material_ui.dart';

import '../../models/master_models.dart';
import '../../services/common/master_service.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
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
  String _category = DigitalProductCategoryChips.categories.first;
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
        if (schemes.isNotEmpty) {
          _selectedScheme = schemes.first;
        }
        _loadingSchemes = false;
      });
    }
  }

  void _showCategoryPicker() {
    final categories = DigitalProductCategoryChips.categories;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pilih Kategori',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: categories.map((cat) {
                        final isSelected =
                            cat.toLowerCase() == _category.toLowerCase();
                        return ListTile(
                          dense: true,
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF2563EB),
                                  size: 18,
                                )
                              : null,
                          onTap: () {
                            setState(() => _category = cat);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTypePicker() {
    final types = const ['Online', 'Offline', 'Hybrid'];
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih Type Produk',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...types.map((type) {
                final isSelected =
                    type.toLowerCase() == _serviceType.toLowerCase();
                return ListTile(
                  dense: true,
                  title: Text(
                    type,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF2563EB), size: 18)
                      : null,
                  onTap: () {
                    setState(() => _serviceType = type);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final scheme = _selectedScheme;
    if (scheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih skema sertifikasi')),
      );
      return;
    }
    final rawPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(rawPrice) ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalProductMediaUploadScreen(
          productType: widget.productType,
          productName: _nameController.text.trim(),
          schemeId: scheme.id,
          category: _category,
          serviceType: _serviceType,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : _nameController.text.trim(),
          price: price,
          negotiable: _negotiable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buat ${widget.productType}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Section 1: Nama Produk & Kategori
                    _buildFormCard(
                      children: [
                        _label('Nama ${widget.productType}'),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            'Masukkan nama ${widget.productType.toLowerCase()}',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 14),

                        // Skema Sertifikasi
                        _label('Skema Sertifikasi'),
                        if (_loadingSchemes)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(),
                          )
                        else
                          DropdownButtonFormField<MasterSkema>(
                            initialValue: _selectedScheme,
                            isExpanded: true,
                            decoration: _inputDecoration('Pilih skema sertifikasi'),
                            items: _schemes
                                .map(
                                  (scheme) => DropdownMenuItem(
                                    value: scheme,
                                    child: Text(
                                      scheme.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
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

                        // Kategori Picker
                        _label('Kategori'),
                        _buildSelector(
                          value: _category,
                          onTap: _showCategoryPicker,
                        ),
                        const SizedBox(height: 8),
                        // Category tag chips
                        Row(
                          children: [
                            _buildTagChip('#$_category'),
                            const SizedBox(width: 8),
                            _buildTagChip('#${widget.productType}'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Type Produk Picker
                        _label('Type ${widget.productType}'),
                        _buildSelector(
                          value: _serviceType,
                          onTap: _showTypePicker,
                        ),
                        const SizedBox(height: 8),
                        // Type tag chips
                        Row(
                          children: [
                            _buildTagChip('#$_serviceType'),
                            const SizedBox(width: 8),
                            _buildTagChip('#${widget.productType}'),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Section 2: Atur Harga
                    _buildFormCard(
                      children: [
                        _label('Atur Harga'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            'Masukan harga dalam rupiah',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Harga wajib diisi';
                            }
                            final price = int.tryParse(
                              value.replaceAll(RegExp(r'[^0-9]'), ''),
                            );
                            if (price == null || price < 0) {
                              return 'Harga tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Option 1: Harga Tetap
                        _buildPriceOption(
                          title: 'Harga Tetap',
                          isSelected: !_negotiable,
                          onTap: () => setState(() => _negotiable = false),
                        ),
                        const SizedBox(height: 8),

                        // Option 2: Harga Bisa Nego
                        _buildPriceOption(
                          title: 'Harga Bisa Nego',
                          isSelected: _negotiable,
                          onTap: () => setState(() => _negotiable = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom "Selanjutnya" Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF93C5FD),
                    foregroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    ),
  );

  Widget _buildSelector({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildPriceOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF93C5FD)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
    ),
  );
}
