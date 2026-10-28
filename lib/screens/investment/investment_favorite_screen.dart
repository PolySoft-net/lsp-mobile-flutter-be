import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/investment/investment_startup_card.dart';
import 'investment_detail_screen.dart';

class InvestmentFavoriteScreen extends StatefulWidget {
  const InvestmentFavoriteScreen({super.key});

  @override
  State<InvestmentFavoriteScreen> createState() =>
      _InvestmentFavoriteScreenState();
}

class _InvestmentFavoriteScreenState extends State<InvestmentFavoriteScreen> {
  bool _isLoading = true;
  String? _error;
  List<InvestmentStartupItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await InvestmentService.getFavoriteStartups();
      if (!mounted) return;
      setState(() {
        _favorites = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat daftar startup favorit.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(InvestmentStartupItem startup) async {
    final nextState = !startup.isFavorite;
    try {
      await InvestmentService.toggleFavorite(startup.id, startup.isFavorite);
      if (!mounted) return;
      _loadFavorites();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nextState
              ? 'Gagal menyimpan favorit'
              : 'Gagal menghapus favorit'),
        ),
      );
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
              title: 'Startup Favorit',
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
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
                onPressed: _loadFavorites,
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

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.bookmark_border_rounded,
                size: 54,
                color: Color(0xFFCBD5E1),
              ),
              SizedBox(height: 14),
              Text(
                'Belum Ada Startup Favorit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tandai startup yang menarik bagi Anda untuk menyimpannya di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        return InvestmentStartupCard(
          startup: item,
          onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => InvestmentDetailScreen(startup: item),
              ),
            );
            if (updated == true) _loadFavorites();
          },
          onToggleFavorite: () => _toggleFavorite(item),
        );
      },
    );
  }
}
