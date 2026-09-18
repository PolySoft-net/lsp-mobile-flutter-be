import 'package:material_ui/material_ui.dart';
import 'digital_product_media_upload_screen.dart';

class DigitalProductFormScreen extends StatefulWidget {
  final String productType; // 'Produk' or 'Jasa'

  const DigitalProductFormScreen({
    super.key,
    this.productType = 'Produk',
  });

  @override
  State<DigitalProductFormScreen> createState() =>
      _DigitalProductFormScreenState();
}

class _DigitalProductFormScreenState extends State<DigitalProductFormScreen> {
  final TextEditingController _namaController =
      TextEditingController(text: 'Desing Website Mobile');
  final TextEditingController _hargaController = TextEditingController();

  String _selectedCategory = 'Design';
  String _selectedType = 'Online';
  String _hargaOption = 'Harga Tetap'; // 'Harga Tetap' or 'Harga Bisa Nego'

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: "< Buat Produk"
            _buildAppBar(context),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    // Card 1: Informasi Produk
                    _buildInformasiCard(),

                    const SizedBox(height: 14),

                    // Card 2: Atur Harga
                    _buildAturHargaCard(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom "Selanjutnya" Button
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final title = 'Buat ${widget.productType}';

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformasiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Produk
          Text(
            'Nama ${widget.productType}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _namaController,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Kategori
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _showCategoryPicker,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCategory,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _TagBadge(label: '#Website'),
              SizedBox(width: 8),
              _TagBadge(label: '#Design'),
            ],
          ),

          const SizedBox(height: 14),

          // Type Produk
          Text(
            'Type ${widget.productType}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _showTypePicker,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _TagBadge(label: '#Online'),
              SizedBox(width: 8),
              _TagBadge(label: '#Produk'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAturHargaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Atur Harga Title
          const Text(
            'Atur Harga',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Harga Input Field
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Masukan harga dalam rupiah',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Masukan harga dalam rupiah',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 12),

          // Radio 1: Harga Tetap
          _buildRadioOption('Harga Tetap'),

          const SizedBox(height: 8),

          // Radio 2: Harga Bisa Nego
          _buildRadioOption('Harga Bisa Nego'),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    final isSelected = _hargaOption == label;

    return InkWell(
      onTap: () {
        setState(() {
          _hargaOption = label;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                  width: 1.5,
                ),
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final categories = ['Design', 'Development', 'Marketing', 'Writing'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              return ListTile(
                title: Text(cat),
                trailing: _selectedCategory == cat
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final types = ['Online', 'Offline', 'Hybrid'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: types.map((t) {
              return ListTile(
                title: Text(t),
                trailing: _selectedType == t
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() => _selectedType = t);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DigitalProductMediaUploadScreen(
                  productType: widget.productType,
                  productName: _namaController.text,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5E7EB),
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Selanjutnya',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;

  const _TagBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

