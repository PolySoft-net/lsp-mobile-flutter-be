import 'package:material_ui/material_ui.dart';

class SertifikatTabBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final int? aktifCount;
  final int? akanBerakhirCount;
  final int? kadaluarsaCount;

  const SertifikatTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.aktifCount,
    this.akanBerakhirCount,
    this.kadaluarsaCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildTabItem(0, 'Aktif', aktifCount)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabItem(1, 'Akan Berakhir', akanBerakhirCount)),
        const SizedBox(width: 8),
        Expanded(child: _buildTabItem(2, 'Kadaluarsa', kadaluarsaCount)),
      ],
    );
  }

  Widget _buildTabItem(int index, String label, int? count) {
    final isSelected = currentTab == index;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF758FAD),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
