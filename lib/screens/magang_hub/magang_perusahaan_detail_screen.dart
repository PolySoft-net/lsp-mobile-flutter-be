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
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Profil Perusahaan Mitra',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.perusahaan.logoColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.perusahaan.logoText.isNotEmpty
                                ? widget.perusahaan.logoText
                                : (widget.perusahaan.namaPerusahaan.isNotEmpty
                                    ? widget.perusahaan.namaPerusahaan.substring(0, 1).toUpperCase()
                                    : 'P'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.perusahaan.namaPerusahaan,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.perusahaan.kategoriPerusahaan.isNotEmpty
                              ? widget.perusahaan.kategoriPerusahaan
                              : 'Mitra Industri LSP',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              widget.perusahaan.lokasi.isNotEmpty ? widget.perusahaan.lokasi : 'Indonesia',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        if (widget.perusahaan.tentangPerusahaan.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 14),
                          Text(
                            widget.perusahaan.tentangPerusahaan,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Open Vacancies Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Program Magang Tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_jobs.length} Posisi',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Text(_error!, style: const TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _fetchCompanyJobs,
                              child: const Text('Coba Lagi', style: TextStyle(color: Color(0xFF7C3AED))),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_jobs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.school_outlined, size: 40, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada lowongan magang yang aktif di perusahaan ini.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._jobs.map((job) => MagangJobCard(
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
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
