import 'package:material_ui/material_ui.dart';
import '../../screens/talenta/atur_lokasi_talenta_screen.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/marketing/location_service.dart';

/// Banner interaktif di Dashboard Asesi.
/// Saat diketuk, membuka halaman AturLokasiTalentaScreen untuk melihat peta
/// Google Maps interaktif, mengecek akurasi lokasi, dan memilih status pencari kerja.
class AsesiTalentaStatusCard extends StatefulWidget {
  final VoidCallback? onUpdated;

  const AsesiTalentaStatusCard({
    super.key,
    this.onUpdated,
  });

  @override
  State<AsesiTalentaStatusCard> createState() => _AsesiTalentaStatusCardState();
}

class _AsesiTalentaStatusCardState extends State<AsesiTalentaStatusCard> {
  double? _latitude;
  double? _longitude;
  String? _locationName;
  int _statusPencariKerja = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await AsesiService.getProfile();
      if (!mounted) return;

      if (profile != null) {
        final lat = (profile['latitude'] as num?)?.toDouble();
        final lng = (profile['longitude'] as num?)?.toDouble();
        final status = (profile['status_pencari_kerja'] as num?)?.toInt() ?? 0;

        setState(() {
          _latitude = lat;
          _longitude = lng;
          _statusPencariKerja = status;
          _isLoading = false;
        });

        if (lat != null && lng != null) {
          _resolveLocationName(lat, lng);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resolveLocationName(double lat, double lng) async {
    try {
      final name = await LocationService.getRealLocationName(lat, lng);
      if (mounted && name.isNotEmpty) {
        setState(() {
          _locationName = name;
        });
      }
    } catch (_) {}
  }

  bool get _isLiveOnMap =>
      (_statusPencariKerja == 1 || _statusPencariKerja == 2) &&
      _latitude != null &&
      _longitude != null;

  String get _statusLabel {
    switch (_statusPencariKerja) {
      case 1:
        return 'Aktif Mencari Kerja (Open to Work)';
      case 2:
        return 'Bekerja, tapi Terbuka Peluang';
      default:
        return 'Tidak Sedang Mencari Kerja';
    }
  }

  Future<void> _navigateToDetail() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AturLokasiTalentaScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialStatusPencariKerja: _statusPencariKerja,
        ),
      ),
    );

    if (result == true) {
      _loadProfileData();
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isLiveOnMap ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
          width: _isLiveOnMap ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isLiveOnMap
                ? const Color(0xFF16A34A).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _navigateToDetail,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isLiveOnMap ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isLiveOnMap ? Icons.person_pin_circle_rounded : Icons.add_location_alt_rounded,
                    color: _isLiveOnMap ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Titik Domisili & Status Kerja',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isLiveOnMap
                                  ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                                  : const Color(0xFFD97706).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _isLiveOnMap ? 'Peta: Aktif' : 'Peta: Belum Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isLiveOnMap ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _statusPencariKerja == 1
                              ? const Color(0xFF16A34A)
                              : (_statusPencariKerja == 2
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            size: 13,
                            color: _latitude != null ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              _latitude != null
                                  ? (_locationName ?? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}')
                                  : 'Ketuk untuk atur titik lokasi di Google Maps',
                              style: TextStyle(
                                fontSize: 11,
                                color: _latitude != null ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                fontStyle: _latitude != null ? FontStyle.normal : FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow indicator
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
