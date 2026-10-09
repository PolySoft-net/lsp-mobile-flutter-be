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
      const CareerExpoLamaranTab(),
      const CareerExpoNotifikasiTab(),
      const CareerExpoProfileTab(),
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
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0066F6),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 11.5,
          unselectedFontSize: 11.5,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Cari',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              label: 'Lamaran',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
