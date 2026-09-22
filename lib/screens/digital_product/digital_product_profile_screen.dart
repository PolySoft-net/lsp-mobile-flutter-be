import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_models.dart';
import '../../services/digital_product_service.dart';
import '../../widgets/digital_product/digital_product_bottom_bar.dart';
import '../../widgets/digital_product/fade_page_route.dart';
import 'digital_product_favorit_screen.dart';
import 'digital_product_pengaturan_profil_screen.dart';
import 'digital_product_produk_jasa_screen.dart';

class DigitalProductProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DigitalProductProfileScreen({super.key, this.onBackToHome});

  @override
  State<DigitalProductProfileScreen> createState() =>
      _DigitalProductProfileScreenState();
}

class _DigitalProductProfileScreenState
    extends State<DigitalProductProfileScreen> {
  DigitalProductProfile? _profile;
  bool _loading = true;
  String _error = '';
  static const int _currentBottomNavIndex = 4;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final profile = await DigitalProductService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _error = 'Profil belum dapat dimuat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 4) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context, index);
    } else {
      widget.onBackToHome?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(
                      child: TextButton(
                        onPressed: _load,
                        child: Text('$_error. Coba lagi'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          _buildProfileCard(),
                          const SizedBox(height: 12),
                          _buildCompetencyCard(),
                          const SizedBox(height: 12),
                          _buildMenuCard(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DigitalProductBottomBar(
        selectedIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                widget.onBackToHome?.call();
              }
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const Text(
            'Profil',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final seller = _profile?.seller ?? DigitalProductSeller.empty;
    final photo = DigitalProductService.absoluteUrl(seller.profilePhoto);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EDFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF94A3B8),
            backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
            child: photo.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 34)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name.isEmpty ? 'Asesi' : seller.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  seller.email,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_profile?.products.length ?? 0} Produk/Jasa',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetencyCard() {
    final certificates =
        _profile?.certificates ?? const <DigitalProductCertificate>[];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sertifikasi Kompetensi',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (certificates.isEmpty)
            const Text(
              'Belum ada sertifikasi kompetensi',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            )
          else
            ...certificates.map(
              (certificate) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_outlined, size: 20),
                title: Text(
                  certificate.schemeName,
                  style: const TextStyle(fontSize: 12),
                ),
                subtitle: Text(
                  [
                    certificate.schemeCode,
                    certificate.competencyStatus,
                  ].where((value) => value.isNotEmpty).join(' · '),
                  style: const TextStyle(fontSize: 10.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _menuItem(
            Icons.account_circle_outlined,
            'Pengaturan Profil',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DigitalProductPengaturanProfilScreen(),
              ),
            ),
          ),
          const Divider(height: 1),
          _menuItem(
            Icons.bookmark_border_rounded,
            'Koleksi',
            () => Navigator.of(
              context,
            ).push(FadePageRoute(page: const DigitalProductFavoritScreen())),
          ),
          const Divider(height: 1),
          _menuItem(
            Icons.group_work_outlined,
            'Produk/Jasa',
            () => Navigator.of(
              context,
            ).push(FadePageRoute(page: const DigitalProductProdukJasaScreen())),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
