import 'package:material_ui/material_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/marketing/location_service.dart';

/// Halaman untuk melihat dan mengatur status pencari kerja serta memverifikasi
/// keakuratan titik koordinat tempat tinggal di Google Maps.
class AturLokasiTalentaScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final int initialStatusPencariKerja;

  const AturLokasiTalentaScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialStatusPencariKerja = 0,
  });

  @override
  State<AturLokasiTalentaScreen> createState() => _AturLokasiTalentaScreenState();
}

class _AturLokasiTalentaScreenState extends State<AturLokasiTalentaScreen> {
  GoogleMapController? _mapController;

  double? _latitude;
  double? _longitude;
  String? _locationName;
  int _statusPencariKerja = 0;

  bool _isLoading = true;
  bool _isLocating = false;
  bool _isSaving = false;

  // Default coordinate (Jakarta) hanya sebagai fallback darurat jika GPS dan profil kosong
  static const double _defaultLat = -6.200000;
  static const double _defaultLng = 106.816666;

  @override
  void initState() {
    super.initState();
    _statusPencariKerja = widget.initialStatusPencariKerja;
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;

    _initDefaultLocationAndData();
  }

  /// Inisialisasi: otomatis by default gunakan lokasi perangkat sendiri (GPS),
  /// sambil memuat status profil asesi dari server.
  Future<void> _initDefaultLocationAndData() async {
    // 1. Jika ada cached / last known location dari device, langsung pakai instan
    if (LocationService.lastKnownLocation != null) {
      final cached = LocationService.lastKnownLocation!;
      _latitude = cached.latitude;
      _longitude = cached.longitude;
      if (cached.locationName.isNotEmpty) {
        _locationName = cached.locationName;
      }
    }

    // 2. Muat status profil dari backend
    try {
      final profile = await AsesiService.getProfile();
      if (profile != null && mounted) {
        final status = (profile['status_pencari_kerja'] as num?)?.toInt() ?? 0;
        setState(() {
          _statusPencariKerja = status;
          // Gunakan koordinat profil sebagai fallback jika device location belum didapat
          _latitude ??= (profile['latitude'] as num?)?.toDouble();
          _longitude ??= (profile['longitude'] as num?)?.toDouble();
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }

    // 3. Otomatis deteksi live GPS perangkat secara realtime & pusatkan kamera peta
    await _detectCurrentLocationLive(isInitialLoad: true);
  }

  /// Ambil lokasi live perangkat via GPS dan pusatkan kamera peta
  Future<void> _detectCurrentLocationLive({bool isInitialLoad = false}) async {
    setState(() => _isLocating = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _latitude = loc.latitude;
        _longitude = loc.longitude;
        _isLocating = false;
      });

      _resolveAddress(loc.latitude, loc.longitude);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(loc.latitude, loc.longitude),
              zoom: 16.5,
            ),
          ),
        );
      }

      if (!isInitialLoad && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lokasi Anda terdeteksi: ${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLocating = false);
        if (_latitude != null && _longitude != null) {
          _resolveAddress(_latitude!, _longitude!);
        }
      }
    }
  }

  Future<void> _resolveAddress(double lat, double lng) async {
    try {
      final name = await LocationService.getRealLocationName(lat, lng);
      if (mounted && name.isNotEmpty) {
        setState(() {
          _locationName = name;
        });
      }
    } catch (_) {}
  }

  /// Pengguna dapat mengetuk langsung lokasi di peta untuk memindahkan pin secara presisi
  void _onMapTapped(LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    _resolveAddress(position.latitude, position.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.place_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Titik lokasi dipindahkan sesuai ketukan Anda di peta.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final body = <String, dynamic>{
        'status_pencari_kerja': _statusPencariKerja,
      };
      if (_latitude != null && _longitude != null) {
        body['latitude'] = _latitude;
        body['longitude'] = _longitude;
      }

      final ok = await AsesiService.updateProfile(body);
      if (!mounted) return;

      setState(() => _isSaving = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status talenta dan titik lokasi domisili berhasil disimpan!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan perubahan. Silakan coba lagi.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Terjadi kesalahan saat menyimpan data.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_latitude != null && _longitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('asesi_domisili_marker'),
          position: LatLng(_latitude!, _longitude!),
          draggable: true,
          onDragEnd: (newPos) {
            setState(() {
              _latitude = newPos.latitude;
              _longitude = newPos.longitude;
            });
            _resolveAddress(newPos.latitude, newPos.longitude);
          },
          infoWindow: InfoWindow(
            title: 'Titik Domisili Anda',
            snippet: _locationName ?? 'Ketuk pada peta untuk memindahkan titik',
          ),
        ),
      );
    }
    return markers;
  }

  bool get _isLiveOnMap =>
      (_statusPencariKerja == 1 || _statusPencariKerja == 2) &&
      _latitude != null &&
      _longitude != null;

  @override
  Widget build(BuildContext context) {
    final activeLat = _latitude ?? _defaultLat;
    final activeLng = _longitude ?? _defaultLng;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight > 0 ? 4 : 8),
            // Header Bar Standar App
            const CustomAppBar(
              title: 'Titik Lokasi & Status Talenta',
              rightWidget: SizedBox(width: 48),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Top Google Maps Section
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(activeLat, activeLng),
                              zoom: _latitude != null ? 16.5 : 13.0,
                            ),
                            markers: _buildMarkers(),
                            onMapCreated: (controller) {
                              _mapController = controller;
                              // Jika koordinat sudah ada saat map ready, animasikan kamera
                              if (_latitude != null && _longitude != null) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(_latitude!, _longitude!),
                                    16.5,
                                  ),
                                );
                              }
                            },
                            onTap: _onMapTapped,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          ),

                          // Floating Guide Banner di atas Peta
                          Positioned(
                            top: 10,
                            left: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF2563EB)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Titik otomatis dari lokasi Anda. Ketuk langsung peta untuk menyesuaikan.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating GPS Location button di pojok kanan bawah peta
                          Positioned(
                            bottom: 14,
                            right: 14,
                            child: FloatingActionButton.extended(
                              heroTag: 'detect_gps_fab',
                              onPressed: _isLocating ? null : () => _detectCurrentLocationLive(),
                              backgroundColor: Colors.white,
                              elevation: 3,
                              icon: _isLocating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.my_location_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 18,
                                    ),
                              label: Text(
                                _isLocating ? 'Mendeteksi...' : 'Lokasi Saya',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Configuration Form Section
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Info Titik Koordinat & Alamat Terdeteksi
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _latitude != null ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _latitude != null ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _latitude != null ? Icons.place_rounded : Icons.info_outline_rounded,
                                      color: _latitude != null ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _latitude != null
                                                ? (_locationName ?? 'Lokasi Terpasang')
                                                : 'Mendeteksi Lokasi...',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: _latitude != null ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _latitude != null
                                                ? 'Koordinat: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                                                : 'Sedang mengambil lokasi GPS atau ketuk peta di atas.',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: _latitude != null ? const Color(0xFF16A34A) : const Color(0xFF92400E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 2. Status Kesiapan Kerja
                              const Text(
                                'Status Kesiapan Kerja',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tentukan apakah profil Anda dapat ditemukan oleh pencari talenta di peta.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),

                              _buildStatusOption(
                                value: 1,
                                title: 'Sedang Aktif Mencari Kerja',
                                subtitle: 'Profil Anda tampil di peta & pencarian Talenta (Open to Work)',
                                badgeText: 'Aktif di Peta',
                                badgeColor: const Color(0xFF16A34A),
                                accentColor: const Color(0xFF16A34A),
                              ),
                              const SizedBox(height: 8),

                              _buildStatusOption(
                                value: 2,
                                title: 'Bekerja, tapi Terbuka Peluang Baru',
                                subtitle: 'Profil Anda tampil di peta untuk peluang karir yang lebih baik',
                                badgeText: 'Aktif di Peta',
                                badgeColor: const Color(0xFF2563EB),
                                accentColor: const Color(0xFF2563EB),
                              ),
                              const SizedBox(height: 8),

                              _buildStatusOption(
                                value: 0,
                                title: 'Tidak Sedang Mencari Kerja',
                                subtitle: 'Profil Anda disembunyikan dari peta Talenta',
                                badgeText: 'Disembunyikan',
                                badgeColor: const Color(0xFF64748B),
                                accentColor: const Color(0xFF64748B),
                              ),

                              const SizedBox(height: 18),

                              // 3. Status Ringkasan Muncul di Peta
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isLiveOnMap ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isLiveOnMap ? Icons.verified_rounded : Icons.visibility_off_outlined,
                                      size: 16,
                                      color: _isLiveOnMap ? const Color(0xFF15803D) : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _isLiveOnMap
                                            ? 'Profil Anda akan tampil di peta Talenta Terdekat.'
                                            : 'Profil belum tampil di peta (lengkapi status & titik lokasi).',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: _isLiveOnMap ? const Color(0xFF15803D) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 4. Action Save Button
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _handleSave,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_rounded, size: 20),
                                  label: Text(
                                    _isSaving ? 'Menyimpan...' : 'Simpan Status & Lokasi',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required int value,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color accentColor,
  }) {
    final isSelected = _statusPencariKerja == value;

    return InkWell(
      onTap: () => setState(() => _statusPencariKerja = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : const Color(0xFFCBD5E1),
                  width: isSelected ? 6 : 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
