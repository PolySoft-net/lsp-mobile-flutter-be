import 'package:material_ui/material_ui.dart';

import '../../services/auth/token_storage.dart';
import '../../services/digital_product_service.dart';

class DigitalProductPengaturanProfilScreen extends StatefulWidget {
  const DigitalProductPengaturanProfilScreen({super.key});

  @override
  State<DigitalProductPengaturanProfilScreen> createState() =>
      _DigitalProductPengaturanProfilScreenState();
}

class _DigitalProductPengaturanProfilScreenState
    extends State<DigitalProductPengaturanProfilScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _photoUrl = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final profile = await DigitalProductService.getProfile();
      final seller = profile.seller;
      if (mounted) {
        setState(() {
          _namaController.text = seller.name;
          _emailController.text = seller.email;
          _noHpController.text = seller.phone;
          _photoUrl = seller.profilePhoto;
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    final user = await TokenStorage.instance.getUserProfile();
    if (mounted) {
      setState(() {
        _namaController.text = user?.name ?? '';
        _emailController.text = user?.email ?? '';
        _photoUrl = user?.fotoProfilUrl ?? '';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildAvatarBanner(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nama',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildReadonlyField(
                              _namaController.text.isNotEmpty
                                  ? _namaController.text
                                  : '-',
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No.Hp',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildReadonlyField(
                              _noHpController.text.isNotEmpty
                                  ? _noHpController.text
                                  : '-',
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildReadonlyField(
                              _emailController.text.isNotEmpty
                                  ? _emailController.text
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pengaturan Profil',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBanner() {
    final photo = DigitalProductService.absoluteUrl(_photoUrl);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: const BoxDecoration(color: Color(0xFFE0EDFB)),
      child: Center(
        child: CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xFF94A3B8),
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 36)
              : null,
        ),
      ),
    );
  }

  Widget _buildReadonlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
