import 'package:material_ui/material_ui.dart';

import '../../models/magang_hub_models.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'magang_detail_screen.dart';
import 'widgets/magang_card.dart';

/// Halaman Detail Perusahaan Mitra Magang beserta daftar posisi yang dibuka.
class MagangPerusahaanDetailScreen extends StatefulWidget {
  final MagangPerusahaanItem perusahaan;

  const MagangPerusahaanDetailScreen({
    super.key,
    required this.perusahaan,
  });

  @override
  State<MagangPerusahaanDetailScreen> createState() => _MagangPerusahaanDetailScreenState();
}

class _MagangPerusahaanDetailScreenState extends State<MagangPerusahaanDetailScreen> {
  bool _isLoading = true;
  String? _error;
  List<CareerJobItem> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanyJobs();
  }

  Future<void> _fetchCompanyJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await MagangHubService.getLowongan(
        company: widget.perusahaan.namaPerusahaan,
      );
      if (!mounted) return;
      setState(() {
        _jobs = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat lowongan di ${widget.perusahaan.namaPerusahaan}.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final perusahaan = widget.perusahaan;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Profil Perusahaan',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityCard(perusahaan),
                    if (perusahaan.tentangPerusahaan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildAboutSection(perusahaan.tentangPerusahaan),
                    ],
                    const SizedBox(height: 20),
                    _buildOpeningsHeader(),
                    const SizedBox(height: 10),
                    _buildOpenings(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Identitas perusahaan ringkas: logo kecil di kiri, nama + bidang industri,
  /// lalu baris informasi lokasi dan jumlah lowongan aktif.
  Widget _buildIdentityCard(MagangPerusahaanItem perusahaan) {
    final nama = perusahaan.namaPerusahaan.isNotEmpty ? perusahaan.namaPerusahaan : 'Perusahaan Mitra';
    final kategori =
        perusahaan.kategoriPerusahaan.isNotEmpty ? perusahaan.kategoriPerusahaan : 'Mitra Industri LSP';
    final lokasi = perusahaan.lokasi.isNotEmpty ? perusahaan.lokasi : 'Indonesia';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: perusahaan.logoColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _logoInitials(perusahaan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kategori,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, 'Lokasi', lokasi),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.work_outline_rounded,
            'Lowongan Aktif',
            '${perusahaan.totalLowongan} lowongan',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(String tentang) {
    return Container(
      width: double.infinity,
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
            'Tentang Perusahaan',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tentang,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Program Magang Tersedia',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!_isLoading && _error == null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_jobs.length} Posisi',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOpenings() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFF53A6ED)),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _fetchCompanyJobs,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.school_outlined, size: 36, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10),
            Text(
              'Belum ada lowongan magang yang aktif di perusahaan ini.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _jobs
          .map(
            (job) => MagangJobCard(
              job: job,
              onTap: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MagangDetailScreen(job: job),
                  ),
                );
                if (updated == true) {
                  _fetchCompanyJobs();
                }
              },
            ),
          )
          .toList(),
    );
  }

  /// Inisial logo aman: maksimal 2 karakter, fallback ke huruf pertama nama.
  String _logoInitials(MagangPerusahaanItem perusahaan) {
    final logoText = perusahaan.logoText.trim();
    if (logoText.isNotEmpty) {
      return String.fromCharCodes(logoText.runes.take(2)).toUpperCase();
    }
    final nama = perusahaan.namaPerusahaan.trim();
    if (nama.isNotEmpty) {
      return String.fromCharCodes(nama.runes.take(1)).toUpperCase();
    }
    return 'P';
  }
}
