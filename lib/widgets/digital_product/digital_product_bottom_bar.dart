import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class DigitalProductBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const DigitalProductBottomBar({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
  });

  static const List<_BottomNavItem> _navItems = [
    _BottomNavItem(
      icon: LucideIcons.house,
      label: 'Home',
    ),
    _BottomNavItem(
      icon: LucideIcons.compass,
      label: 'Explore',
    ),
    _BottomNavItem(
      icon: LucideIcons.search,
      label: 'Search',
    ),
    _BottomNavItem(
      icon: LucideIcons.bookmark,
      label: 'Save',
    ),
    _BottomNavItem(
      icon: LucideIcons.circle_user_round,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = selectedIndex == index;
              final color = isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: color,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });
}

