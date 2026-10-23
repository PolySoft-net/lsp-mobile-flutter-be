import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/portal_banner_model.dart';
import '../../services/career_expo/career_expo_service.dart';
import '../../services/magang_hub/magang_hub_service.dart';
import '../../utils/url_helper.dart';

class CareerPortalBanner extends StatefulWidget {
  final bool isMagang;
  final VoidCallback? onSeeMore;

  const CareerPortalBanner({
    super.key,
    this.isMagang = false,
    this.onSeeMore,
  });

  @override
  State<CareerPortalBanner> createState() => _CareerPortalBannerState();
}

class _CareerPortalBannerState extends State<CareerPortalBanner>
    with WidgetsBindingObserver {
  PortalBanner _banner = const PortalBanner();
  bool _loading = false;
  String? _error;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    _expiryTimer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final banner = widget.isMagang
          ? await MagangHubService.getBanner()
          : await CareerExpoService.getBanner();
      if (!mounted) return;
      setState(() => _banner = banner);
      if (banner.remainingSeconds > 0) {
        _expiryTimer = Timer(Duration(seconds: banner.remainingSeconds), _load);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Banner gagal dimuat.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(child: Text(_error!)),
          TextButton(onPressed: _load, child: const Text('Muat ulang')),
        ]),
      );
    }
    if (_banner.imageUrl.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isMagang ? 'Magang Hub' : 'Siap Naik Level Karir\ndi Dunia Digital?',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isMagang
                      ? 'Temukan kesempatan magang terbaik untuk membangun karirmu.'
                      : 'Dapatkan Pekerjaan Sesuai Dengan Kompetensimu.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                TextButton(onPressed: widget.onSeeMore, child: const Text('Lihat Lebih')),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: Image.network(
                  UrlHelper.resolveUrl(_banner.imageUrl),
                  fit: BoxFit.cover,
                  semanticLabel: widget.isMagang ? 'Banner Magang Hub' : 'Banner Career Expo',
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Gambar gagal dimuat', textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
