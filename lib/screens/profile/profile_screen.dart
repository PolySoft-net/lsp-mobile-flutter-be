import 'package:file_picker/file_picker.dart';
import '../../utils/upload_file_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/auth/token_storage.dart';
import '../../services/common/notification_service.dart';
import '../../models/dashboard_models.dart';
import '../../core/navigation/main_navigator.dart';
import 'data_diri_screen.dart';
import 'edit_instansi_screen.dart';
import 'keamanan_screen.dart';
import '../../widgets/profile/ringkasan_widget.dart';
import '../../widgets/profile/menu_profil_widget.dart';
import 'public_profile_screen.dart';
import '../../utils/url_helper.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isUploadingPhoto = false;
  bool _isInstansiExpanded = false;
  bool _isLoadingRingkasan = true;
  AsesiDashboardSummary _ringkasan = AsesiDashboardSummary.empty();
  String _instansiType = 'Mahasiswa';
  Map<String, String> _instansiData = {
    'Nama Perguruan Tinggi': '',
    'Falkutas': '',
    'Program Studi': '',
    'NIM': '',
    'Alamat': '',
  };

  @override
  void initState() {
    super.initState();
    _fetchInstansi();
    _fetchRingkasan();
  }

  Future<void> _fetchRingkasan() async {
    setState(() => _isLoadingRingkasan = true);
    try {
      final data = await DashboardService.getAsesiSummary();
      if (!mounted) return;
      setState(() {
        _ringkasan = data;
        _isLoadingRingkasan = false;
      });
    } catch (e) {
      debugPrint('Error fetching asesi ringkasan: $e');
      if (mounted) setState(() => _isLoadingRingkasan = false);
    }
  }

  Future<void> _fetchInstansi() async {
    try {
      final res = await AsesiService.getInstansi();
      if (res != null && mounted) {
        final type = res['tipe_instansi'] ?? 'Mahasiswa';
        final data = res['data_instansi'] ?? {};
        setState(() {
          _instansiType = type;
          if (type == 'Mahasiswa') {
            _instansiData = {
              'Nama Perguruan Tinggi':
                  data['nama_perguruan_tinggi']?.toString() ?? '',
              'Falkutas': data['fakultas']?.toString() ?? '',
              'Program Studi': data['program_studi']?.toString() ?? '',
              'NIM': data['nim']?.toString() ?? '',
              'Alamat': data['alamat']?.toString() ?? '',
            };
          } else if (type == 'Pekerja' || type == 'Karyawan') {
            _instansiData = {
              'Nama Perusahaan': data['nama_perusahaan']?.toString() ?? '',
              'Jabatan': data['jabatan']?.toString() ?? '',
              'Bidang Pekerjaan': data['bidang_pekerjaan']?.toString() ?? '',
              'Lama Bekerja': data['lama_bekerja']?.toString() ?? '',
              'Alamat': data['alamat']?.toString() ?? '',
            };
          } else {
            _instansiData = {
              'Nama Usaha': data['nama_usaha']?.toString() ?? '',
              'Bidang Usaha': data['bidang_usaha']?.toString() ?? '',
              'Tahun Berdiri': data['tahun_berdiri']?.toString() ?? '',
              'Alamat': data['alamat']?.toString() ?? '',
            };
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching instansi: $e');
    }
  }

  void _copyTukId() {
    final userAccount =
        AuthRepository.currentUserInstance?.account ??
        AuthRepository.currentUserInstance?.id ??
        '';
    Clipboard.setData(ClipboardData(text: userAccount));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('ID TUK disalin ke clipboard!'),
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
      final messenger = ScaffoldMessenger.of(context);
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file != null) {
        final valid = await UploadFileValidator.isValid(
          messenger,
          file,
          UploadFileValidator.profilePhotoMaxMB,
        );
        if (!mounted) {
          return;
        }
        if (!valid) {
          return;
        }
        final filePath = file.path!;
        setState(() => _isUploadingPhoto = true);
        final uploaded = await AuthRepository.uploadProfilePhoto(filePath);
        if (!mounted) return;
        if (uploaded != null && uploaded['foto_profil_url'] != null) {
          setState(() {});
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF378CE7),
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF378CE7),
                    ),
                  ),
                  title: const Text('Ambil Foto / Pilih Berkas'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
      body: SingleChildScrollView(
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
                      Row(
                        children: [
                          const Text(
                            'Profil Saya',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                              builder: (context) => const KeamananScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Builder(
                    builder: (context) {
                      final rawPhoto = user.fotoProfilUrl;
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
                                    color: Colors.black.withValues(alpha: 0.1),
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5B9FD8),
                                                ),
                                          ),
                                        ),
                                      )
                                    : (photoUrl != null && photoUrl.isNotEmpty)
                                    ? Image.network(
                                        photoUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
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
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // TUK Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TUK Digital Marketing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ID TUK Copyable Row
                  GestureDetector(
                    onTap: _copyTukId,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ID TUK : ${user.account.isNotEmpty
                              ? user.account
                              : user.id.isNotEmpty
                              ? user.id
                              : '-'}',
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
                ],
              ),
            ),

            // Content Body Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (_isLoadingRingkasan)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    RingkasanWidget(
                      sertifikatAktif: _ringkasan.sertifikatAktif,
                      skemaKompetensi: _ringkasan.skemaKompetensi,
                      sertifikatKadaluarsa: _ringkasan.sertifikatKadaluarsa,
                      totalUjiKompetensi: _ringkasan.totalUjiKompetensi,
                    ),
                  const SizedBox(height: 24),
                  MenuProfilWidget(
                    onDataDiriTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataDiriScreen(),
                        ),
                      );
                    },
                    isInstansiExpanded: _isInstansiExpanded,
                    instansiType: _instansiType,
                    instansiData: _instansiData,
                    onInstansiTap: () {
                      setState(() {
                        _isInstansiExpanded = !_isInstansiExpanded;
                      });
                    },
                    onInstansiEditTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditInstansiScreen(
                            currentType: _instansiType,
                            currentData: _instansiData,
                            onSave: (type, data) async {
                              setState(() {
                                _instansiType = type;
                                _instansiData = data;
                              });
                              // Prepare fields for backend schema mapping
                              final Map<String, String> dataMap = {};
                              if (type == 'Mahasiswa') {
                                dataMap['nama_perguruan_tinggi'] =
                                    data['Nama Perguruan Tinggi'] ?? '';
                                dataMap['nim'] = data['NIM'] ?? '';
                                dataMap['alamat'] = data['Alamat'] ?? '';
                              } else if (type == 'Karyawan') {
                                dataMap['nama_perusahaan'] =
                                    data['Nama Perusahaan'] ?? '';
                                dataMap['jabatan'] = data['Jabatan'] ?? '';
                                dataMap['bidang_pekerjaan'] =
                                    data['Bidang Pekerjaan'] ?? '';
                                dataMap['lama_bekerja'] =
                                    data['Lama Bekerja'] ?? '';
                                dataMap['alamat'] = data['Alamat'] ?? '';
                              } else {
                                dataMap['nama_usaha'] =
                                    data['Nama Usaha'] ?? '';
                                dataMap['bidang_usaha'] =
                                    data['Bidang Usaha'] ?? '';
                                dataMap['tahun_berdiri'] =
                                    data['Tahun Berdiri'] ?? '';
                                dataMap['alamat'] = data['Alamat'] ?? '';
                              }
                              await AsesiService.updateInstansi(type, dataMap);
                            },
                          ),
                        ),
                      );
                    },
                    onKeamananTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KeamananScreen(),
                        ),
                      );
                    },
                    onReviewAppTap: () => UrlHelper.openAppReview(),
                    onKeluarTap: _isLoggingOut
                        ? null
                        : _showLogoutConfirmDialog,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
