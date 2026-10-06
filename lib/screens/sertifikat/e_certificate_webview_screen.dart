import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/api_routes.dart';
import '../../widgets/common/custom_app_bar.dart';
class ECertificateWebViewScreen extends StatefulWidget {
  final String title;
  final String previewUrl;
  final String? downloadUrl;
  final String? publicUrl;
  final String? printUrl;

  const ECertificateWebViewScreen({
    super.key,
    required this.title,
    required this.previewUrl,
    this.downloadUrl,
    this.publicUrl,
    this.printUrl,
  });
  @override
  State<ECertificateWebViewScreen> createState() => _ECertificateWebViewScreenState();
}

class _ECertificateWebViewScreenState extends State<ECertificateWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
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
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.previewUrl));
  }

  Future<void> _handleShare() async {
    String shareLink = widget.publicUrl ?? '';
    if (shareLink.isEmpty) {
      final uri = Uri.tryParse(widget.previewUrl);
      if (uri != null) {
        final idAsesi = uri.queryParameters['id_asesi'];
        if (idAsesi != null && idAsesi.isNotEmpty) {
          shareLink = ApiRoutes.digitalSignaturePublicUrl(idAsesi);
        } else {
          final queryParams = Map<String, String>.from(uri.queryParameters);
          queryParams.remove('token');
          shareLink = uri.replace(queryParameters: queryParams.isEmpty ? null : queryParams).toString();
        }
      } else {
        shareLink = widget.previewUrl;
      }
    }

    try {
      final text = 'Berikut adalah tautan verifikasi resmi E-Sertifikasi: $shareLink';
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: widget.title.isNotEmpty ? widget.title : 'E-Sertifikasi',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: shareLink));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan verifikasi berhasil disalin.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF1E293B),
          ),
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    String targetUrl = widget.printUrl ?? '';
    if (targetUrl.isEmpty) {
      final uri = Uri.tryParse(widget.previewUrl);
      final idAsesi = uri?.queryParameters['id_asesi'];
      if (idAsesi != null && idAsesi.isNotEmpty) {
        targetUrl = ApiRoutes.digitalSignaturePrintUrl(idAsesi);
      } else if (widget.downloadUrl != null && widget.downloadUrl!.isNotEmpty) {
        targetUrl = widget.downloadUrl!;
      } else {
        targetUrl = widget.previewUrl;
      }
    }

    final uri = Uri.parse(targetUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan cetak / unduh.')),
        );
      }
    }
  }

  Future<void> _handleOpenBrowser() async {
    final targetUrl = (widget.publicUrl != null && widget.publicUrl!.isNotEmpty)
        ? widget.publicUrl!
        : widget.previewUrl;
    final uri = Uri.parse(targetUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka browser eksternal.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'E-Sertifikasi',
              onBack: () => Navigator.of(context).pop(),
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Color(0xFF64748B), size: 20),
                    tooltip: 'Bagikan',
                    onPressed: _handleShare,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 20),
                    tooltip: 'Unduh E-Sertifikasi',
                    onPressed: _handleDownload,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF64748B), size: 20),
                    tooltip: 'Buka di Browser',
                    onPressed: _handleOpenBrowser,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                backgroundColor: Colors.transparent,
                color: const Color(0xFF2563EB),
                minHeight: 2,
              ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: const Color(0xFFF8FAFC),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF2563EB)),
                          SizedBox(height: 14),
                          Text(
                            'Memuat E-Sertifikasi...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
