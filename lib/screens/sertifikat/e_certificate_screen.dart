import 'package:material_ui/material_ui.dart';
import '../../models/sertifikat_models.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/api_client.dart';
import '../../services/auth/token_storage.dart';
import 'e_certificate_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ECertificateScreen extends StatefulWidget {
  const ECertificateScreen({super.key});

  @override
  State<ECertificateScreen> createState() => _ECertificateScreenState();
}

class _ECertificateScreenState extends State<ECertificateScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<SertifikatItem> _allCertificates = [];
  List<SertifikatItem> _filteredCertificates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AsesiService.getSertifikatList();
      final list = result['data'] as List<dynamic>? ?? [];
      final parsed = list
          .map((e) => SertifikatItem.fromJson(e as Map<String, dynamic>))
          .where((item) => item.nomorSertifikat.isNotEmpty)
          .toList();

      setState(() {
        _allCertificates = parsed;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading e-certificates: $e');
      setState(() {
        _allCertificates = [];
        _filteredCertificates = [];
        _errorMessage = 'Gagal memuat daftar E-Certificate.';
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredCertificates = List.from(_allCertificates);
    } else {
      _filteredCertificates = _allCertificates.where((item) {
        return item.skema.toLowerCase().contains(query) ||
            item.nomorSertifikat.toLowerCase().contains(query) ||
            item.pemegang.toLowerCase().contains(query) ||
            item.nomorRegistrasi.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _openWebView(String title, String previewUrl, String downloadUrl) {
    if (previewUrl.isEmpty && downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan E-Certificate tidak tersedia.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ECertificateWebViewScreen(
          title: title,
          previewUrl: previewUrl.isNotEmpty ? previewUrl : downloadUrl,
          downloadUrl: downloadUrl.isNotEmpty ? downloadUrl : previewUrl,
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url, String skema) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan unduh.')),
        );
      }
    }
  }

  Future<void> _openECertificate(SertifikatItem item) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final previewUrl = '$baseUrl/api/asesi/e-certificate/view?id_asesi=${item.id}$tokenParam';
    final downloadUrl = item.fileSertifikatDownload.isNotEmpty
        ? item.fileSertifikatDownload
        : '$baseUrl/api/asesi/e-certificate/download?id_asesi=${item.id}$tokenParam';

    if (!mounted) return;
    _openWebView('E-Certificate - ${item.skema}', previewUrl, downloadUrl);
  }

  Future<void> _downloadECertificate(SertifikatItem item) async {
    final token = await TokenStorage.instance.getAccessToken();
    final baseUrl = ApiClient.baseUrl;
    final tokenParam = token != null && token.isNotEmpty ? '&token=$token' : '';
    final downloadUrl = item.fileSertifikatDownload.isNotEmpty
        ? item.fileSertifikatDownload
        : '$baseUrl/api/asesi/e-certificate/download?id_asesi=${item.id}$tokenParam';

    await _downloadFile(downloadUrl, item.skema);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'E-Certificate',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF2563EB),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(_applySearch),
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama, skema, no. sertifikat...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(_applySearch);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    )
                  : (_errorMessage != null)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFF64748B)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _filteredCertificates.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.card_membership_rounded,
                                        size: 32,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Belum Ada E-Certificate',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Dokumen digital sertifikat belum diunggah oleh admin LSP atau akun Anda belum memiliki sertifikat digital aktif.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _filteredCertificates.length,
                              itemBuilder: (context, index) {
                                final item = _filteredCertificates[index];
                                return _buildECertificateCard(item);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildECertificateCard(SertifikatItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pemegang.isNotEmpty ? item.pemegang : 'Asesi',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKEMA : ${item.skema}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Certificate Info Rows
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No. Sertifikat',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.nomorSertifikat.isNotEmpty ? item.nomorSertifikat : '-',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Berlaku Hingga',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.tanggalBerlaku.isNotEmpty ? item.tanggalBerlaku : '-',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Buka E-Certificate (single view) & Download
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.badge_outlined, size: 16),
                  label: const Text(
                    'Buka E-Certificate',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openECertificate(item),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFF334155)),
                  tooltip: 'Unduh E-Certificate',
                  padding: EdgeInsets.zero,
                  onPressed: () => _downloadECertificate(item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
