import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../widgets/dashboard/rangkuman_utama.dart';
import '../../widgets/dashboard/rangkuman_asesi.dart';
import '../../widgets/dashboard/rangkuman_asesor.dart';
import '../../widgets/dashboard/tren_asesmen_chart.dart';
import '../jadwal/pelaporan_screen.dart';
import '../pendaftaran/permohonan_pendaftaran_screen.dart';
import '../../widgets/common/notification_bell.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../services/dashboard/berita_service.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../models/dashboard_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/dashboard/mulai_sertifikasi_card.dart';
import '../../models/berita_models.dart';
import '../../widgets/dashboard/berita_terkini_section.dart';
import '../auth/login_screen.dart';
import '../../widgets/dashboard/public_sertifikat_card.dart';
import '../../widgets/dashboard/tentang_kami_section.dart';
import '../../widgets/dashboard/bantuan_informasi_section.dart';
import '../profile/honor_asesor_screen.dart';
import '../profile/profile_asesor_screen.dart';
import '../blanko/admin_pengajuan_blanko_screen.dart';
import '../../utils/url_helper.dart';
import '../../widgets/dashboard/asesi_timeline_section.dart';
import '../../widgets/dashboard/asesi_talenta_status_card.dart';
import '../../widgets/dashboard/menu_bulat_section.dart';
import '../talenta/talenta_screen.dart';
import '../sertifikat/skema_sertifikasi_screen.dart';
import '../sertifikat/validasi_sertifikat_screen.dart';
import 'berita_screen.dart';
import '../ai/asesor_ai_screen.dart';
import '../digital_product/digital_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToJadwal;
  final Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({
    super.key,
    this.onNavigateToJadwal,
    this.onNavigateToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _initTimer;

  // State untuk menyimpan data dari API
  DashboardSummary? _summaryData;
  AsesiDashboardSummary? _asesiSummaryData;
  AsesorDashboardData? _asesorDashboardData;
  List<MonthlyAssessment>? _chartData;
  // ignore: unused_field
  List<JadwalBaru>? _jadwalData;
  List<BeritaItem>? _beritaData;

  @override
  void initState() {
    super.initState();
    // Delay 300ms to let session validation complete first
    _initTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isDisposed && mounted) {
        _loadAllData();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _initTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthRepository.currentUserInstance;
      final bool isAsesi = user?.role == 'asesi';
      final bool isAsesor = user?.role == 'asesor';

      if (isAsesi) {
        // Panggil API yang dibutuhkan asesi secara parallel (termasuk berita, chart graf, dan jadwal baru)
        final results = await Future.wait([
          DashboardService.getAsesiSummary(),
          BeritaService.getBerita(page: 1, size: 5),
          DashboardService.getAssessmentGraph(),
          JadwalService.getJadwalBaru(),
        ]);

        if (_isDisposed || !mounted) return;
        setState(() {
          _asesiSummaryData = results[0] as AsesiDashboardSummary;
          _beritaData = results[1] as List<BeritaItem>;
          _chartData = results[2] as List<MonthlyAssessment>;
          _jadwalData = results[3] as List<JadwalBaru>;
          _isLoading = false;
        });
      } else if (isAsesor) {
        // Fetch Asesor Dashboard API data
        final data = await DashboardService.getAsesorDashboard();
        if (_isDisposed || !mounted) return;
        setState(() {
          _asesorDashboardData = data;
          _isLoading = false;
        });
      } else {
        // Admin / other roles: admin summary APIs only.
        // Do NOT call /api/asesor/dashboard (role=asesor → 403 for admin).
        final results = await Future.wait([
          DashboardService.getSummary(),
          BeritaService.getBerita(page: 1, size: 5),
          DashboardService.getAssessmentGraph(),
          JadwalService.getJadwalBaru(),
        ]);

        if (_isDisposed || !mounted) return;
        setState(() {
          _summaryData = results[0] as DashboardSummary;
          _beritaData = results[1] as List<BeritaItem>;
          _chartData = results[2] as List<MonthlyAssessment>;
          _jadwalData = results[3] as List<JadwalBaru>;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Log error untuk debugging
      debugPrint('Error loading dashboard data: $e');
      if (_isDisposed || !mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ignore: unused_element
  Future<void> _refreshJadwalData() async {
    try {
      final jadwalData = await JadwalService.getJadwalBaru();
      if (!_isDisposed && mounted) {
        setState(() {
          _jadwalData = jadwalData;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing jadwal data: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAllData();

    if (!_isDisposed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final user = AuthRepository.currentUserInstance;
    final bool isAsesi = user?.role == 'asesi';
    final bool isAsesor = user?.role == 'asesor';
    final bool isGuest = user == null;
    final bool isAdmin = user != null && !isAsesi && !isAsesor;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 1. Top Section: Header & Rangkuman Utama Card Overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Sky Blue Header Background
                Container(
                  width: double.infinity,
                  height: (isGuest ? 310 : 260) + statusBarHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FA8E8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    statusBarHeight + 20,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (user != null) ...[
                            // Foto Profil
                            Builder(
                              builder: (context) {
                                final rawPhoto = user.fotoProfilUrl;
                                final photoUrl =
                                    (rawPhoto != null && rawPhoto.isNotEmpty)
                                    ? UrlHelper.resolveUrl(rawPhoto)
                                    : null;
                                return GestureDetector(
                                  onTap: isAsesor
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileAsesorScreen(),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        width: 2,
                                      ),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: photoUrl != null
                                          ? Image.network(
                                              photoUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person_rounded,
                                                    size: 32,
                                                    color: Color(0xFFCBD5E1),
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              size: 32,
                                              color: Color(0xFFCBD5E1),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            // Hallo / Selamat Datang Asesor, Nama User
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAsesor
                                        ? 'Selamat Datang Asesor'
                                        : 'Hallo,',
                                    style: const TextStyle(
                                      color: Color(0xE6FFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.name.isNotEmpty
                                        ? user.name
                                        : (isAsesor
                                              ? 'Muhammad Hanafi'
                                              : 'Asesi'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isGuest) ...[
                            // Guest Header (original style + Masuk button)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0x66FFFFFF,
                                  ), // white with 0.4 opacity
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Title Texts
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LSP Teknologi Digital',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Kompeten, Profesional dan Inovatif',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(
                                        0xE6FFFFFF,
                                      ), // white with 0.9 opacity
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // "Masuk" Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ] else ...[
                            // Custom Logo
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0x66FFFFFF,
                                  ), // white with 0.4 opacity
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Title Texts
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LSP Teknologi Digital',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Kompeten, Profesional dan Inovatif',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(
                                        0xE6FFFFFF,
                                      ), // white with 0.9 opacity
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (!isGuest) ...[
                            if (isAsesor) ...[
                              _buildAsesorMenuDropdown(context),
                              const SizedBox(width: 8),
                            ],
                            const NotificationBell(),
                          ],
                        ],
                      ),
                      if (isGuest) ...[
                        const SizedBox(height: 14),
                        // Searchbox AI Asisten (Tanya AI / Rekomendasi Skema)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AsesorAiScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 17,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Tanya AI: cari info, rekomendasi skema...',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Cari',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Rangkuman Utama Card Container (Imported widget)
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        statusBarHeight +
                        (isGuest ? 142 : (isAsesor ? 110 : 90)),
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: isGuest
                      ? const PublicSertifikatCard()
                      : (isAsesi
                            ? RangkumanAsesi(
                                data: _asesiSummaryData,
                                isLoading: _isLoading,
                                onNavigateToTab: widget.onNavigateToTab,
                              )
                            : (isAsesor
                                  ? RangkumanAsesor(
                                      isLoading: _isLoading,
                                      onNavigateToJadwal:
                                          widget.onNavigateToJadwal,
                                      data: _asesorDashboardData,
                                    )
                                  : RangkumanUtama(
                                      data: _summaryData,
                                      isLoading: _isLoading,
                                      onNavigateToJadwal:
                                          widget.onNavigateToJadwal,
                                    ))),
                ),
              ],
            ),
            if (isGuest || isAsesi)
              MenuBulatSection(
                items: [
                  if (isAsesi)
                    MenuBulatItem(
                      icon: Icons.card_membership_rounded,
                      label: 'E-Certificate',
                      color: const Color(0xFF6366F1),
                      onTap: () => widget.onNavigateToTab?.call(3),
                    ),
                  MenuBulatItem(
                    icon: Icons.groups_rounded,
                    label: 'Talenta',
                    color: const Color(0xFF2563EB),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TalentaScreen()),
                    ),
                  ),
                  MenuBulatItem(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Skema',
                    color: const Color(0xFF0EA5E9),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SkemaSertifikasiScreen(),
                      ),
                    ),
                  ),
                  MenuBulatItem(
                    icon: Icons.verified_rounded,
                    label: 'Validasi',
                    color: const Color(0xFF16A34A),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ValidasiSertifikatScreen(),
                      ),
                    ),
                  ),
                  MenuBulatItem(
                    icon: Icons.newspaper_rounded,
                    label: 'Berita',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BeritaScreen()),
                    ),
                  ),
                ],
              ),

            if (isAsesi && _asesiSummaryData?.hasAlert == true)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF3CD), Color(0xFFFFE8A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFE082),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB300),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _asesiSummaryData!.alertTitle,
                              style: const TextStyle(
                                color: Color(0xFF856404),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _asesiSummaryData!.alertSubtitle,
                              style: const TextStyle(
                                color: Color(0xFF856404),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 1.35. Form Status Pencari Kerja & Lokasi Domisili (Peta Talenta) — Khusus Asesi
            if (isAsesi) AsesiTalentaStatusCard(onUpdated: _loadAllData),

            // 1.4. Linimasa Uji Terakhir Section — Khusus untuk Asesi
            if (isAsesi)
              AsesiTimelineSection(
                timeline: _asesiSummaryData?.timelineTerakhir,
                isLoading: _isLoading,
                onNavigateToTab: widget.onNavigateToTab,
                onRefresh: _loadAllData,
              ),

            // 1.5. Mulai Skema Sertifikasi Section - Hanya untuk Guest/Publik (sembunyi untuk asesi/admin/asesor)
            if (isGuest)
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 4.0,
                  bottom: 8.0,
                ),
                child: MulaiSertifikasiCard(),
              ),

            // 1.6. Berita Terkini Section (2 boxes horizontally under Mulai Skema Sertifikasi) - Tampil di Asesi, Guest, Admin
            if (!isAsesor)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: BeritaTerkiniSection(
                  data: _beritaData,
                  isLoading: _isLoading,
                ),
              ),

            // Ringkasan Section (like Asesor) - Only for Admin
            if (isAdmin) _buildAdminRingkasanSection(),

            // 2. Tren Asesmen Bulanan Section — hanya untuk Admin/pengguna selain Asesi & Asesor
            if (!isAsesor && !isGuest && !isAsesi)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: TrenAsesmenChart(
                  data: _chartData,
                  isLoading: _isLoading,
                ),
              ),

            // 2.5. Tentang Kami Section - Hanya untuk Guest (Public Landing Page)
            if (isGuest) const TentangKamiSection(),

            // 3. Bantuan & Informasi Section - Tampil untuk Asesi & Asesor
            if (!isGuest && !isAdmin)
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 14.0,
                  bottom: 16.0,
                ),
                child: BantuanInformasiSection(),
              )
            else
              const SizedBox(height: 32),

            // 4. Berita Terkini Section Khusus Asesor (Di bawah Tanya Jawab / Bantuan & Informasi)
            if (isAsesor)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                child: BeritaTerkiniSection(
                  data: _beritaData,
                  isLoading: _isLoading,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminRingkasanSection() {
    final approveJadwalCount = _summaryData?.jadwalBelumTerkonfirmasi ?? 10;
    final laporanCount = _summaryData?.suratTugasMenungguPengiriman ?? 4;
    final pendaftaranCount =
        _summaryData?.pendaftaranAsesiBaru != 0 &&
            _summaryData?.pendaftaranAsesiBaru != null
        ? _summaryData!.pendaftaranAsesiBaru
        : 12;
    final honorCount =
        _summaryData?.honorAsesorBelumDibayar != 0 &&
            _summaryData?.honorAsesorBelumDibayar != null
        ? _summaryData!.honorAsesorBelumDibayar
        : 4;
    final blankoCount =
        (_summaryData?.pengajuanBlankoBelumSelesai != null &&
            _summaryData!.pengajuanBlankoBelumSelesai > 0)
        ? _summaryData!.pengajuanBlankoBelumSelesai
        : ((_summaryData?.pengajuanBlankoPending != null &&
                  _summaryData!.pengajuanBlankoPending > 0)
              ? _summaryData!.pengajuanBlankoPending
              : 35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildRingkasanItem(
            icon: Icons.calendar_today_rounded,
            title: 'Approve Jadwal',
            subtitle: '$approveJadwalCount Jadwal menunggu...',
            onTap: () {
              if (widget.onNavigateToJadwal != null) {
                widget.onNavigateToJadwal!();
              }
            },
          ),
          const SizedBox(height: 8),
          _buildRingkasanItem(
            icon: Icons.assignment_rounded,
            title: 'Laporan',
            subtitle: '$laporanCount Laporan menunggu...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PelaporanScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildRingkasanItem(
            icon: Icons.note_add_rounded,
            title: 'Pendaftaran',
            subtitle: '$pendaftaranCount Pendaftaran asessi baru',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermohonanPendaftaranScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildRingkasanItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Honor',
            subtitle: '$honorCount Honor asessor belum dibayar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HonorAsesorScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildRingkasanItem(
            icon: Icons.description_outlined,
            title: 'Pengajuan Blanko',
            subtitle: '$blankoCount Pengajuan blanko pending',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPengajuanBlankoScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF3B82F6), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsesorMenuDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu Layanan & Profil',
      offset: const Offset(0, 48),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'profil') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileAsesorScreen(),
            ),
          );
        } else if (value == 'digital_product') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DigitalProductScreen(),
            ),
          );
        } else if (value == 'career_expo') {
          _showComingSoonDialog(
            context,
            'Career Expo',
            Icons.work_outline_rounded,
            const Color(0xFFEA580C),
          );
        } else if (value == 'magang_hub') {
          _showComingSoonDialog(
            context,
            'Magang Hub',
            Icons.school_outlined,
            const Color(0xFF7C3AED),
          );
        } else if (value == 'investment') {
          _showComingSoonDialog(
            context,
            'Investment',
            Icons.trending_up_rounded,
            const Color(0xFF059669),
          );
        }
      },
      itemBuilder: (context) => [
        _buildHeaderDropdownItem(
          value: 'profil',
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF2563EB),
          title: 'Profil',
        ),
        const PopupMenuDivider(height: 1),
        _buildHeaderDropdownItem(
          value: 'digital_product',
          icon: Icons.shopping_bag_outlined,
          iconColor: const Color(0xFF0D9488),
          title: 'Digital Product',
        ),
        _buildHeaderDropdownItem(
          value: 'career_expo',
          icon: Icons.work_outline_rounded,
          iconColor: const Color(0xFFEA580C),
          title: 'Career Expo',
          badgeText: 'Segera Hadir',
        ),
        _buildHeaderDropdownItem(
          value: 'magang_hub',
          icon: Icons.school_outlined,
          iconColor: const Color(0xFF7C3AED),
          title: 'Magang Hub',
          badgeText: 'Segera Hadir',
        ),
        _buildHeaderDropdownItem(
          value: 'investment',
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF059669),
          title: 'Investment',
          badgeText: 'Segera Hadir',
        ),
      ],
      icon: const Icon(Icons.apps_rounded, color: Colors.white, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildHeaderDropdownItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badgeText,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showComingSoonDialog(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Segera Hadir',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Layanan $title sedang dalam proses pengembangan untuk melengkapi ekosistem LSP Teknologi Digital. Nantikan pembaruan mendatang!',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
