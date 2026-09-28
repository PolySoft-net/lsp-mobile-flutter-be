import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/navigation/main_navigator.dart';
import '../../services/auth/token_storage.dart';
import '../../services/common/health_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/session_manager.dart';
import '../../services/common/notification_service.dart';
import '../../models/auth_models.dart';
import '../../services/common/app_update_service.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../../services/marketing/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  String _loadingStatus = "Menyiapkan aplikasi...";
  double _loadingProgress = 0.1;

  @override
  void initState() {
    super.initState();
    
    // Set system status bar & nav bar to transparent for edge-to-edge
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ));

    // Initialize animation controller for a smooth fade & scale wow factor
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Stage 1: Load configurations
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = "Membaca konfigurasi .env...";
        _loadingProgress = 0.3;
      });
    }

    try {
      // In case dotenv hasn't loaded yet or we want to double check it
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
    } catch (e) {
      debugPrint('Splash dotenv read status: $e');
    }

    // Stage 1.5: Health check server (NEW: backend added /api/health endpoint)
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _loadingStatus = "Memeriksa koneksi server...";
        _loadingProgress = 0.45;
      });
    }

    bool serverHealthy = await HealthService.healthCheck();
    if (!serverHealthy) {
      debugPrint('⚠️ Server health check failed');
      await _showNoConnectionDialog();
      return;
    }

    // Stage 1.6: Cek update Play Store (in-app update). Tidak ada update ->
    // lanjut tanpa jeda berarti; ada update flexible -> dialog konfirmasi.
    if (mounted) {
      setState(() {
        _loadingStatus = "Memeriksa pembaruan aplikasi...";
        _loadingProgress = 0.55;
      });
    }
    try {
      await AppUpdateService.instance.checkForUpdate();
    } catch (e) {
      debugPrint('⚠️ App update check failed (non-fatal): $e');
    }

    // Stage 1.7: Readiness check (verify DB connection)
    bool serverReady = await HealthService.readyCheck();
    if (!serverReady) {
      debugPrint('⚠️ Server not ready (DB issue)');
      await _showNoConnectionDialog(serverBusy: true);
      return;
    }

    // Stage 1.8: Perizinan Aplikasi (Notifikasi & Lokasi GPS)
    if (mounted) {
      setState(() {
        _loadingStatus = "Memeriksa perizinan aplikasi...";
        _loadingProgress = 0.58;
      });
    }

    try {
      // 1. Izin Notifikasi
      await NotificationService.instance
          .requestPermission()
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('⚠️ Notification permission check failed: $e');
    }

    try {
      // 2. Izin Lokasi (koordinat GPS dihangatkan di background oleh service)
      await LocationService.requestPermissionAndWarmup()
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('⚠️ Location permission check failed: $e');
    }

    // Stage 2: Initialize assets / session check
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = "Memvalidasi sesi login...";
        _loadingProgress = 0.6;
      });
    }

    AuthUser? loggedInUser;
    try {
      final token = await TokenStorage.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final authRepo = AuthRepository.instance;
        loggedInUser = await authRepo.currentUser();
        
        // Register token for all roles
        NotificationService.instance.registerCurrentToken();
      }
    } catch (e) {
      debugPrint('Session loading failed: $e');

      // ApiClient interceptor adalah satu-satunya otoritas matinya session:
      // token hanya dihapus di sana saat refresh ditolak (401/403) atau request
      // retry masih 401. Jadi di sini cukup cek keberadaan token — 401 yang
      // lolos ke sini karena refresh gagal sementara (DB spike/network) tidak
      // boleh menghapus session user.
      final stillHaveToken = await TokenStorage.instance.getAccessToken();
      final shouldForceLogout = stillHaveToken == null || stillHaveToken.isEmpty;

      if (shouldForceLogout) {
        try {
          final authRepo = AuthRepository.instance;
          await authRepo.logout();
        } catch (ex) {
          debugPrint('Logout during failed session loading failed: $ex');
        }
      } else {
        // If it's a server/network error (like 502), try to load cached user from TokenStorage
        try {
          final cachedUser = await TokenStorage.instance.getUserProfile();
          if (cachedUser != null) {
            loggedInUser = cachedUser;
            AuthRepository.currentUserInstance = cachedUser;
            debugPrint('Loaded cached user session: ${cachedUser.name}');
          }
        } catch (cacheEx) {
          debugPrint('Failed to load cached user profile: $cacheEx');
        }
      }
    }

    // Stage 3: Smooth progress completion
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = loggedInUser != null
            ? "Selamat datang kembali, ${loggedInUser.name}..."
            : "Menghubungkan ke server LSP...";
        _loadingProgress = 1.0;
      });
    }

    // Smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
    // Baca flag onboarding WAJIB fail-safe: EncryptedSharedPreferences bisa
    // throw/menggantung di Android, dan kalau itu terjadi splash terjebak
    // selamanya di status terakhir tanpa pernah pindah layar.
    bool seenOnboarding = false;
    try {
      seenOnboarding = await TokenStorage.instance
          .hasSeenOnboarding()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('⚠️ Onboarding flag read failed (non-fatal): $e');
    }
    if (!mounted) return;

    // If a token expired during cold start (before the main shell mounted),
    // route straight to login instead of silently entering the guest shell.
    final bool forceLogin = SessionManager.forcedLogoutPending;
    if (forceLogin) {
      SessionManager.resetForcedLogout();
    }

    final Widget nextScreen = forceLogin
        ? const LoginScreen()
        : (loggedInUser != null
            ? MainNavigator(key: mainNavigatorKey)
            : (seenOnboarding
                ? MainNavigator(key: mainNavigatorKey)
                : const OnboardingScreen()));

    Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 850),
          reverseTransitionDuration: const Duration(milliseconds: 850),
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            );
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            );
            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        ),
      );
  }

  /// [serverBusy] membedakan dua sebab yang berbeda: endpoint tidak terjangkau
  /// (internet user) vs server/DB sedang bermasalah (503 dari /api/ready).
  /// Dulu keduanya berbunyi "periksa koneksi internet Anda", sehingga saat DB
  /// spike app menyalahkan internet user — dan user tidak tahu sesinya aman.
  Future<void> _showNoConnectionDialog({bool serverBusy = false}) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Icon Stack matching the image style exactly
            Stack(
              alignment: Alignment.center,
              children: [
                // Decorative background dots (orange/amber style like the reference image)
                ...[
                  const Offset(-55, -20),
                  const Offset(-42, -45),
                  const Offset(-60, 10),
                  const Offset(-48, 35),
                  const Offset(55, -25),
                  const Offset(45, -5),
                  const Offset(58, 22),
                  const Offset(42, 45),
                  const Offset(-10, -55),
                  const Offset(15, 52),
                ].asMap().entries.map((entry) {
                  final offset = entry.value;
                  final index = entry.key;
                  final size = (index % 3 == 0) ? 6.0 : (index % 3 == 1 ? 9.0 : 5.0);
                  return Transform.translate(
                    offset: offset,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFCC80).withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }),
                // Main circular icon container with larger styling
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFEAD2), // Orange/amber accent matching reference
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 46, // Larger icon size
                    color: Color(0xFFEF6C00), // Warm amber/orange
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Message styled like the reference (bold title and clean font)
            Text(
              serverBusy ? 'Server Sedang Sibuk' : 'Koneksi Internet Terputus',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              serverBusy
                  ? 'Server LSP sedang sibuk. Sesi login Anda tetap aman dan tidak perlu login ulang. Silakan coba lagi sebentar lagi.'
                  : 'Silakan periksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            // Standard rounded blue action button OK/Coba Lagi
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    setState(() {
                      _loadingProgress = 0.1;
                      _loadingStatus = "Menghubungkan kembali...";
                    });
                    _startInitialization();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF559AD4), // Clean sky blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Jalan keluar: barrierDismissible=false, jadi tanpa ini user
            // terjebak loop retry selama server belum pulih.
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text(
                'Keluar Aplikasi',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF559AD4), // Sky blue premium
              Color(0xFF1E4B70), // Elegant deep navy blue
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top accent bubble for deep aesthetics
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    
                    // Logo with glow & shadow container
                    Hero(
                      tag: 'app_logo',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFF4FA8E8).withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // App Main Title
                    const Text(
                      'LSP TEKNOLOGI DIGITAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // App Subtitle
                    Text(
                      'Monitoring Sertifikasi Nasional',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Progress Loading Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        children: [
                          // Elegant thin progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: _loadingProgress,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Dynamic loading status text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _loadingStatus,
                              key: ValueKey<String>(_loadingStatus),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Footer branding
                    Text(
                      'Powered By LSP Teknologi Digital 2026',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
