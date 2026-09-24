import 'package:material_ui/material_ui.dart';

class DigitalProductCategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;
  final bool showAllOption;

  const DigitalProductCategoryChips({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.showAllOption = true,
  });

  static const List<String> categories = [
    'Software',
    'Ebook',
    'Video',
    'Template',
    'Musik',
    'Voucher',
    'Instalasi',
    'Konfigurasi',
    'Troubleshoot',
  ];

  @override
  Widget build(BuildContext context) {
    final list = [
      if (showAllOption) 'Semua',
      ...categories,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: list.map((category) {
          final isAll = category == 'Semua';
          final isSelected = isAll
              ? (selectedCategory == null ||
                  selectedCategory!.isEmpty ||
                  selectedCategory!.toLowerCase() == 'semua')
              : (selectedCategory?.toLowerCase() == category.toLowerCase());

          return Padding(
            padding: EdgeInsets.only(
              right: category != list.last ? 8.0 : 0.0,
            ),
            child: InkWell(
              onTap: () {
                if (isAll) {
                  onCategorySelected?.call('');
                } else {
                  onCategorySelected?.call(category);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 9.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE0EDFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

