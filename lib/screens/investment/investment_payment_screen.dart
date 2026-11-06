import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';

class InvestmentPaymentScreen extends StatefulWidget {
  final InvestmentStartupItem startup;

  const InvestmentPaymentScreen({
    super.key,
    required this.startup,
  });

  @override
  State<InvestmentPaymentScreen> createState() =>
      _InvestmentPaymentScreenState();
}

class _InvestmentPaymentScreenState extends State<InvestmentPaymentScreen> {
  late final List<int> _nominals;
  late int _selectedNominal;
  bool _isCustomNominal = false;
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  int _proofType = 0; // 0: Upload Foto, 1: Link Gambar
  File? _selectedFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final min = widget.startup.minimumTicket > 0
        ? widget.startup.minimumTicket
        : 1000000;
    _nominals = [
      min,
      min * 2,
      min * 5,
      min * 10,
    ];
    _selectedNominal = _nominals[0];
    final initStr = NumberFormatHelper.formatWithDots(_selectedNominal);
    _nominalController.value = TextEditingValue(
      text: initStr,
      selection: TextSelection.collapsed(offset: initStr.length),
    );
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  double _calculateEquityShare(int nominal) {
    if (widget.startup.valuation > 0) {
      return (nominal / widget.startup.valuation * 100.0);
    }
    if (widget.startup.targetFunding > 0) {
      final equity = widget.startup.equityOffered > 0
          ? widget.startup.equityOffered
          : 10.0;
      return (nominal / widget.startup.targetFunding * equity);
    }
    return (nominal / 200000000.0 * 10.0);
  }

  Future<void> _pickProofFile() async {
    try {
      final res = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (res != null && res.path != null) {
        setState(() {
          _selectedFile = File(res.path!);
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih file bukti transfer'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedNominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal investasi harus lebih dari 0'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (widget.startup.minimumTicket > 0 &&
        _selectedNominal < widget.startup.minimumTicket) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Nominal minimal investasi adalah Rp ${NumberFormatHelper.formatWithDots(widget.startup.minimumTicket)}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final String linkUrl = _linkController.text.trim();
    if (_proofType == 0 && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah foto bukti transfer terlebih dahulu'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_proofType == 1 && linkUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan link URL gambar bukti transfer'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Dialog Konfirmasi: Apakah Anda Yakin?
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Investasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin data investasi dan bukti transfer sudah sesuai?',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            _buildConfirmRow('Startup', widget.startup.nama),
            const SizedBox(height: 6),
            _buildConfirmRow('Nominal',
                'Rp ${NumberFormatHelper.formatWithDots(_selectedNominal)}'),
            const SizedBox(height: 6),
            _buildConfirmRow('Estimasi Saham',
                '≈ ${_calculateEquityShare(_selectedNominal).toStringAsFixed(1)}%'),
            const SizedBox(height: 6),
            _buildConfirmRow('Metode', 'Wajib Transfer Bank (BCA)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Periksa Lagi',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Ya, Kirim Sekarang',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      String finalBuktiUrl = linkUrl;
      if (_proofType == 0 && _selectedFile != null) {
        final uploaded =
            await InvestmentService.uploadBuktiTransfer(_selectedFile!.path);
        if (uploaded.isEmpty) {
          throw Exception('Gagal mengunggah foto bukti transfer');
        }
        finalBuktiUrl = uploaded;
      }

      final res = await InvestmentService.checkout(
        startupId: int.tryParse(widget.startup.id) ?? 0,
        nominal: _selectedNominal,
        paymentMethod: 'transfer_bank',
        paymentChannel: 'BCA',
        buktiTransferUrl: finalBuktiUrl,
      );
      if (!mounted) return;
      _showSuccessBottomSheet(res);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Gagal memproses transaksi investasi. Silakan coba lagi.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ),
        const Text(': ',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessBottomSheet(InvestmentCheckoutResponse res) {
    final nominalStr = NumberFormatHelper.formatWithDots(
        res.nominal > 0 ? res.nominal : _selectedNominal);
    final equityShare = res.equityPercentage > 0
        ? res.equityPercentage
        : _calculateEquityShare(_selectedNominal);
    final equityStr = equityShare.toStringAsFixed(1);
    final trxCode = res.transactionCode.isNotEmpty ? res.transactionCode : '-';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.paddingOf(ctx).bottom + 20,
        ),
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
                Icons.check_circle_rounded,
                color: Color(0xFF0066F6),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bukti Transfer Terkirim!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Order investasi sebesar Rp $nominalStr (estimasi $equityStr% saham) pada ${widget.startup.nama} berhasil dibuat. Bukti transfer telah diterima dan sedang dalam proses verifikasi tim.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (trxCode != '-') ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kode: $trxCode',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equity = _calculateEquityShare(_selectedNominal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: CustomAppBar(
              title: 'Investasi',
              onBack: () => Navigator.pop(context),
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
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Bukti Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Transfer Bank Resmi LSP Teknologi Digital',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Nominal Investasi (Input + Small Cards)
            const Text(
              'Nominal Investasi',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            // Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066F6),
                  ),
                  hintText: '0',
                  hintStyle:
                      TextStyle(fontSize: 18, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                  final num = int.tryParse(clean) ?? 0;
                  setState(() {
                    _selectedNominal = num;
                    _isCustomNominal = !_nominals.contains(num);
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Card / Chips kecil nominal & Custom di bawah input
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._nominals.map((nom) {
                    final isSel =
                        !_isCustomNominal && _selectedNominal == nom;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCustomNominal = false;
                            _selectedNominal = nom;
                            final nomStr = NumberFormatHelper.formatWithDots(nom);
                            _nominalController.value = TextEditingValue(
                              text: nomStr,
                              selection: TextSelection.collapsed(
                                  offset: nomStr.length),
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF0066F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF0066F6)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            'Rp ${NumberFormatHelper.formatWithDots(nom)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCustomNominal = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isCustomNominal
                            ? const Color(0xFF0066F6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isCustomNominal
                              ? const Color(0xFF0066F6)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _isCustomNominal
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _isCustomNominal
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Estimasi Saham Dinamis
            Row(
              children: [
                const Icon(Icons.pie_chart_outline_rounded,
                    size: 16, color: Color(0xFF0066F6)),
                const SizedBox(width: 6),
                Text(
                  'Estimasi kepemilikan saham: ≈ ${equity.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0066F6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 2: Instruksi Transfer Bank Resmi (Wajib Transfer)
            const Text(
              'Metode Pembayaran (Wajib Transfer Bank)',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            // Card ATM / Bank Style Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066F6), Color(0xFF0F56D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066F6).withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'BANK BCA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: '82201923819'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Nomor rekening berhasil disalin!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded,
                                    size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Salin',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Nomor Rekening',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xD9FFFFFF),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '822-0192-3819',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'a.n. PT LSP Teknologi Digital',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xF2FFFFFF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Lampiran Bukti Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bukti Pembayaran',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProofTypeChip(0, 'Unggah Foto'),
                    const SizedBox(width: 6),
                    _buildProofTypeChip(1, 'Link Gambar'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_proofType == 0) ...[
              GestureDetector(
                onTap: _pickProofFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedFile != null
                          ? const Color(0xFF0066F6)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF0066F6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile != null
                                  ? _selectedFile!.path
                                      .split(RegExp(r'[/\\]'))
                                      .last
                                  : 'Pilih foto bukti transfer',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedFile != null
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _selectedFile != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _selectedFile != null
                                  ? 'Ketuk untuk mengganti foto'
                                  : 'Format JPG, PNG, atau WEBP (Maks 10MB)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedFile != null)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: TextField(
                  controller: _linkController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintText: 'https://example.com/bukti-transfer.jpg',
                    hintStyle:
                        TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.link_rounded,
                        size: 20, color: Color(0xFF64748B)),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 32, minHeight: 20),
                    border: InputBorder.none,
                  ),
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProofTypeChip(int type, String label) {
    final isSelected = _proofType == type;
    return GestureDetector(
      onTap: () => setState(() => _proofType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// Formatter untuk menambahkan pemisah ribuan titik pada input angka secara dinamis.
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final parsed = int.tryParse(cleanDigits) ?? 0;
    final formatted = NumberFormatHelper.formatWithDots(parsed);

    // Hitung posisi kursor baru agar nyaman saat mengetik/menghapus
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
