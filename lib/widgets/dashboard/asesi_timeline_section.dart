import 'package:material_ui/material_ui.dart';
import '../../models/asesi_dashboard_models.dart';
import '../../models/jadwal_models.dart';
import '../../models/sertifikat_models.dart';
import '../../screens/asesi/asesi_ak03_form_screen.dart';
import '../../screens/jadwal/jadwal_detail_screen.dart';
import '../../screens/pengajuan/pra_asesmen_screen.dart';
import '../../screens/pengajuan/hasil_review_pra_asesmen_screen.dart';
import '../../screens/sertifikat/e_certificate_webview_screen.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/auth/token_storage.dart';
import '../../utils/date_format_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AsesiTimelineSection extends StatelessWidget {
  final AsesiTimelineTerakhir? timeline;
  final List<SertifikatItem> sertifikatList;
  final bool isLoading;
  final Function(int tabIndex)? onNavigateToTab;
  final VoidCallback? onRefresh;

  const AsesiTimelineSection({
    super.key,
    this.timeline,
    this.sertifikatList = const [],
    this.isLoading = false,
    this.onNavigateToTab,
    this.onRefresh,
  });

  void _openDetailJadwal(BuildContext context, AsesiTimelineTerakhir data) {
    final user = AuthRepository.currentUserInstance;
    final userRole = UserRole(
      role: user?.role ?? 'asesi',
      name: user?.name ?? '',
      email: user?.email ?? '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JadwalDetailScreen(
          jadwal: data.toJadwalItem(),
          userRole: userRole,
        ),
      ),
    ).then((_) => onRefresh?.call());
  }

  void _openAK03Form(BuildContext context, AsesiTimelineTerakhir data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsesiAK03FormScreen(
          jadwal: data.toJadwalItem(),
        ),
      ),
    ).then((_) => onRefresh?.call());
  }

  void _openAPL02(BuildContext context, AsesiTimelineTerakhir data, AsesiTimelineStep step) {
    if (step.status == 'completed' || step.statusLabel == 'Menunggu Verifikasi') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HasilReviewPraAsesmenScreen(
            skemaId: data.skemaId,
            title: data.namaSkema,
            kodeSkema: data.kodeSkema,
            tuk: data.tuk,
            tanggalAsesmen: data.tanggalMulai,
          ),
        ),
      ).then((_) => onRefresh?.call());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PraAsesmenScreen(
            skemaId: data.skemaId,
            title: data.namaSkema,
            kodeSkema: data.kodeSkema,
          ),
        ),
      ).then((_) => onRefresh?.call());
    }
  }

  void _showAK02Dialog(BuildContext context, AsesiTimelineTerakhir data, AsesiTimelineStep step) {
    final bool isKompeten = step.statusLabel.contains('(K)');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isKompeten ? Icons.verified_rounded : Icons.info_outline_rounded,
              color: isKompeten ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'FR.AK.02 Rekomendasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.namaSkema,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Status Keputusan: ${step.statusLabel}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isKompeten ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isKompeten
                  ? 'Selamat! Anda direkomendasikan Kompeten pada skema sertifikasi ini.'
                  : 'Hasil asesmen: ${step.statusLabel}. Silakan pantau rekomendasi dari asesor Anda.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (sertifikatList.isNotEmpty || timeline?.isSertifikatTerbit == true)
                    ? 'Sertifikat Kompetensi'
                    : 'Linimasa Asesmen Terakhir',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (sertifikatList.isNotEmpty || timeline?.isSertifikatTerbit == true)
                InkWell(
                  onTap: () => onNavigateToTab?.call(3),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sertifikatList.length > 1
                              ? 'Lihat Semua (${sertifikatList.length})'
                              : 'Lihat Semua',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                )
              else if (timeline?.hasUji == true)
                InkWell(
                  onTap: () => _openDetailJadwal(context, timeline!),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Jadwal',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (isLoading)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (sertifikatList.isNotEmpty || timeline?.isSertifikatTerbit == true)
            _buildSertifikatListSection(context)
          else if (timeline == null || !timeline!.hasUji)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: _buildEmptyState(context),
            )
          else
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: _buildTimelineContent(context, timeline!),
            ),
        ],
      ),
    );
  }

  Widget _buildSertifikatListSection(BuildContext context) {
    final certs = sertifikatList.isNotEmpty
        ? sertifikatList
        : (timeline != null && timeline!.isSertifikatTerbit
            ? [
                SertifikatItem(
                  id: timeline!.asesiId,
                  skema: timeline!.namaSkema,
                  pemegang: '',
                  nomorSertifikat: timeline!.noSertifikat,
                  nomorRegistrasi: timeline!.noRegistrasi,
                  nomorSeri: timeline!.noSeri,
                  tanggalTerbit: timeline!.tanggalTerbit,
                  tanggalBerlaku: timeline!.tanggalBerlaku,
                  status: 'aktif',
                  kategori: timeline!.kodeSkema,
                ),
              ]
            : <SertifikatItem>[]);

    if (certs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Jika <= 3: tampilkan langsung bertumpuk
    if (certs.length <= 3) {
      return Column(
        children: certs
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSertifikatCardFromItem(context, c),
                ))
            .toList(),
      );
    }

    // Jika > 3: batasi dengan virtual scrolling (ListView berbatas tinggi)
    return SizedBox(
      height: 480,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: certs.length,
        itemBuilder: (context, index) {
          final cert = certs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSertifikatCardFromItem(context, cert),
          );
        },
      ),
    );
  }

  Widget _buildSertifikatCardFromItem(BuildContext context, SertifikatItem item) {
    final masaBerlakuStr = (item.tanggalTerbit.isNotEmpty && item.tanggalBerlaku.isNotEmpty)
        ? '${item.tanggalTerbit} s/d ${item.tanggalBerlaku}'
        : (item.tanggalBerlaku.isNotEmpty ? item.tanggalBerlaku : '-');

    final noSeri = item.nomorSeri.isNotEmpty
        ? item.nomorSeri
        : (item.nomorBlanko.isNotEmpty ? item.nomorBlanko : '-');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Skema & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.skema.isNotEmpty ? item.skema : 'Sertifikat Kompetensi',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (item.kategori.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.kategori,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Terbit / Aktif',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Detail rows
          _buildCertDetailRow('No. Sertifikat', item.nomorSertifikat.isNotEmpty ? item.nomorSertifikat : '-'),
          const SizedBox(height: 8),
          _buildCertDetailRow('Nama Skema', item.skema.isNotEmpty ? item.skema : '-'),
          const SizedBox(height: 8),
          _buildCertDetailRow('No. Registrasi', item.nomorRegistrasi.isNotEmpty ? item.nomorRegistrasi : '-'),
          const SizedBox(height: 8),
          _buildCertDetailRow('No. Seri (Blanko)', noSeri),
          const SizedBox(height: 8),
          _buildCertDetailRow('Masa Berlaku', masaBerlakuStr),

          const SizedBox(height: 16),

          // Action Buttons: Buka Sertifikat & Download
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.badge_outlined, size: 16),
                  label: const Text(
                    'Buka Sertifikat',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openECertificateByItem(context, item),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFF334155)),
                  tooltip: 'Unduh E-Certificate',
                  padding: EdgeInsets.zero,
                  onPressed: () => _downloadECertificateByItem(context, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openECertificateByItem(BuildContext context, SertifikatItem item) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final previewUrl = '$baseUrl/api/asesi/e-certificate/view?id_asesi=${item.id}$tokenParam';
    final downloadUrl = item.fileSertifikatDownload.isNotEmpty
        ? item.fileSertifikatDownload
        : '$baseUrl/api/asesi/e-certificate/download?id_asesi=${item.id}$tokenParam';

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ECertificateWebViewScreen(
          title: 'E-Certificate - ${item.skema}',
          previewUrl: previewUrl,
          downloadUrl: downloadUrl,
        ),
      ),
    );
  }

  Future<void> _downloadECertificateByItem(BuildContext context, SertifikatItem item) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final downloadUrl = item.fileSertifikatDownload.isNotEmpty
        ? item.fileSertifikatDownload
        : '$baseUrl/api/asesi/e-certificate/download?id_asesi=${item.id}$tokenParam';

    final uri = Uri.parse(downloadUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan unduh.')),
        );
      }
    }
  }

  Widget _buildCertDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openECertificate(BuildContext context, AsesiTimelineTerakhir data) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final previewUrl = '$baseUrl/api/asesi/e-certificate/view?id_asesi=${data.asesiId}$tokenParam';
    final downloadUrl = '$baseUrl/api/asesi/e-certificate/download?id_asesi=${data.asesiId}$tokenParam';

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ECertificateWebViewScreen(
          title: 'E-Certificate - ${data.namaSkema}',
          previewUrl: previewUrl,
          downloadUrl: downloadUrl,
        ),
      ),
    );
  }

  Future<void> _downloadECertificate(BuildContext context, AsesiTimelineTerakhir data) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final downloadUrl = '$baseUrl/api/asesi/e-certificate/download?id_asesi=${data.asesiId}$tokenParam';

    final uri = Uri.parse(downloadUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan unduh.')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFF64748B),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum Ada Asesmen Terdaftar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar skema sertifikasi untuk memulai uji kompetensi Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => onNavigateToTab?.call(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Pilih Skema Sertifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent(BuildContext context, AsesiTimelineTerakhir data) {
    final statusBgColor = data.statusJadwal == '1'
        ? const Color(0xFFDCFCE7)
        : (data.statusJadwal == '3'
            ? const Color(0xFFDBEAFE)
            : const Color(0xFFFEF3C7));
    final statusTextColor = data.statusJadwal == '1'
        ? const Color(0xFF166534)
        : (data.statusJadwal == '3'
            ? const Color(0xFF1E40AF)
            : const Color(0xFF92400E));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Info
        InkWell(
          onTap: () => _openDetailJadwal(context, data),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.namaSkema.isNotEmpty
                                ? data.namaSkema
                                : data.namaJadwal,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (data.kodeSkema.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              data.kodeSkema,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      data.tanggalMulai.isNotEmpty
                          ? DateFormatHelper.formatToIndonesian(data.tanggalMulai)
                          : '-',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data.tuk.isNotEmpty ? data.tuk : 'TUK Online',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (data.namaAsesor.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Asesor: ${data.namaAsesor}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 14),

        // Steps List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: data.steps.length,
          itemBuilder: (context, index) {
            final step = data.steps[index];
            final isLast = index == data.steps.length - 1;
            return _buildStepItem(context, data, step, isLast);
          },
        ),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    AsesiTimelineTerakhir data,
    AsesiTimelineStep step,
    bool isLast,
  ) {
    Color indicatorColor;
    Color indicatorBgColor;
    IconData indicatorIcon;

    if (step.status == 'completed') {
      indicatorColor = const Color(0xFF16A34A);
      indicatorBgColor = const Color(0xFFDCFCE7);
      indicatorIcon = Icons.check_rounded;
    } else if (step.status == 'in_progress') {
      indicatorColor = const Color(0xFF2563EB);
      indicatorBgColor = const Color(0xFFDBEAFE);
      indicatorIcon = Icons.edit_note_rounded;
    } else if (step.status == 'rejected') {
      indicatorColor = const Color(0xFFDC2626);
      indicatorBgColor = const Color(0xFFFEE2E2);
      indicatorIcon = Icons.close_rounded;
    } else {
      indicatorColor = const Color(0xFF94A3B8);
      indicatorBgColor = const Color(0xFFF1F5F9);
      indicatorIcon = Icons.circle;
    }

    final isUmpanBalikStep = step.key == 'ak03';
    final isSiapIsiUmpanBalik = isUmpanBalikStep && step.status == 'in_progress';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Line & Dot
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: indicatorBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: indicatorColor,
                  width: 1.5,
                ),
              ),
              child: Icon(
                indicatorIcon,
                size: step.status == 'pending' ? 8 : 15,
                color: indicatorColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: isSiapIsiUmpanBalik ? 64 : 44,
                color: step.status == 'completed'
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Step Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: step.canClick
                  ? () {
                      if (step.key == 'ak03') {
                        _openAK03Form(context, data);
                      } else if (step.key == 'apl02') {
                        _openAPL02(context, data, step);
                      } else if (step.key == 'ak02') {
                        _showAK02Dialog(context, data, step);
                      } else {
                        _openDetailJadwal(context, data);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: isSiapIsiUmpanBalik
                    ? BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF93C5FD),
                          width: 1.2,
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: step.isActive
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStepStatusBadge(step),
                        const Spacer(),
                        if (step.canClick)
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (isSiapIsiUmpanBalik) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Isi Umpan Balik Sekarang',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepStatusBadge(AsesiTimelineStep step) {
    Color bg;
    Color fg;

    if (step.status == 'completed') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (step.status == 'in_progress') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (step.status == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        step.statusLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

