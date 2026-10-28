import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/investment/investment_startup_card.dart';
import 'investment_detail_screen.dart';
import 'investment_form_screen.dart';

class InvestmentMyStartupsScreen extends StatefulWidget {
  const InvestmentMyStartupsScreen({super.key});

  @override
  State<InvestmentMyStartupsScreen> createState() =>
      _InvestmentMyStartupsScreenState();
}

class _InvestmentMyStartupsScreenState
    extends State<InvestmentMyStartupsScreen> {
  bool _isLoading = true;
  String? _error;
  List<InvestmentStartupItem> _myStartups = [];

  @override
  void initState() {
    super.initState();
    _loadMyStartups();
  }

  Future<void> _loadMyStartups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await InvestmentService.getMyStartups();
      if (!mounted) return;
      setState(() {
        _myStartups = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat daftar startup Anda.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Startup Saya',
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const InvestmentFormScreen(),
            ),
          );
          if (res == true) _loadMyStartups();
        },
        backgroundColor: const Color(0xFF0066F6),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Daftarkan Startup',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyStartups,
        color: const Color(0xFF0066F6),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066F6)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMyStartups,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_myStartups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.business_center_outlined,
                size: 54,
                color: Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Startup Terdaftar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Anda belum mendaftarkan startup untuk pendanaan. Daftarkan startup Anda sekarang untuk membuka peluang investasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final res = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InvestmentFormScreen(),
                    ),
                  );
                  if (res == true) _loadMyStartups();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Daftarkan Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _myStartups.length,
      itemBuilder: (context, index) {
        final item = _myStartups[index];
        return InvestmentStartupCard(
          startup: item,
          onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => InvestmentDetailScreen(startup: item),
              ),
            );
            if (updated == true) _loadMyStartups();
          },
        );
      },
    );
  }
}
