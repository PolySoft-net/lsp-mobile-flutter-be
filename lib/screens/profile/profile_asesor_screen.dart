import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/auth/token_storage.dart';
import '../../services/common/notification_service.dart';
import '../../core/navigation/main_navigator.dart';
import 'data_diri_screen.dart';
import 'keamanan_screen.dart';
import 'honor_asesor_screen.dart';
import 'tiket_bantuan_screen.dart';
import '../dashboard/faq_screen.dart';
import 'public_profile_screen.dart';
import '../../widgets/profile/profile_asesor_widgets.dart';
import '../../utils/url_helper.dart';
import '../../utils/date_format_helper.dart';

class ProfileAsesorScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ProfileAsesorScreen({super.key, this.onBackToHome});

  @override
  State<ProfileAsesorScreen> createState() => _ProfileAsesorScreenState();
}

class _ProfileAsesorScreenState extends State<ProfileAsesorScreen> {
  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;
  bool _isUploadingPhoto = false;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _honorData;
  int _totalPenugasan = 0;
  int _totalLaporan = 0;
  int _totalLaporanSukses = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndHonor();
  }

  Future<void> _fetchProfileAndHonor() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final profile = await AsesorService.getProfile();
      final currentPeriod = DateFormatHelper.formatCurrentMonthPeriod();
      final honor = await AsesorService.getHonorList(currentPeriod, 'semua');

      final penugasanCount = await AsesorService.getAssignmentCount();

      // Fetch reports count
      int laporanCount = 0;
      int laporanSuksesCount = 0;
      try {
        final reports = await AsesorService.getLaporanList();
        laporanCount = reports.length;
        laporanSuksesCount = reports
            .where((item) => item['status'] == 'Terkonfirmasi')
            .length;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _profileData = profile;
          _honorData = honor;
          _totalPenugasan = penugasanCount;
          _totalLaporan = laporanCount;
          _totalLaporanSukses = laporanSuksesCount;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _copyAsesorId() {
    final String idText = _profileData?['id_asesor'] ?? 'ASR-2026-000123';
    Clipboard.setData(ClipboardData(text: idText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('ID Asesor disalin ke clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authRepo = AuthRepository.instance;

      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getToken();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error fetching FCM token for logout: $e');
        }
      }

      await authRepo.logout(deviceToken: fcmToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during logout: $e');
      }
      try {
        await TokenStorage.instance.clear();
        AuthRepository.currentUserInstance = null;
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        mainNavigatorKey = GlobalKey<MainNavigatorState>();
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainNavigator(key: mainNavigatorKey),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slideAnimation =
                      Tween<Offset>(
                        begin: const Offset(0.0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  final fadeAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeIn,
                  );
                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(opacity: fadeAnimation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (route) => false,
        );
      }
    }
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Konfirmasi Keluar',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah Anda yakin ingin keluar dari akun ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: const Color(0xFF64748B),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file != null) {
        final filePath = file.path;
        if (filePath == null) return;
        setState(() => _isUploadingPhoto = true);
        final uploaded = await AuthRepository.uploadProfilePhoto(filePath);
        if (!mounted) return;
        if (uploaded != null && uploaded['foto_profil_url'] != null) {
          final photoUrl = uploaded['foto_profil_url'].toString();
          setState(() {
            _profileData = {
              ...?_profileData,
              'foto_profil_url': photoUrl,
            };
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Foto profil berhasil diperbarui!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah foto profil'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoPickerDemo() {
    showProfilePhotoPicker(
      context: context,
      onPickPhoto: _pickAndUploadPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final user = AuthRepository.currentUserInstance;

    if (user == null) {
      return PublicProfileScreen(onBackToHome: widget.onBackToHome);
    }

    final userName = user.name;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchProfileAndHonor,
            color: const Color(0xFF5B9FD8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B9FD8), Color(0xFF4FA8E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: statusBarHeight + 12,
                      bottom: 24,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        // App Bar Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profil Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const KeamananScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Builder(
                          builder: (context) {
                            final rawPhoto = _profileData?['foto_profil_url']?.toString() ?? user.fotoProfilUrl;
                            final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
                                ? UrlHelper.resolveUrl(rawPhoto)
                                : null;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: _showPhotoPickerDemo,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _isUploadingPhoto
                                          ? const Center(
                                              child: SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
                                                ),
                                              ),
                                            )
                                          : (photoUrl != null && photoUrl.isNotEmpty)
                                              ? Image.network(
                                                  photoUrl,
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(
                                                      Icons.person_rounded,
                                                      size: 70,
                                                      color: Color(0xFFCBD5E1),
                                                    ),
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    size: 70,
                                                    color: Color(0xFFCBD5E1),
                                                  ),
                                                ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: _showPhotoPickerDemo,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Color(0xFF378CE7),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          _profileData?['nama_lengkap'] ?? userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ID copyable row
                        GestureDetector(
                          onTap: _copyAsesorId,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ID : ${_profileData?["id_asesor"] ?? "ASR-2026-000123"}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.copy_rounded,
                                color: Colors.white.withValues(alpha: 0.75),
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Status Badge "Aktif"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _profileData?['status_aktif'] ?? 'Aktif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Body Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ringkasan Title & Row of 3 Cards
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRingkasanCards(),
                        const SizedBox(height: 24),

                        // Honor Section
                        _buildHonorCard(),
                        const SizedBox(height: 24),

                        // Menu Profil Section
                        const Text(
                          'Menu Profil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          icon: Icons.person_rounded,
                          title: 'Data Diri',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DataDiriScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Honor',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HonorAsesorScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.shield_rounded,
                          title: 'Keamanan',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KeamananScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.local_play_rounded,
                          title: 'Tiket Bantuan',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TiketBantuanScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.help_rounded,
                          title: 'FAQ',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FaqScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.star_rounded,
                          title: 'Beri Rating & Ulasan',
                          iconColor: const Color(0xFF378CE7),
                          iconBgColor: const Color(0xFFE3F2FD),
                          onTap: () => UrlHelper.openAppReview(),
                        ),
                        _buildMenuCard(
                          icon: Icons.logout_rounded,
                          title: 'Keluar',
                          iconColor: const Color(0xFFEF4444),
                          iconBgColor: const Color(0xFFFEE2E2),
                          textColor: const Color(0xFFEF4444),
                          onTap: _isLoggingOut
                              ? () {}
                              : _showLogoutConfirmDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoadingProfile)
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCards() {
    return ProfileRingkasanCards(
      totalPenugasan: _totalPenugasan,
      totalLaporan: _totalLaporan,
      totalLaporanSukses: _totalLaporanSukses,
    );
  }

  Widget _buildHonorCard() {
    return ProfileHonorCard(
      honorData: _honorData,
      onTapLihatSemua: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HonorAsesorScreen(),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF1E293B),
  }) {
    return ProfileMenuCard(
      icon: icon,
      title: title,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      onTap: onTap,
      textColor: textColor,
    );
  }
}
