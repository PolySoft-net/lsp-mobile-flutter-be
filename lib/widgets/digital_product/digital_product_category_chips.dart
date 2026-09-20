import 'package:material_ui/material_ui.dart';

class DigitalProductCategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const DigitalProductCategoryChips({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  static const List<String> categories = [
    'Online',
    'Offline',
    'Jasa',
    'Produk',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: category != categories.last ? 8.0 : 0.0,
              ),
              child: InkWell(
                onTap: () => onCategorySelected?.call(category),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2563EB),
                      ),
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

