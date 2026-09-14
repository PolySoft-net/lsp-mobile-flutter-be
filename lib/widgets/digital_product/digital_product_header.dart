import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class DigitalProductHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onFilterTap;

  const DigitalProductHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onFavoriteTap,
    this.onFilterTap,
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
          // Favorite / Heart circle button
          InkWell(
            onTap: onFavoriteTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.heart,
                  size: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title
          const Text(
            'Digital Produk',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 12),

          // Search bar pill
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'search',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter / Sliders horizontal icon button
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                LucideIcons.sliders_horizontal,
                size: 22,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
