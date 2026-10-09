import 'package:material_ui/material_ui.dart';

import 'career_expo_home_tab.dart';
import 'career_expo_lamaran_tab.dart';
import 'career_expo_notifikasi_tab.dart';
import 'career_expo_profile_tab.dart';
import 'career_expo_search_tab.dart';

/// Screen utama Career Expo dengan Bottom Navigation Bar 5 Tab
class CareerExpoScreen extends StatefulWidget {
  final int initialTabIndex;

  const CareerExpoScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<CareerExpoScreen> createState() => _CareerExpoScreenState();
}

class _CareerExpoScreenState extends State<CareerExpoScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      CareerExpoHomeTab(
        onNavigateToSearch: () => _onTabTapped(1),
        onNavigateToNotification: () => _onTabTapped(3),
      ),
      CareerExpoSearchTab(
        initialQuery: 'UI/UX',
        showBackButton: false,
        onBack: () => _onTabTapped(0),
      ),
      CareerExpoLamaranTab(
        onBack: () => _onTabTapped(0),
      ),
      const CareerExpoNotifikasiTab(),
      CareerExpoProfileTab(
        onNavigateToLamaran: () => _onTabTapped(2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
                _buildNavItem(1, Icons.search_rounded, Icons.search_rounded),
                _buildNavItem(2, Icons.work_rounded, Icons.work_outline_rounded),
                _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_none_rounded, hasBadge: true),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon, {
    bool hasBadge = false,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0066F6) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: color,
                size: 26,
              ),
              if (hasBadge)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
