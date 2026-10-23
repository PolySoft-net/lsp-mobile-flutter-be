import 'package:material_ui/material_ui.dart';

import '../../services/asesi/asesi_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Halaman Pengaturan Profil Career Expo sesuai mockup UI
class CareerExpoProfileEditScreen extends StatefulWidget {
  const CareerExpoProfileEditScreen({super.key});

  @override
  State<CareerExpoProfileEditScreen> createState() =>
      _CareerExpoProfileEditScreenState();
}

class _CareerExpoProfileEditScreenState
    extends State<CareerExpoProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? _asesiProfile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final user = AuthRepository.currentUserInstance;
    if (user != null) {
      _nameController.text = user.name;
      if (user.email != null) _emailController.text = user.email!;
    }
    _loadAsesiPhone();
  }

  Future<void> _loadAsesiPhone() async {
    try {
      final profile = await AsesiService.getProfile();
      if (profile != null && mounted) {
        _asesiProfile = profile;
        final hp = profile['telp']?.toString() ??
            profile['no_hp']?.toString() ??
            profile['telepon']?.toString() ??
            profile['no_telepon']?.toString() ??
            '';
        if (hp.isNotEmpty && _phoneController.text.isEmpty) {
          setState(() {
            _phoneController.text = hp;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan email tidak boleh kosong.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final body = Map<String, dynamic>.from(_asesiProfile ?? {});
      body['nama_lengkap'] = name;
      body['email'] = email;
      body['telp'] = phone;
      final success = await AsesiService.updateProfile(body);
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui.'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil. Coba lagi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          bottom: false,
          child: CustomAppBar(
            title: 'Pengaturan Profil',
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Card: Big circular avatar in center
              Container(
                width: double.infinity,
                height: 104,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Card: Nama, No.Hp, Email
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'Nama',
                      controller: _nameController,
                      hint: 'Nama Lengkap',
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'No.Hp',
                      controller: _phoneController,
                      hint: 'Nomor WhatsApp / HP',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Email aktif',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Button "Edit"
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: Color(0xFF0F172A),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}
