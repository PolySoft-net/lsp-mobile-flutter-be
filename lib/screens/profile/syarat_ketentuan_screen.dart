import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Syarat & Ketentuan',
            rightWidget: SizedBox(width: 32),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/syarat_1.png',
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(height: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Syarat & Ketentuan Layanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Dengan menggunakan layanan LSP Teknologi Digital dan Career Expo, Anda telah menyetujui seluruh syarat dan ketentuan berikut.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildRuleCard(
                    icon: Icons.person_rounded,
                    title: 'Akun Pengguna',
                    description:
                        'Anda wajib mendaftar dan memberikan informasi yang lengkap, benar, dan terbaru. Akun hanya boleh digunakan oleh pemilik identitas yang terdaftar.',
                  ),
                  _buildRuleCard(
                    icon: Icons.work_outline_rounded,
                    title: 'Layanan Career Expo & Sertifikasi',
                    description:
                        'LSP Teknologi Digital menyediakan portal lowongan kerja terkurasi serta sertifikasi kompetensi sesuai standar BNSP. Informasi lowongan dan jadwal dapat diperbarui sewaktu-waktu.',
                  ),
                  _buildRuleCard(
                    icon: Icons.folder_shared_rounded,
                    title: 'Keaslian Dokumen & Resume',
                    description:
                        'Anda bertanggung jawab penuh atas keabsahan CV, sertifikat, dan berkas portofolio yang diunggah. Pemalsuan dokumen berakibat pada diskualifikasi langsung.',
                  ),
                  _buildRuleCard(
                    icon: Icons.gavel_rounded,
                    title: 'Etika & Proses Lamaran',
                    description:
                        'Pelamar wajib bersikap profesional dalam komunikasi dan wawancara dengan perusahaan mitra serta menaati seluruh tata tertib rekrutmen.',
                  ),
                  _buildRuleCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Ketentuan Pembayaran',
                    description:
                        'Biaya administrasi atau uji kompetensi yang telah dibayarkan bersifat final sesuai regulasi resmi LSP Teknologi Digital.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF0066F6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
