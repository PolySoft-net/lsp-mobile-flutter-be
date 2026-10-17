import 'package:material_ui/material_ui.dart';

import 'career_expo_home_tab.dart';
import 'career_expo_lamaran_tab.dart';
import 'career_expo_notifikasi_tab.dart';
import 'career_expo_profile_tab.dart';
import 'career_expo_search_tab.dart';
import '../../services/career_expo/career_expo_service.dart';

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
  int _lamaranKeyCounter = 0;
  int _notifikasiKeyCounter = 0;
  int _profileKeyCounter = 0;
  int _unreadNotifCount = 0;
  int _searchKeyCounter = 0;
  String _searchQuery = '';
  String _searchEmpType = 'Semua';
  String _searchWorkplaceType = 'Semua';
  String _searchLocation = 'Semua';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _checkUnreadNotif();
  }

  Future<void> _checkUnreadNotif() async {
    try {
      final count = await CareerExpoService.getUnreadNotifikasiCount();
      if (!mounted) return;
      setState(() => _unreadNotifCount = count);
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) _lamaranKeyCounter++;
      if (index == 3) {
        _notifikasiKeyCounter++;
        _unreadNotifCount = 0;
      }
      if (index == 4) _profileKeyCounter++;
    });
  }

  void _onNavigateToSearch({
    String? query,
    String? empType,
    String? workplaceType,
    String? location,
  }) {
    setState(() {
      _searchQuery = query ?? '';
      _searchEmpType = empType ?? 'Semua';
      _searchWorkplaceType = workplaceType ?? 'Semua';
      _searchLocation = location ?? 'Semua';
      _searchKeyCounter++;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      CareerExpoHomeTab(
        onNavigateToSearch: _onNavigateToSearch,
        onNavigateToNotification: () => _onTabTapped(3),
      ),
      CareerExpoSearchTab(
        key: ValueKey('search_$_searchKeyCounter'),
        initialQuery: _searchQuery,
        initialEmploymentType: _searchEmpType,
        initialWorkplaceType: _searchWorkplaceType,
        initialLocation: _searchLocation,
        showBackButton: false,
        onBack: () => _onTabTapped(0),
      ),
      CareerExpoLamaranTab(
        key: ValueKey('lamaran_$_lamaranKeyCounter'),
        onBack: () => _onTabTapped(0),
      ),
      CareerExpoNotifikasiTab(
        key: ValueKey('notifikasi_$_notifikasiKeyCounter'),
      ),
      CareerExpoProfileTab(
        key: ValueKey('profile_$_profileKeyCounter'),
        onNavigateToLamaran: () => _onTabTapped(2),
      ),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _CareerExpoBottomNav(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
        unreadNotifCount: _unreadNotifCount,
      ),
    );
  }
}

class _CareerExpoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final int unreadNotifCount;

  const _CareerExpoBottomNav({
    required this.currentIndex,
    required this.onTabTapped,
    required this.unreadNotifCount,
  });

  @override
  Widget build(BuildContext context) {
    // Sembunyikan bottom nav saat keyboard terbuka tanpa me-rebuild layar utama
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
                _buildNavItem(1, Icons.search_rounded, Icons.search_rounded),
                _buildNavItem(2, Icons.work_rounded, Icons.work_outline_rounded),
                _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_none_rounded, hasBadge: unreadNotifCount > 0),
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
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF0066F6) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => onTabTapped(index),
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
