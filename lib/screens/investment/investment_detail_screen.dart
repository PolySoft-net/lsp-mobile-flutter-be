import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../utils/url_helper.dart';
import '../../widgets/common/company_logo.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/investment/investment_interest_modal.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final InvestmentStartupItem startup;

  const InvestmentDetailScreen({
    super.key,
    required this.startup,
  });

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  late InvestmentStartupItem _startup;
  bool _isTogglingFavorite = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _startup = widget.startup;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    try {
      final updated = await InvestmentService.getStartupDetail(_startup.id);
      if (mounted) {
        setState(() => _startup = updated);
      }
    } catch (_) {
      // Keep static view if detail fetch fails
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isTogglingFavorite = true);
    final nextState = !_startup.isFavorite;
    try {
      await InvestmentService.toggleFavorite(_startup.id, _startup.isFavorite);
        setState(() {
          _startup = _startup.copyWith(isFavorite: nextState);
          _hasChanged = true;
        });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status favorit')),
      );
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  Future<void> _shareStartup() async {
    final text = 'Peluang Investasi Startup: ${_startup.nama} (${_startup.kategori})\n'
        'Target Pendanaan: Rp ${NumberFormatHelper.formatWithDots(_startup.targetFunding)}\n'
        '${_startup.tagline}\n'
        'Cek selengkapnya di aplikasi LSP Digital Mobile.';
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: _startup.nama,
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teks peluang investasi disalin ke clipboard')),
        );
      }
    }
  }

  void _openInterestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvestmentInterestModal(
        startup: _startup,
        onSuccess: () {
          _hasChanged = true;
          _refreshDetail();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetFundingStr = NumberFormatHelper.formatWithDots(_startup.targetFunding);
    final minTicketStr = NumberFormatHelper.formatWithDots(_startup.minimumTicket);
    final valuationStr = _startup.valuation > 0
        ? NumberFormatHelper.formatWithDots(_startup.valuation)
        : '-';

    final double progress = _startup.targetFunding > 0
        ? (_startup.collectedFunding / _startup.targetFunding).clamp(0.0, 1.0)
        : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SafeArea(
            child: CustomAppBar(
              title: 'Detail Startup',
              onBack: () => Navigator.pop(context, _hasChanged),
              rightWidget: IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF0F172A)),
                tooltip: 'Bagikan',
                onPressed: _shareStartup,
              ),
            ),
          ),
        ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompanyLogo(
                        imageUrl: _startup.logoUrl,
                        size: 64,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _startup.nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (_startup.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: Color(0xFF0D9488),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startup.tagline.isNotEmpty
                                  ? _startup.tagline
                                  : _startup.kategori,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChipBadge(_startup.kategori, const Color(0xFF0D9488)),
                      _buildChipBadge(_startup.stage, const Color(0xFF2563EB)),
                      if (_startup.lokasi.isNotEmpty)
                        _buildLocationChip(_startup.lokasi),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Funding Metrics Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pendanaan & Valuasi',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4 Grid boxes
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Target Dana',
                            'Rp $targetFundingStr',
                            const Color(0xFF0D9488),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            'Min. Tiket',
                            'Rp $minTicketStr',
                            const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Valuasi Pra-Investasi',
                            valuationStr != '-' ? 'Rp $valuationStr' : 'Tersedia di Deck',
                            const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            'Ekuitas Ditawarkan',
                            _startup.equityOffered > 0
                                ? '${_startup.equityOffered}%'
                                : 'Negosiasi',
                            const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),

                    if (_startup.collectedFunding > 0) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Komitmen: Rp ${NumberFormatHelper.formatWithDots(_startup.collectedFunding)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% Tercapai',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Business Summary Section
            if (_startup.deskripsi.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Bisnis & Solusi',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _startup.deskripsi,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Traction Section
            if (_startup.traction.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            size: 20,
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Traksi & Pencapaian Utama',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _startup.traction,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Founder Card
            if (_startup.founderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tim Pendiri (Founder)',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage: _startup.founderPhoto.isNotEmpty
                                ? NetworkImage(
                                    UrlHelper.resolveUrl(_startup.founderPhoto))
                                : null,
                            child: _startup.founderPhoto.isEmpty
                                ? const Icon(Icons.person,
                                    size: 26, color: Color(0xFF94A3B8))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _startup.founderName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _startup.founderRole,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_startup.founderPhone.isNotEmpty) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final phone = _startup.founderPhone.replaceAll(RegExp(r'[^0-9]'), '');
                                  final intlPhone = phone.startsWith('0') ? '62${phone.substring(1)}' : phone;
                                  UrlHelper.launchURL('https://wa.me/$intlPhone');
                                },
                                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF0D9488)),
                                label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF0D9488), fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0D9488)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (_startup.founderEmail.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => launchUrl(
                                  Uri.parse('mailto:${_startup.founderEmail}'),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(Icons.email_outlined, size: 16, color: Color(0xFF2563EB)),
                                label: const Text('Email', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF2563EB)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Links Section: Pitch deck & Website
            if (_startup.pitchDeckUrl.isNotEmpty || _startup.websiteUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dokumen & Media Informasi',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_startup.pitchDeckUrl.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.picture_as_pdf_rounded,
                                color: Color(0xFF2563EB), size: 22),
                          ),
                          title: const Text('Pitch Deck Lengkap',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Rincian proyeksi bisnis & market share',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                          onTap: () => UrlHelper.launchURL(_startup.pitchDeckUrl),
                        ),
                      if (_startup.websiteUrl.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.language_rounded,
                                color: Color(0xFF0D9488), size: 22),
                          ),
                          title: const Text('Situs Web Resmi',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text(_startup.websiteUrl,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                          onTap: () => UrlHelper.launchURL(_startup.websiteUrl),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChipBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 13,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            location,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          // Favorite button
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: _isTogglingFavorite
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _startup.isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _startup.isFavorite
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF64748B),
                    ),
              onPressed: _isTogglingFavorite ? null : _toggleFavorite,
            ),
          ),
          const SizedBox(width: 12),

          // Main Action: Ajukan Minat Investasi
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openInterestModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.handshake_outlined,
                    color: Colors.white, size: 20),
                label: const Text(
                  'Ajukan Minat Investasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
