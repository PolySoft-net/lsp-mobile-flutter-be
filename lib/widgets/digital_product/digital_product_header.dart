import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class DigitalProductHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddProductTap;

  const DigitalProductHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onFavoriteTap,
    this.onAddProductTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Digital Product Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCCFBF1).withValues(alpha: 0.6),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.shopping_bag,
                size: 20,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Product',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),
              Text(
                '& Services',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  height: 1.15,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onAddProductTap != null) ...[
            // Add Product circle button
            InkWell(
              onTap: onAddProductTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.plus,
                    size: 20,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
