import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../widgets/career_expo/career_job_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'career_expo_detail_screen.dart';

/// Halaman Daftar Lowongan Favorit / Tersimpan di Career Expo
class CareerExpoFavoritScreen extends StatefulWidget {
  final bool showBackButton;
  const CareerExpoFavoritScreen({super.key, this.showBackButton = true});

  @override
  State<CareerExpoFavoritScreen> createState() => _CareerExpoFavoritScreenState();
}

class _CareerExpoFavoritScreenState extends State<CareerExpoFavoritScreen> {
  bool _isLoading = true;
  String? _error;
  List<CareerJobItem> _favorites = [];

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
      final items = await CareerExpoService.getTersimpan();
      if (!mounted) return;
      setState(() {
        _favorites = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException && e.response != null
            ? 'Gagal memuat lowongan favorit (kode ${e.response?.statusCode}).'
            : 'Tidak bisa terhubung ke server. Periksa koneksi internetmu.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark(CareerJobItem job, bool value) async {
    final prevList = List<CareerJobItem>.from(_favorites);
    setState(() {
      if (!value) {
        _favorites.removeWhere((j) => j.id == job.id);
      } else {
        final idx = _favorites.indexWhere((j) => j.id == job.id);
        if (idx != -1) {
          _favorites[idx] = job.copyWith(isBookmarked: true);
        }
      }
    });

    try {
      await CareerExpoService.setTersimpan(job.id, value);
    } catch (e) {
      if (!mounted) return;
      setState(() => _favorites = prevList);
      final unauthorized = e is DioException && e.response?.statusCode == 401;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unauthorized
                ? 'Silakan login terlebih dahulu untuk menyimpan lowongan.'
                : 'Gagal memperbarui lowongan tersimpan. Coba lagi ya.',
          ),
          behavior: SnackBarBehavior.floating,
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
              title: 'Lowongan Favorit',
              showBack: widget.showBackButton,
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0066F6),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadFavorites,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFavorites,
        color: const Color(0xFF0066F6),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          children: const [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Belum Ada Lowongan Favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Simpan lowongan pekerjaan yang kamu minati untuk memantau atau melamarnya nanti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: const Color(0xFF0066F6),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _favorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = _favorites[index];
          return CareerJobCard(
            job: job,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CareerExpoDetailScreen(job: job),
                ),
              );
              // Refresh after returning from detail in case bookmark was changed
              _loadFavorites();
            },
            onBookmarkToggle: (val) => _toggleBookmark(job, val),
          );
        },
      ),
    );
  }
}
