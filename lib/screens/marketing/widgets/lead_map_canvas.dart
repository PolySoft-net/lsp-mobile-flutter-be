import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/location_service.dart';

class LeadMapCanvas extends StatefulWidget {
  final List<PlaceResult> places;
  final PlaceResult? selectedPlace;
  final UserGeoLocation? userLocation;
  final Set<String> savedPlaceIds;
  final Set<String> savedNames;
  final Function(PlaceResult place) onSelectPlace;
  final VoidCallback onSearchArea;
  final Future<void> Function()? onMyLocationPressed;
  final bool isLoading;

  const LeadMapCanvas({
    super.key,
    required this.places,
    this.selectedPlace,
    this.userLocation,
    this.savedPlaceIds = const {},
    this.savedNames = const {},
    required this.onSelectPlace,
    required this.onSearchArea,
    this.onMyLocationPressed,
    this.isLoading = false,
  });

  @override
  State<LeadMapCanvas> createState() => _LeadMapCanvasState();
}

class _LeadMapCanvasState extends State<LeadMapCanvas> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  bool _mapInitFailed = false;
  int _mapInstanceId = 0;
  Timer? _mapInitTimer;

  // Default Center (Jakarta fallback)
  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);
  static const Duration _mapInitTimeout = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _startMapInitWatchdog();
  }

  @override
  void dispose() {
    _mapInitTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Google Maps SDK yang gagal init (Google Play Services rusak / API key
  /// ditolak) TIDAK pernah dilaporkan ke sisi Dart oleh plugin
  /// google_maps_flutter — `onMapCreated` hanya dipanggil saat berhasil.
  /// Watchdog ini yang mendeteksi kegagalan supaya canvas tidak menggantung
  /// kosong tanpa penjelasan.
  void _startMapInitWatchdog() {
    _mapInitTimer?.cancel();
    _mapInitTimer = Timer(_mapInitTimeout, () {
      if (!mounted || _isMapReady) return;
      setState(() => _mapInitFailed = true);
    });
  }

  /// Buang instance GoogleMap yang gagal lalu pasang ulang (platform view baru).
  void _retryMapInit() {
    setState(() {
      _mapInitFailed = false;
      _isMapReady = false;
      _mapController = null;
      _mapInstanceId++;
    });
    _startMapInitWatchdog();
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // Pengganti layer 'myLocationEnabled' bawaan SDK: posisi user tetap
    // terlihat tanpa membuka location source milik Google Play Services.
    if (widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('lead_user_location'),
          position: LatLng(
            widget.userLocation!.latitude,
            widget.userLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          zIndexInt: 4,
          infoWindow: const InfoWindow(title: 'Posisi Anda Saat Ini'),
        ),
      );
    }

    for (final place in widget.places) {
      final isSelected = widget.selectedPlace?.placeId == place.placeId;
      final isSaved = widget.savedPlaceIds.contains(place.placeId) ||
          widget.savedNames.contains(place.name.toLowerCase().trim());

      final double markerHue = isSaved
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueRed;

      final String statusTag =
          isSaved ? '✓ [Tersimpan di Prospek]' : '[Calon Prospek Baru]';

      markers.add(
        Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          zIndexInt: isSelected ? 3 : (isSaved ? 2 : 1),
          infoWindow: InfoWindow(
            title: '${isSaved ? "✓ " : ""}${place.name}',
            snippet:
                '$statusTag ${place.inferredCategory} • Rating: ${place.rating > 0 ? place.rating : "-"}',
            onTap: () => widget.onSelectPlace(place),
          ),
          onTap: () => widget.onSelectPlace(place),
        ),
      );
    }

    return markers;
  }

  void _animateCamera() {
    if (!_isMapReady || _mapController == null) return;

    if (widget.selectedPlace != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.selectedPlace!.latitude,
            widget.selectedPlace!.longitude,
          ),
          15.0,
        ),
      );
    } else if (widget.userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.userLocation!.latitude,
            widget.userLocation!.longitude,
          ),
          14.0,
        ),
      );
    } else if (widget.places.isNotEmpty) {
      final first = widget.places.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(first.latitude, first.longitude),
          13.5,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant LeadMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlace?.placeId != widget.selectedPlace?.placeId ||
        oldWidget.userLocation?.latitude != widget.userLocation?.latitude ||
        oldWidget.userLocation?.longitude != widget.userLocation?.longitude ||
        oldWidget.savedPlaceIds.length != widget.savedPlaceIds.length ||
        oldWidget.places.length != widget.places.length) {
      _animateCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget = _defaultCenter;
    if (widget.userLocation != null) {
      initialTarget = LatLng(
        widget.userLocation!.latitude,
        widget.userLocation!.longitude,
      );
    } else if (widget.places.isNotEmpty) {
      initialTarget = LatLng(
        widget.places.first.latitude,
        widget.places.first.longitude,
      );
    }

    if (_mapInitFailed) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF1F5F9),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 44, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'Peta tidak dapat dimuat',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Layanan Google Maps tidak tersedia di perangkat ini. Pencarian prospek tetap dapat dilakukan lewat daftar hasil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _retryMapInit,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 12.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      key: ValueKey('lead-map-$_mapInstanceId'),
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 13.5,
      ),
      onMapCreated: (controller) {
        // Sudah jatuh ke fallback: controller ini milik view yang dibuang.
        if (_mapInitFailed) return;
        _mapInitTimer?.cancel();
        _mapController = controller;
        _isMapReady = true;
        _animateCamera();
      },
      markers: _buildMarkers(),
      // myLocationEnabled memaksa Maps SDK membuka location source milik Google
      // Play Services sendiri — jalur yang memunculkan loop DEVELOPER_ERROR di
      // perangkat dengan GMS bermasalah. Tombol lokasi di overlay induk tetap
      // berfungsi lewat onMyLocationPressed + marker userLocation.
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
    );
  }
}
