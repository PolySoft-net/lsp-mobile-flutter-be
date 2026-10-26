import 'package:material_ui/material_ui.dart';

class InvestmentFilterSheet extends StatefulWidget {
  final String selectedCategory;
  final String selectedStage;
  final String selectedSort;
  final Function(String category, String stage, String sort) onApply;

  const InvestmentFilterSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedStage,
    required this.selectedSort,
    required this.onApply,
  });

  static const List<String> categories = [
    'Semua',
    'EdTech & AI',
    'AgriTech',
    'HealthTech',
    'Logistik',
    'GreenTech',
    'FinTech',
    'SaaS',
    'E-Commerce',
  ];

  static const List<String> stages = [
    'Semua',
    'Pre-Seed',
    'Seed',
    'Pre-Series A',
    'Series A',
    'Bootstrapped',
  ];

  static const Map<String, String> sortOptions = {
    '': 'Terbaru',
    'funding_asc': 'Target Dana: Terendah',
    'funding_desc': 'Target Dana: Tertinggi',
  };

  @override
  State<InvestmentFilterSheet> createState() => _InvestmentFilterSheetState();
}

class _InvestmentFilterSheetState extends State<InvestmentFilterSheet> {
  late String _category;
  late String _stage;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _stage = widget.selectedStage;
    _sort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: keyboardInset > 0 ? keyboardInset + 16 : 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Urutkan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = 'Semua';
                      _stage = 'Semua';
                      _sort = '';
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

          // Sektor Kategori
          const Text(
            'Sektor Industri',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InvestmentFilterSheet.categories.map((c) {
              final isSelected = _category == c;
              return ChoiceChip(
                label: Text(c),
                selected: isSelected,
                selectedColor: const Color(0xFF0D9488),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _category = c);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Tahapan Startup (Stage)
          const Text(
            'Tahapan Pendanaan (Stage)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InvestmentFilterSheet.stages.map((s) {
              final isSelected = _stage == s;
              return ChoiceChip(
                label: Text(s),
                selected: isSelected,
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _stage = s);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Urutkan (Sort By)
          const Text(
            'Urutan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InvestmentFilterSheet.sortOptions.entries.map((entry) {
              final isSelected = _sort == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                selectedColor: const Color(0xFF0F172A),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _sort = entry.key);
                },
              );
            }).toList(),
          ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_category, _stage, _sort);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Terapkan Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
