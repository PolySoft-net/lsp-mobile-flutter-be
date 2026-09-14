import 'package:material_ui/material_ui.dart';
import '../../widgets/digital_product/digital_product_header.dart';
import '../../widgets/digital_product/digital_product_banner.dart';
import '../../widgets/digital_product/digital_product_category_chips.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';

class DigitalProductScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<DigitalProductScreen> createState() => _DigitalProductScreenState();
}

class _DigitalProductScreenState extends State<DigitalProductScreen> {
  String? _selectedCategory;
  int _currentBottomNavIndex = 0;

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DigitalProductHeader(),
            const SizedBox(height: 4),
            const DigitalProductBanner(),
            const SizedBox(height: 8),
            DigitalProductCategoryChips(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
      bottomNavigationBar: DigitalProductBottomBar(
        selectedIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
