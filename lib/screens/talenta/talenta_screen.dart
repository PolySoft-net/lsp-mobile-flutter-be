import 'dart:async';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/talenta_models.dart';
import '../../models/master_models.dart';
import '../../services/talenta/talenta_service.dart';
import '../../services/common/master_service.dart';
import '../../services/marketing/location_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/common/custom_app_bar.dart';

class TalentaScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const TalentaScreen({super.key, this.onBackToHome});

  @override
  State<TalentaScreen> createState() => _TalentaScreenState();
}

class _TalentaScreenState extends State<TalentaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Location state
  UserGeoLocation? _currentGeo;
  String _currentLocationName = 'Mendeteksi lokasi...';
  bool _isDetectingLocation = false;
  bool _isManualLocation = false;

  // Filter state
  int? _selectedSkemaId;
  String _selectedSkemaName = 'Semua Skema';
  List<MasterSkema> _skemaList = [];
  int? _selectedStatusKerja;

  // Data state
  List<TalentaItem> _talentaList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _isError = false;
  String _errorMessage = '';
  int _offset = 0;
  static const int _limit = 20;

  // Map & View mode state
  bool _isMapView = true;
  GoogleMapController? _mapController;
  TalentaItem? _selectedMapTalenta;
  static const LatLng _defaultCenter = LatLng(-2.5489, 118.0149);

  Timer? _searchDebounce;
  bool _isScrollThrottled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
    _mapController?.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _fetchTalenta(isRefresh: true);
      }
    });
  }

  void _onScroll() {
    if (_isScrollThrottled) return;
    _isScrollThrottled = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      _isScrollThrottled = false;
      if (!mounted) return;
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!_isLoading && !_isLoadingMore && _hasMore) {
          _fetchTalenta(isRefresh: false);
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Fetch master skema
    try {
      final skemas = await MasterService.getMasterSkemaList();
      if (mounted) {
        setState(() {
          _skemaList = skemas;
        });
      }
    } catch (_) {}

    // If LocationService already warmed up location in splash screen, use it instantly!
    if (LocationService.lastKnownLocation != null) {
      final cached = LocationService.lastKnownLocation!;
      if (mounted) {
        setState(() {
          _isManualLocation = false;
          _currentGeo = cached;
          _currentLocationName = cached.locationName;
        });
        _fetchTalenta(isRefresh: true);
      }
    } else {
      // Auto-detect GPS location via Google Maps Geocoding
      await _detectLocation();
    }
  }

  Future<void> _detectLocation() async {
    if (_isDetectingLocation) return;
    setState(() {
      _isDetectingLocation = true;
      _currentLocationName = 'Mendeteksi lokasi GPS...';
    });

    try {
      final geo = await LocationService.getCurrentLocation();
      final realName = await LocationService.getRealLocationName(
        geo.latitude,
        geo.longitude,
      );

      if (mounted) {
        setState(() {
          _isManualLocation = false;
          _currentGeo = geo;
          _currentLocationName =
              realName.isNotEmpty ? realName : geo.locationName;
          _isDetectingLocation = false;
        });
        _fetchTalenta(isRefresh: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationName = 'Lokasi gagal dideteksi';
          _isDetectingLocation = false;
        });
        _fetchTalenta(isRefresh: true);
      }
    }
  }

  void _onManualLocationSelected(UserGeoLocation geo, {String? customName}) {
    setState(() {
      _isManualLocation = true;
      _currentGeo = geo;
      _currentLocationName = customName ?? geo.locationName;
    });
    _fetchTalenta(isRefresh: true);
  }

  Future<void> _fetchTalenta({required bool isRefresh}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
        _offset = 0;
      });
    } else {
      if (_isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final res = await TalentaService.getTalenta(
        lat: _currentGeo?.latitude,
        lng: _currentGeo?.longitude,
        skemaId: _selectedSkemaId,
        statusPencariKerja: _selectedStatusKerja,
        search: _searchController.text.trim(),
        limit: _limit,
        offset: _offset,
      );

      if (!mounted) return;

      setState(() {
        if (isRefresh) {
          _talentaList = res.data;
        } else {
          _talentaList.addAll(res.data);
        }
        _offset += res.data.length;
        _hasMore = res.meta.hasMore;
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (_isMapView && _mapController != null) {
        _fitMapBounds();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = 'Gagal memuat data talenta. Periksa koneksi internet Anda.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _showSkemaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSkemas = _skemaList.where((s) {
              final q = searchQuery.toLowerCase();
              return s.namaSkema.toLowerCase().contains(q) ||
                  s.kodeSkema.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Skema Sertifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (_selectedSkemaId != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSkemaId = null;
                              _selectedSkemaName = 'Semua Skema';
                            });
                            Navigator.pop(ctx);
                            _fetchTalenta(isRefresh: true);
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau kode skema...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredSkemas.length + 1,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedSkemaId == null;
                          return ListTile(
                            title: const Text('Semua Skema'),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedSkemaId = null;
                                _selectedSkemaName = 'Semua Skema';
                              });
                              Navigator.pop(ctx);
                              _fetchTalenta(isRefresh: true);
                            },
                          );
                        }

                        final skema = filteredSkemas[index - 1];
                        final isSelected = _selectedSkemaId == skema.id;

                        return ListTile(
                          title: Text(
                            skema.namaSkema,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: skema.kodeSkema.isNotEmpty
                              ? Text(skema.kodeSkema, style: const TextStyle(fontSize: 12))
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedSkemaId = skema.id;
                              _selectedSkemaName = skema.namaSkema;
                            });
                            Navigator.pop(ctx);
                            _fetchTalenta(isRefresh: true);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _launchWhatsApp(String rawPhone, {String? name}) async {
    final clean = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor WhatsApp tidak tersedia'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    String formatted = clean;
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    } else if (!formatted.startsWith('62')) {
      formatted = '62$formatted';
    }

    final greeting = name != null && name.isNotEmpty
        ? 'Halo $name, saya melihat profil Anda di Talenta LSP Digital.'
        : 'Halo, saya melihat profil Anda di Talenta LSP Digital.';
    final uri = Uri.parse('https://wa.me/$formatted?text=${Uri.encodeComponent(greeting)}');

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp terpasang.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(String email, {String? name}) async {
    final clean = email.trim();
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat email tidak tersedia'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final subject = Uri.encodeComponent('Peluang Kerja / Talenta LSP Digital');
    final body = Uri.encodeComponent(
      name != null && name.isNotEmpty
          ? 'Halo $name,\n\nSaya melihat profil Anda di aplikasi Talenta LSP Digital dan berminat untuk mendiskusikan peluang kerja sama.\n\nSalam,'
          : 'Halo,\n\nSaya melihat profil Anda di aplikasi Talenta LSP Digital.\n\nSalam,',
    );
    final uri = Uri.parse('mailto:$clean?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka aplikasi Email.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }
  void _showManualLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        List<UserGeoLocation> searchResults = [];
        bool isSearching = false;
        Timer? debounce;
        final searchController = TextEditingController();

        // Master Wilayah state
        List<MasterItem> provList = [];
        List<MasterItem> filteredProvList = [];
        List<MasterItem> kabList = [];
        List<MasterItem> filteredKabList = [];
        MasterItem? selectedProv;
        bool isLoadingMaster = false;
        bool isMasterView = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            void performSearch(String q) {
              debounce?.cancel();
              if (q.trim().isEmpty) {
                setModalState(() {
                  searchQuery = '';
                  searchResults = [];
                  isSearching = false;
                });
                return;
              }

              debounce = Timer(const Duration(milliseconds: 350), () async {
                setModalState(() {
                  isSearching = true;
                  searchQuery = q.trim();
                });

                final results = await LocationService.searchLocations(q.trim());
                if (ctx.mounted) {
                  setModalState(() {
                    searchResults = results;
                    isSearching = false;
                  });
                }
              });
            }

            void loadProvinces() async {
              setModalState(() {
                isLoadingMaster = true;
                isMasterView = true;
                selectedProv = null;
              });
              try {
                final list = await MasterService.getProvinsiList();
                if (ctx.mounted) {
                  setModalState(() {
                    provList = list;
                    filteredProvList = list;
                    isLoadingMaster = false;
                  });
                }
              } catch (_) {
                if (ctx.mounted) {
                  setModalState(() => isLoadingMaster = false);
                }
              }
            }

            void filterProvinces(String q) {
              setModalState(() {
                if (q.trim().isEmpty) {
                  filteredProvList = provList;
                } else {
                  filteredProvList = provList
                      .where((p) =>
                          p.name.toLowerCase().contains(q.toLowerCase()))
                      .toList();
                }
              });
            }

            void loadKabupaten(MasterItem prov) async {
              setModalState(() {
                selectedProv = prov;
                isLoadingMaster = true;
              });
              try {
                final list = await MasterService.getKabupatenList(prov.id);
                if (ctx.mounted) {
                  setModalState(() {
                    kabList = list;
                    filteredKabList = list;
                    isLoadingMaster = false;
                  });
                }
              } catch (_) {
                if (ctx.mounted) {
                  setModalState(() => isLoadingMaster = false);
                }
              }
            }

            void filterKabupaten(String q) {
              setModalState(() {
                if (q.trim().isEmpty) {
                  filteredKabList = kabList;
                } else {
                  filteredKabList = kabList
                      .where((k) =>
                          k.name.toLowerCase().contains(q.toLowerCase()))
                      .toList();
                }
              });
            }

            void selectKabupaten(MasterItem kab) async {
              Navigator.pop(ctx);
              final query = '${kab.name}, ${selectedProv?.name ?? ''}';
              final results = await LocationService.searchLocations(query);
              if (results.isNotEmpty) {
                _onManualLocationSelected(results.first, customName: kab.name);
              } else {
                _onManualLocationSelected(
                  UserGeoLocation(
                    latitude: LocationService.defaultLat,
                    longitude: LocationService.defaultLng,
                    locationName: kab.name,
                  ),
                  customName: kab.name,
                );
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMasterView
                            ? (selectedProv == null
                                ? 'Pilih Provinsi'
                                : 'Pilih Kabupaten/Kota')
                            : 'Pilih Lokasi Manual',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMasterView
                        ? (selectedProv == null
                            ? 'Pilih provinsi dari master wilayah'
                            : 'Provinsi: ${selectedProv!.name}')
                        : 'Cari kota/wilayah atau pilih dari master data',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),

                  // GPS Reset Shortcut
                  if (_isManualLocation && !isMasterView) ...[
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _detectLocation();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.my_location_rounded,
                                size: 18, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kembali Gunakan Lokasi GPS Saya',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (!isMasterView) ...[
                    // Dynamic Search Box
                    TextField(
                      controller: searchController,
                      onChanged: performSearch,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama kota, kabupaten, atau alamat...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: Color(0xFF64748B)),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  performSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Content Area: Search results or Master Button
                    Expanded(
                      child: isSearching
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            )
                          : searchQuery.isNotEmpty
                              ? searchResults.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.location_off_rounded,
                                              size: 40,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Lokasi "$searchQuery" tidak ditemukan',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Coba gunakan nama kota atau kabupaten lain',
                                            style: TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: searchResults.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = searchResults[index];
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.location_on_rounded,
                                              color: Color(0xFF2563EB),
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            item.locationName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Koordinat: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _onManualLocationSelected(item);
                                          },
                                        );
                                      },
                                    )
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      InkWell(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        onTap: loadProvinces,
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEFF6FF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.account_balance_rounded,
                                                  size: 22,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Pilih dari Master Wilayah',
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      'Daftar resmi Provinsi & Kabupaten/Kota',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 36),
                                      Center(
                                        child: Text(
                                          'Ketik nama kota atau daerah pada kolom di atas untuk mencari secara langsung.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                    ),
                  ] else ...[
                    // Master Wilayah Selection View
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (selectedProv != null) {
                              setModalState(() {
                                selectedProv = null;
                                kabList = [];
                                filteredKabList = [];
                              });
                            } else {
                              setModalState(() {
                                isMasterView = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: selectedProv == null
                                ? filterProvinces
                                : filterKabupaten,
                            decoration: InputDecoration(
                              hintText: selectedProv == null
                                  ? 'Cari nama provinsi...'
                                  : 'Cari kabupaten/kota...',
                              hintStyle: const TextStyle(
                                  fontSize: 12.5, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  size: 18, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isLoadingMaster
                          ? const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : selectedProv == null
                              ? ListView.separated(
                                  itemCount: filteredProvList.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, idx) {
                                    final prov = filteredProvList[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(prov.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                      trailing: const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: Color(0xFF94A3B8)),
                                      onTap: () => loadKabupaten(prov),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  itemCount: filteredKabList.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, idx) {
                                    final kab = filteredKabList[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(kab.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                      trailing: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 18,
                                        color: Color(0xFF2563EB),
                                      ),
                                      onTap: () => selectKabupaten(kab),
                                    );
                                  },
                                ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAdminPlottingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final searchController = TextEditingController();
        final latController = TextEditingController(
          text: _currentGeo?.latitude != null ? _currentGeo!.latitude.toString() : '',
        );
        final lngController = TextEditingController(
          text: _currentGeo?.longitude != null ? _currentGeo!.longitude.toString() : '',
        );

        List<Map<String, dynamic>> searchResults = [];
        Map<String, dynamic>? selectedAsesi;
        int statusPencariKerja = 1;
        bool isSearching = false;
        bool isSaving = false;
        Timer? debounce;
        bool hasLoadedInitial = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!hasLoadedInitial && searchResults.isEmpty && !isSearching) {
              hasLoadedInitial = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                setModalState(() => isSearching = true);
                final res = await TalentaService.searchAsesiAdmin('');
                if (ctx.mounted) {
                  setModalState(() {
                    searchResults = res;
                    isSearching = false;
                  });
                }
              });
            }

            void onSearchChanged(String val) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () async {
                setModalState(() => isSearching = true);
                final res = await TalentaService.searchAsesiAdmin(val.trim());
                if (ctx.mounted) {
                  setModalState(() {
                    searchResults = res;
                    isSearching = false;
                  });
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_pin_circle_rounded,
                            color: Color(0xFF16A34A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plotting Lokasi Asesi (Admin)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Pilih asesi yang sudah ada dan tentukan titik koordinatnya',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    const Text(
                      '1. Pilih Asesi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedAsesi == null) ...[
                      TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Ketik nama asesi (contoh: HANAFI)...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: searchResults.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    isSearching ? 'Mencari asesi...' : 'Tidak ada asesi ditemukan',
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: searchResults.length,
                                separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (_, i) {
                                  final item = searchResults[i];
                                  final nama = item['nama_lengkap']?.toString() ?? '-';
                                  final skema = item['skema']?.toString() ?? '';
                                  final hasCoords = item['latitude'] != null && item['longitude'] != null;

                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      nama,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    subtitle: Text(
                                      skema.isNotEmpty ? skema : 'Skema belum terdaftar',
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: hasCoords
                                        ? const Tooltip(
                                            message: 'Sudah memiliki koordinat',
                                            child: Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                                          )
                                        : null,
                                    onTap: () {
                                      setModalState(() {
                                        selectedAsesi = item;
                                        if (item['latitude'] != null) {
                                          latController.text = item['latitude'].toString();
                                        }
                                        if (item['longitude'] != null) {
                                          lngController.text = item['longitude'].toString();
                                        }
                                        final currentStatus = (item['status_pencari_kerja'] as num?)?.toInt() ?? 0;
                                        if (currentStatus > 0) {
                                          statusPencariKerja = currentStatus;
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF16A34A),
                              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedAsesi!['nama_lengkap']?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedAsesi!['skema']?.toString() ?? 'Skema belum terdaftar',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedAsesi = null;
                                });
                              },
                              child: const Text('Ganti', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      '2. Status Pencari Kerja',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: statusPencariKerja,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(
                                'Sedang aktif mencari kerja (Open to Work)',
                                style: TextStyle(fontSize: 13, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(
                                'Bekerja, tapi terbuka untuk peluang baru',
                                style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 0,
                              child: Text(
                                'Tidak sedang mencari kerja',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => statusPencariKerja = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '3. Titik Koordinat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (_currentGeo?.latitude != null && _currentGeo?.longitude != null)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                latController.text = _currentGeo!.latitude.toString();
                                lngController.text = _currentGeo!.longitude.toString();
                              });
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.my_location_rounded, size: 14, color: Color(0xFF2563EB)),
                                SizedBox(width: 4),
                                Text(
                                  'Pakai Lokasi Saya',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              hintText: '-2.5399...',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: lngController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              hintText: '112.942...',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: (isSaving || selectedAsesi == null)
                            ? null
                            : () async {
                                final lat = double.tryParse(latController.text.trim());
                                final lng = double.tryParse(lngController.text.trim());

                                if (lat == null || lng == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Masukkan koordinat latitude dan longitude yang valid'),
                                      backgroundColor: Color(0xFFDC2626),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);
                                final id = selectedAsesi!['id'] as int;
                                final success = await TalentaService.updateAsesiLokasiAdmin(
                                  id: id,
                                  latitude: lat,
                                  longitude: lng,
                                  statusPencariKerja: statusPencariKerja,
                                );

                                if (!ctx.mounted) return;
                                setModalState(() => isSaving = false);

                                if (success) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lokasi & status ${selectedAsesi!['nama_lengkap']} berhasil disimpan ke Talenta!'),
                                      backgroundColor: const Color(0xFF16A34A),
                                    ),
                                  );
                                  _fetchTalenta(isRefresh: true);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal memperbarui data asesi'),
                                      backgroundColor: Color(0xFFDC2626),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Simpan ke Talenta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _fitMapBounds() {
    if (_mapController == null) return;

    final itemsWithCoords = _talentaList.where((t) => t.hasCoordinates).toList();
    if (itemsWithCoords.isEmpty) {
      if (_currentGeo != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentGeo!.latitude, _currentGeo!.longitude),
            13.5,
          ),
        );
      }
      return;
    }

    double minLat = _currentGeo?.latitude ?? itemsWithCoords.first.latitude!;
    double maxLat = minLat;
    double minLng = _currentGeo?.longitude ?? itemsWithCoords.first.longitude!;
    double maxLng = minLng;

    for (final item in itemsWithCoords) {
      if (item.latitude! < minLat) minLat = item.latitude!;
      if (item.latitude! > maxLat) maxLat = item.latitude!;
      if (item.longitude! < minLng) minLng = item.longitude!;
      if (item.longitude! > maxLng) maxLng = item.longitude!;
    }

    if ((maxLat - minLat).abs() < 0.001 && (maxLng - minLng).abs() < 0.001) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14.0),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          60.0,
        ),
      );
    }
  }

  Set<Marker> _buildMapMarkers() {
    final Set<Marker> markers = {};

    // User location marker
    if (_currentGeo != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentGeo!.latitude, _currentGeo!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          zIndexInt: 5,
          infoWindow: InfoWindow(
            title: 'Posisi Anda Saat Ini',
            snippet: _currentLocationName,
          ),
        ),
      );
    }

    final Map<String, int> coordCounts = {};
    for (final item in _talentaList) {
      if (!item.hasCoordinates) continue;

      final key = '${item.latitude!.toStringAsFixed(4)}_${item.longitude!.toStringAsFixed(4)}';
      final duplicateIndex = coordCounts[key] ?? 0;
      coordCounts[key] = duplicateIndex + 1;

      double lat = item.latitude!;
      double lng = item.longitude!;
      if (duplicateIndex > 0) {
        final angle = (duplicateIndex * 60) * (math.pi / 180);
        lat += 0.00015 * duplicateIndex * math.cos(angle);
        lng += 0.00015 * duplicateIndex * math.sin(angle);
      }

      final isSelected = _selectedMapTalenta?.id == item.id;
      final double markerHue = item.statusPencariKerja == 1
          ? BitmapDescriptor.hueGreen
          : (item.statusPencariKerja == 2
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueOrange);

      markers.add(
        Marker(
          markerId: MarkerId('talenta_${item.id}'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          zIndexInt: isSelected ? 10 : 2,
          infoWindow: InfoWindow(
            title: item.pemegang,
            snippet: '${item.skema}${item.jarakLabel.isNotEmpty ? " • ${item.jarakLabel}" : ""}',
            onTap: () {
              setState(() {
                _selectedMapTalenta = item;
              });
            },
          ),
          onTap: () {
            setState(() {
              _selectedMapTalenta = item;
            });
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(lat, lng)),
            );
          },
        ),
      );
    }

    return markers;
  }

  Widget _buildMapTalentaPreviewCard(TalentaItem item) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildTalentaCard(item),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMapTalenta = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    final LatLng initialCenter = _currentGeo != null
        ? LatLng(_currentGeo!.latitude, _currentGeo!.longitude)
        : _defaultCenter;
    final double initialZoom = _currentGeo != null ? 13.0 : 5.0;

    final itemsWithCoords = _talentaList.where((t) => t.hasCoordinates).toList();

    return Stack(
      children: [
        // 1. Full Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialCenter,
            zoom: initialZoom,
          ),
          markers: _buildMapMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapBounds();
          },
          onTap: (_) {
            if (_selectedMapTalenta != null) {
              setState(() {
                _selectedMapTalenta = null;
              });
            }
          },
        ),

        // 2. Floating Filter Overlay on top
        Positioned(
          top: 10,
          left: 14,
          right: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Cari nama pemegang sertifikat...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _fetchTalenta(isRefresh: true);
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Filter Chips: Skema & Status Kerja
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Skema Filter Chip
                    InkWell(
                      onTap: _showSkemaPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedSkemaId != null ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedSkemaId != null ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 14,
                              color: _selectedSkemaId != null ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedSkemaId != null ? _selectedSkemaName : 'Semua Skema',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _selectedSkemaId != null ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: _selectedSkemaId != null ? Colors.white : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Semua',
                      isSelected: _selectedStatusKerja == null,
                      onTap: () {
                        setState(() => _selectedStatusKerja = null);
                        _fetchTalenta(isRefresh: true);
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Aktif Mencari',
                      isSelected: _selectedStatusKerja == 1,
                      onTap: () {
                        setState(() => _selectedStatusKerja = 1);
                        _fetchTalenta(isRefresh: true);
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Bekerja',
                      isSelected: _selectedStatusKerja == 2,
                      onTap: () {
                        setState(() => _selectedStatusKerja = 2);
                        _fetchTalenta(isRefresh: true);
                      },
                    ),
                  ],
                ),
              ),

              if (itemsWithCoords.isEmpty && !_isLoading) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Belum ada talenta dengan koordinat GPS pada filter ini. Gunakan mode list untuk melihat semua.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 3. Floating Re-Center GPS Button
        Positioned(
          bottom: _selectedMapTalenta != null ? 175 : 80,
          right: 16,
          child: GestureDetector(
            onTap: () {
              if (_currentGeo != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_currentGeo!.latitude, _currentGeo!.longitude),
                    15.0,
                  ),
                );
              } else {
                _detectLocation();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
          ),
        ),

        // 4. Floating Talent Preview Card (when a marker is tapped)
        if (_selectedMapTalenta != null)
          Positioned(
            bottom: 8,
            left: 14,
            right: 14,
            child: _buildMapTalentaPreviewCard(_selectedMapTalenta!),
          ),

        // 5. Loading indicator badge
        if (_isLoading)
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Memuat talenta terdekat...',
                      style: TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUserInstance;
    final bool isAdmin = user != null && (user.role == 'admin' || user.roles.contains('admin'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedMapTalenta != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                  if (_isMapView) {
                    _selectedMapTalenta = null;
                  }
                });
                if (_isMapView) {
                  Future.delayed(const Duration(milliseconds: 250), () {
                    _fitMapBounds();
                  });
                }
              },
              backgroundColor: const Color(0xFF0F172A),
              elevation: 4,
              icon: Icon(
                _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                _isMapView ? 'Tampilkan Mode List' : 'Tampilkan Mode Peta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Talenta Terdekat',
              onBack: widget.onBackToHome ?? () => Navigator.of(context).pop(),
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdmin) ...[
                    GestureDetector(
                      onTap: _showAdminPlottingModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 15),
                            SizedBox(width: 4),
                            Text(
                              'Plot Asesi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Switch button: Peta vs List
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMapView = !_isMapView;
                        if (_isMapView) {
                          _selectedMapTalenta = null;
                        }
                      });
                      if (_isMapView) {
                        Future.delayed(const Duration(milliseconds: 250), () {
                          _fitMapBounds();
                        });
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _isMapView ? const Color(0xFF2563EB) : const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isMapView ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Icon(
                        _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_rounded,
                        color: _isMapView ? Colors.white : const Color(0xFF2563EB),
                        size: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showManualLocationPicker,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Icon(
                        Icons.edit_location_alt_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isMapView
                  ? _buildMapView()
                  : RefreshIndicator(
        onRefresh: () => _fetchTalenta(isRefresh: true),
        color: const Color(0xFF2563EB),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header: GPS Location Banner & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Card
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isManualLocation
                                      ? const Color(0xFFF5F3FF)
                                      : const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isManualLocation
                                      ? Icons.pin_drop_rounded
                                      : Icons.location_on_rounded,
                                  color: _isManualLocation
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _isManualLocation
                                                ? 'Lokasi Pilihan Manual'
                                                : 'Posisi Anda Saat Ini',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: _isManualLocation
                                                ? const Color(0xFFFAF5FF)
                                                : const Color(0xFFEFF6FF),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _isManualLocation
                                                  ? const Color(0xFFDDD6FE)
                                                  : const Color(0xFFBFDBFE),
                                            ),
                                          ),
                                          child: Text(
                                            _isManualLocation
                                                ? 'Manual'
                                                : 'GPS',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: _isManualLocation
                                                  ? const Color(0xFF7C3AED)
                                                  : const Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentLocationName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Deteksi GPS
                              Expanded(
                                child: InkWell(
                                  onTap: _isDetectingLocation
                                      ? null
                                      : _detectLocation,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: !_isManualLocation
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: !_isManualLocation
                                            ? const Color(0xFFBFDBFE)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: _isDetectingLocation
                                        ? const Center(
                                            child: SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.my_location_rounded,
                                                  size: 14,
                                                  color: Color(0xFF2563EB)),
                                              SizedBox(width: 5),
                                              Text(
                                                'Deteksi GPS',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Pilih Manual
                              Expanded(
                                child: InkWell(
                                  onTap: _showManualLocationPicker,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _isManualLocation
                                          ? const Color(0xFFFAF5FF)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _isManualLocation
                                            ? const Color(0xFFDDD6FE)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.edit_location_alt_rounded,
                                          size: 14,
                                          color: _isManualLocation
                                              ? const Color(0xFF7C3AED)
                                              : const Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Pilih Manual',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: _isManualLocation
                                                ? const Color(0xFF7C3AED)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama pemegang sertifikat...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _fetchTalenta(isRefresh: true);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Skema Filter Chip/Selector
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _showSkemaPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedSkemaId != null
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedSkemaId != null
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 18,
                              color: _selectedSkemaId != null
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedSkemaName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedSkemaId != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedSkemaId != null
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Semua Pencari Kerja',
                            isSelected: _selectedStatusKerja == null,
                            onTap: () {
                              setState(() => _selectedStatusKerja = null);
                              _fetchTalenta(isRefresh: true);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Aktif Mencari Kerja',
                            isSelected: _selectedStatusKerja == 1,
                            onTap: () {
                              setState(() => _selectedStatusKerja = 1);
                              _fetchTalenta(isRefresh: true);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Bekerja (Buka Peluang)',
                            isSelected: _selectedStatusKerja == 2,
                            onTap: () {
                              setState(() => _selectedStatusKerja = 2);
                              _fetchTalenta(isRefresh: true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content: Loading / Error / Empty / List
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              )
            else if (_isError)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchTalenta(isRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_talentaList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum Ada Talenta Ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tidak ada pemegang sertifikat yang sesuai filter. Coba ubah kata kunci atau ganti skema sertifikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _talentaList[index];
                      return _buildTalentaCard(item);
                    },
                    childCount: _talentaList.length,
                  ),
                ),
              ),

            // Pagination loader
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 76)),
          ],
        ),
      ),
    ),
  ],
),
),
);
  }

  void _showTalentaDetailModal(TalentaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        item.pemegang.isNotEmpty ? item.pemegang[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.pemegang,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.skema.isNotEmpty ? item.skema : 'Skema belum terdaftar',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isAktif
                            ? const Color(0xFFDCFCE7)
                            : (item.status == 'proses'
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isAktif
                            ? 'Sertifikat Aktif'
                            : (item.status == 'proses' ? 'Proses / Belum Terbit' : 'Kadaluarsa'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: item.isAktif
                              ? const Color(0xFF16A34A)
                              : (item.status == 'proses'
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFDC2626)),
                        ),
                      ),
                    ),
                    if (item.statusPencariKerja == 1 || item.statusPencariKerja == 2)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.statusPencariKerja == 1
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.statusPencariKerja == 1
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Text(
                          item.statusPencariKerja == 1
                              ? 'Sedang Aktif Mencari Kerja'
                              : 'Bekerja, Terbuka Peluang',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: item.statusPencariKerja == 1
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    if (item.jarakLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              item.jarakLabel,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                const Text(
                  'Informasi Sertifikasi & Kompetensi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('Bidang / Kategori', item.kategori.isNotEmpty ? item.kategori : '-'),
                _buildDetailRow('Nomor Sertifikat', item.nomorSertifikat.isNotEmpty ? item.nomorSertifikat : '-'),
                _buildDetailRow('Nomor Registrasi', item.nomorRegistrasi.isNotEmpty ? item.nomorRegistrasi : '-'),
                _buildDetailRow('Tanggal Terbit', item.tanggalTerbit.isNotEmpty ? item.tanggalTerbit : '-'),
                _buildDetailRow('Tanggal Berlaku', item.tanggalBerlaku.isNotEmpty ? item.tanggalBerlaku : '-'),
                const SizedBox(height: 14),
                const Text(
                  'Informasi Lokasi & Wilayah',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('Wilayah / Lokasi', item.lokasi.isNotEmpty ? item.lokasi : '-'),
                if (item.provinsi.isNotEmpty) _buildDetailRow('Provinsi', item.provinsi),
                if (item.kabupaten.isNotEmpty) _buildDetailRow('Kabupaten / Kota', item.kabupaten),
                if (item.hasCoordinates)
                  _buildDetailRow(
                    'Titik Koordinat',
                    '${item.latitude!.toStringAsFixed(6)}, ${item.longitude!.toStringAsFixed(6)}',
                  ),
                if (item.hasKontak) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Kontak Pemegang / Asesi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (item.telp.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 140,
                            child: Text(
                              'WhatsApp / No. HP',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ),
                          const Text(': ', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                          Expanded(
                            child: Text(
                              item.telp,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF16A34A)),
                            tooltip: 'Kirim WhatsApp',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _launchWhatsApp(item.telp, name: item.pemegang),
                          ),
                        ],
                      ),
                    ),
                  if (item.email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 140,
                            child: Text(
                              'Email',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ),
                          const Text(': ', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                          Expanded(
                            child: Text(
                              item.email,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF2563EB)),
                            tooltip: 'Kirim Email',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _launchEmail(item.email, name: item.pemegang),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (item.telp.isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF16A34A)),
                          label: const Text(
                            'WhatsApp',
                            style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBBF7D0)),
                            backgroundColor: const Color(0xFFF0FDF4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _launchWhatsApp(item.telp, name: item.pemegang),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (item.email.isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.email_outlined, size: 15, color: Color(0xFF2563EB)),
                          label: const Text(
                            'Email',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            backgroundColor: const Color(0xFFEFF6FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _launchEmail(item.email, name: item.pemegang),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF334155),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalentaCard(TalentaItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTalentaDetailModal(item),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Distance Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pemegang,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.skema,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.jarakLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        item.jarakLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Location & Category
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.lokasi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isAktif
                      ? const Color(0xFFDCFCE7)
                      : (item.status == 'proses'
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isAktif
                      ? 'Aktif'
                      : (item.status == 'proses' ? 'Proses' : 'Kadaluarsa'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.isAktif
                        ? const Color(0xFF16A34A)
                        : (item.status == 'proses'
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFDC2626)),
                  ),
                ),
              ),
              if (item.statusPencariKerja == 1 || item.statusPencariKerja == 2) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.statusPencariKerja == 1
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.statusPencariKerja == 1
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Text(
                    item.statusPencariKerja == 1
                        ? 'Cari Kerja'
                        : 'Buka Peluang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.statusPencariKerja == 1
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Certificate info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No. Sertifikat',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.nomorSertifikat.isNotEmpty ? item.nomorSertifikat : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Masa Berlaku',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.tanggalBerlaku.isNotEmpty ? item.tanggalBerlaku : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Contact actions if logged in, or hint if guest
          const SizedBox(height: 12),
          if (item.hasKontak) ...[
            Row(
              children: [
                if (item.telp.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBBF7D0)),
                        backgroundColor: const Color(0xFFF0FDF4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _launchWhatsApp(item.telp, name: item.pemegang),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.email.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.email_outlined, size: 14, color: Color(0xFF2563EB)),
                      label: const Text(
                        'Email',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _launchEmail(item.email, name: item.pemegang),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF475569)),
                  label: const Text(
                    'Detail',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: () => _showTalentaDetailModal(item),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF2563EB)),
                label: const Text(
                  'Lihat Informasi',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  backgroundColor: const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => _showTalentaDetailModal(item),
              ),
            ),
          ],
        ],
      ),
    ),
  ),
),
);
  }
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
