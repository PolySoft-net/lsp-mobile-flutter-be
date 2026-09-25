import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sertifikat_models.dart';
import '../../services/api_service.dart';
import '../../widgets/sertifikat/sertifikat_list_item.dart';
import '../../widgets/sertifikat/sertifikat_tab_bar.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'detail_sertifikat_screen.dart';

class AsesiSertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesiSertifikatScreen({super.key, this.onBackToHome});

  @override
  State<AsesiSertifikatScreen> createState() => _AsesiSertifikatScreenState();
}

class _AsesiSertifikatScreenState extends State<AsesiSertifikatScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<SertifikatItem> _allSertifikats = [];
  Map<String, dynamic> _meta = const {};
  String? _errorMessage;
  int _currentTab = 0;

  List<SertifikatItem> get _filteredSertifikats {
    final query = _searchController.text.trim().toLowerCase();
    
    // Filter by tab
    final tabFiltered = _allSertifikats.where((item) {
      final status = item.status.toLowerCase();
      if (_currentTab == 0) {
        return status == 'aktif';
      } else if (_currentTab == 1) {
        return status == 'akan_kadaluarsa';
      } else {
        return status == 'kadaluarsa' || (status != 'aktif' && status != 'akan_kadaluarsa');
      }
    }).toList();

    // Filter by search query
    if (query.isEmpty) {
      return tabFiltered;
    } else {
      return tabFiltered.where((item) {
        return item.skema.toLowerCase().contains(query) ||
            item.nomorRegistrasi.toLowerCase().contains(query) ||
            item.nomorSertifikat.toLowerCase().contains(query) ||
            item.nomorBlanko.toLowerCase().contains(query);
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await AsesiService.getSertifikatList();
      final list = results['data'] as List<dynamic>;
      final mappedResults =
          list.map((e) => SertifikatItem.fromJson(e as Map<String, dynamic>)).toList();

      setState(() {
        _allSertifikats = mappedResults;
        _meta = results['meta'] as Map<String, dynamic>? ?? const {};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading initial certificates: $e');
      setState(() {
        _allSertifikats = [];
        _errorMessage = 'Gagal memuat daftar sertifikat.';
        _isLoading = false;
      });
    }
  }

  void _handleSearchInstant(String val) {
    setState(() {});
  }

  Future<void> _handleDownloadCertificate(SertifikatItem item) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menghubungi server untuk unduh ${item.skema}...'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );

      final url = await AsesiService.downloadSertifikat(item.id);
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        try {
          if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            return; // Success
          }
          if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
            return; // Fallback success
          }
        } catch (e) {
          // Launch failed for both modes
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka link download.'),
              backgroundColor: Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sertifikat belum dapat diunduh.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching download URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat mengunduh.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Counter tab dibaca langsung dari agregasi kanonikal backend (`meta`).
    final int aktifCount = (_meta['total_aktif'] as num?)?.toInt() ?? 0;
    final int akanBerakhirCount = (_meta['total_akan_kadaluarsa'] as num?)?.toInt() ?? 0;
    final int kadaluarsaCount = (_meta['total_kadaluarsa'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Sertifikat',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SertifikatTabBar(
              currentTab: _currentTab,
              aktifCount: aktifCount,
              akanBerakhirCount: akanBerakhirCount,
              kadaluarsaCount: kadaluarsaCount,
              onTabChanged: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
            ),
          ),

          _buildSearchBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: _buildLoadingWidget(),
                    ),

                  if (!_isLoading && _errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: _buildErrorWidget(),
                    ),

                  if (!_isLoading && _errorMessage == null) ...[
                    if (_filteredSertifikats.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                        child: Center(
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'Sertifikat tidak ditemukan.'
                                : 'Tidak ada sertifikat di tab ini.',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 12.0),
                        child: Text(
                          'Sertifikat Terdaftar (${_filteredSertifikats.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _filteredSertifikats.length,
                        itemBuilder: (context, index) {
                          final item = _filteredSertifikats[index];
                          return SertifikatListItem(
                            item: item,
                            onView: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailSertifikatScreen(
                                    item: item,
                                    isAsesiView: true,
                                  ),
                                ),
                              );
                            },
                            onDownload: () => _handleDownloadCertificate(item),
                          );
                        },
                      ),
                    ],
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchInstant,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan skema atau nomor registrasi...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                _searchController.clear();
                _handleSearchInstant('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF3B82F6)),
          SizedBox(height: 12),
          Text(
            'Mencari data sertifikat...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5).withAlpha(127)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
