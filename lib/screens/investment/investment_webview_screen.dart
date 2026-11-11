import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/url_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Screen untuk menampilkan Website Startup dan Dokumen Pitch Deck via in-app WebView
/// dilengkapi tombol untuk membuka di browser eksternal.
class InvestmentWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const InvestmentWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InvestmentWebViewScreen> createState() => _InvestmentWebViewScreenState();
}

class _InvestmentWebViewScreenState extends State<InvestmentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  String get _resolvedUrl => UrlHelper.resolveUrl(widget.url);

  /// URL yang dimuat di WebView.
  /// Jika file berupa PDF, gunakan Google Docs Viewer agar WebView Android/iOS
  /// dapat merender dokumen secara langsung tanpa download paksa.
  String get _displayUrl {
    final raw = _resolvedUrl.trim();
    final lower = raw.toLowerCase();
    if (lower.endsWith('.pdf') || lower.contains('.pdf?')) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(raw)}';
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final targetUrl = _displayUrl;
    final uri = Uri.tryParse(targetUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      );

    if (uri != null && uri.hasScheme) {
      _controller.loadRequest(uri);
    } else {
      _hasError = true;
      _errorMessage = 'Tautan URL tidak valid';
    }
  }

  Future<void> _openInExternalBrowser() async {
    final target = _resolvedUrl;
    if (target.isEmpty) return;
    final success = await UrlHelper.launchURL(context, target);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka browser eksternal'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _copyUrlToClipboard() async {
    final target = _resolvedUrl;
    if (target.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: target));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan berhasil disalin ke clipboard!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: widget.title,
              onBack: () => Navigator.pop(context),
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_browser_rounded, size: 22, color: Color(0xFF0066F6)),
                    tooltip: 'Buka di Browser',
                    onPressed: _openInExternalBrowser,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF0F172A)),
                    onSelected: (val) {
                      if (val == 'browser') {
                        _openInExternalBrowser();
                      } else if (val == 'copy') {
                        _copyUrlToClipboard();
                      } else if (val == 'refresh') {
                        _controller.reload();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'browser',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF0066F6)),
                            SizedBox(width: 10),
                            Text('Buka di Browser Eksternal', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 18, color: Color(0xFF64748B)),
                            SizedBox(width: 10),
                            Text('Salin Tautan', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF64748B)),
                            SizedBox(width: 10),
                            Text('Muat Ulang', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyUrlToClipboard,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text(
                      'Salin Tautan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openInExternalBrowser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.open_in_browser_rounded, size: 17, color: Colors.white),
                    label: const Text(
                      'Buka di Browser',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal Memuat Halaman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage.isNotEmpty ? _errorMessage : 'Pastikan perangkat terhubung ke internet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _controller.reload(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Coba Lagi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0066F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _openInExternalBrowser,
                          icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                          label: const Text('Buka di Browser', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066F6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading && !_hasError)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                minHeight: 3,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066F6)),
              ),
            ),
        ],
      ),
    );
  }
}
