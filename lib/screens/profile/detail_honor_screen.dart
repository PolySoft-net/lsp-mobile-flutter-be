import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/auth/auth_repository.dart';

class DetailHonorScreen extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String status;
  final String metodePembayaran;
  final String tanggalPembayaran;
  final String noTransfer;
  final int jumlahAsesmen;

  const DetailHonorScreen({
    super.key,
    required this.detail,
    required this.status,
    required this.metodePembayaran,
    required this.tanggalPembayaran,
    required this.noTransfer,
    required this.jumlahAsesmen,
  });

  @override
  State<DetailHonorScreen> createState() => _DetailHonorScreenState();
}

class _DetailHonorScreenState extends State<DetailHonorScreen> {
  late String _currentStatus;
  late TextEditingController _buktiUrlController;

  bool get _isAdmin {
    final role = AuthRepository.currentUserInstance?.role.toLowerCase();
    return role == 'admin' || role == 'pengelola' || (role != null && role != 'asesor' && role != 'asesi' && role.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    if (_currentStatus.toLowerCase() == 'selesai' || _currentStatus.toLowerCase() == 'complete' || _currentStatus == 'Pembayaran Selesai') {
      _currentStatus = 'Pembayaran Selesai';
    } else {
      _currentStatus = 'Menunggu Pembayaran';
    }
    final initialBukti = widget.detail['link_bukti_pembayaran']?.toString() ??
        (widget.detail['lampiran_bukti'] is Map
            ? widget.detail['lampiran_bukti']['file_url']?.toString()
            : null) ??
        '';
    _buktiUrlController = TextEditingController(text: initialBukti);
  }

  @override
  void dispose() {
    _buktiUrlController.dispose();
    super.dispose();
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Status Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pilih status pembayaran honor untuk penugasan ini',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusSelectOption(
                    sheetContext: context,
                    statusValue: 'Pembayaran Selesai',
                    title: 'Pembayaran Selesai',
                    description: 'Honor telah ditransfer dan diverifikasi lunas',
                    icon: Icons.check_circle_rounded,
                    activeColor: const Color(0xFF10B981),
                    activeBgColor: const Color(0xFFECFDF5),
                  ),
                  _buildStatusSelectOption(
                    sheetContext: context,
                    statusValue: 'Menunggu Pembayaran',
                    title: 'Menunggu Pembayaran',
                    description: 'Honor belum ditransfer / masih dalam antrean',
                    icon: Icons.hourglass_top_rounded,
                    activeColor: const Color(0xFFD97706),
                    activeBgColor: const Color(0xFFFFFBEB),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSelectOption({
    required BuildContext sheetContext,
    required String statusValue,
    required String title,
    required String description,
    required IconData icon,
    required Color activeColor,
    required Color activeBgColor,
  }) {
    final bool isSelected = _currentStatus == statusValue;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? activeBgColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _currentStatus = statusValue;
            });
            Navigator.pop(sheetContext);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? activeColor : const Color(0xFF94A3B8),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor.withOpacity(0.15) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? activeColor : const Color(0xFF64748B),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? activeColor : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_rounded, color: activeColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simpanPerubahan() async {
    final int? tugasId = widget.detail['id'] is int
        ? widget.detail['id']
        : int.tryParse(widget.detail['id']?.toString() ?? '');

    if (tugasId != null) {
      final String statusDb = _currentStatus == 'Pembayaran Selesai' ? '1' : '0';
      await AsesorService.updateAdminHonorTugasStatus(
        tugasId,
        status: statusDb,
        linkBuktiPembayaran: _buktiUrlController.text.trim(),
      );
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green success check icon with soft background and decorative dots
                // NO top-left back arrow and NO top-right X close icon as requested
                SizedBox(
                  width: 130,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer soft green circle background
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Decorative dots around icon
                      Positioned(
                        top: 10, right: 14,
                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBBF7D0), shape: BoxShape.circle)),
                      ),
                      Positioned(
                        top: 6, left: 24,
                        child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF86EFAC), shape: BoxShape.circle)),
                      ),
                      Positioned(
                        top: 26, left: 8,
                        child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle)),
                      ),
                      Positioned(
                        bottom: 18, left: 16,
                        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFBBF7D0), shape: BoxShape.circle)),
                      ),
                      Positioned(
                        bottom: 12, right: 22,
                        child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF86EFAC), shape: BoxShape.circle)),
                      ),
                      Positioned(
                        top: 16, right: 26,
                        child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle)),
                      ),
                      // Inner vivid green scalloped check badge icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title Text
                const Text(
                  'Pembayaran Honor Asessor Telah Di Simpan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),

                // Uniform Blue OK Button
                SizedBox(
                  width: 140,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.pop(context, true); // Pop detail screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
  }

  @override
  Widget build(BuildContext context) {
    final String namaAsesor = (widget.detail['nama_asesor'] ?? widget.detail['asesor'] ?? '').toString().trim();
    final String rawTipeAsesor = (widget.detail['tipe_asesor'] ?? '').toString().trim();
    final String tipeAsesor = rawTipeAsesor.replaceAll(RegExp(r'^Asesor\s*', caseSensitive: false), '').trim();
    final String judul = widget.detail['judul_asesmen'] ?? widget.detail['judul'] ?? 'Junior Web Developer';
    final String tuk = widget.detail['tuk'] ?? 'SMA 5 Semarang';
    final String rawWaktu = widget.detail['waktu'] ?? widget.detail['tanggal'] ?? '20/05/2026';
    String sWaktu = rawWaktu.replaceAll(RegExp(r'\s*wib', caseSensitive: false), '').trim();
    sWaktu = sWaktu.replaceAll(RegExp(r'\s+\d{1,2}(?::\d{2})*.*$'), '').trim();
    final String waktu = sWaktu == '0' ? '' : sWaktu;
    final String mode = widget.detail['mode'] ?? '[Offline]';
    final String honorAsesmen = _formatHonorValue(
      widget.detail['honor'] ?? widget.detail['honor_asesmen'],
      fallback: 'Rp 0',
    );
    final String biayaTransportasi = _formatHonorValue(
      widget.detail['akomodasi'] ?? widget.detail['biaya_transportasi'] ?? widget.detail['transportasi'],
      fallback: 'Rp 0',
    );
    final String potonganPph = _formatHonorValue(
      widget.detail['potongan_pph'] ?? widget.detail['pajak'] ?? widget.detail['pph'],
      fallback: 'Rp 0',
    );
    final dynamic rawBiayaAdmin = widget.detail['biaya_admin_transfer'];
    final String? biayaAdmin = (rawBiayaAdmin != null &&
            rawBiayaAdmin.toString().trim().isNotEmpty &&
            rawBiayaAdmin.toString().trim() != '0')
        ? _formatHonorValue(rawBiayaAdmin)
        : null;

    final String? rawTotal = widget.detail['total_honor']?.toString() ?? widget.detail['total']?.toString();
    final String totalHonor;
    if (rawTotal != null && rawTotal.trim().isNotEmpty && rawTotal.trim() != '0') {
      totalHonor = _formatHonorValue(rawTotal);
    } else {
      final int h = _parseNumeric(widget.detail['honor'] ?? widget.detail['honor_asesmen']);
      final int a = _parseNumeric(widget.detail['akomodasi'] ?? widget.detail['biaya_transportasi']);
      final int p = _parseNumeric(widget.detail['potongan_pph'] ?? widget.detail['pajak'] ?? widget.detail['pph']);
      final int adm = _parseNumeric(rawBiayaAdmin);
      final int calc = h + a - p - adm;
      totalHonor = calc > 0 ? _formatHonorValue(calc) : (h > 0 ? _formatHonorValue(h) : 'Rp 0');
    }
    final bool isSelesai = _currentStatus == 'Pembayaran Selesai';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

          // Header Bar
          CustomAppBar(
            title: 'Detail Honor Asessor',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
              onSelected: (val) {},
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text('Refresh Data', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Task Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.description_rounded,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (namaAsesor.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF3B82F6)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        namaAsesor + (tipeAsesor.isNotEmpty ? ' ($tipeAsesor)' : ''),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                              ],
                              Text(
                                judul,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'TUK : $tuk',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                waktu.isNotEmpty ? '$waktu ${mode.startsWith('[') ? mode : '[$mode]'}' : (mode.startsWith('[') ? mode : '[$mode]'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: mode.contains('Online') ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelesai ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSelesai ? 'Selesai' : 'Menunggu',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Rincian Honor Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Honor',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),
                        _buildRincianRow('Honor Asesmen', honorAsesmen),
                        if (biayaTransportasi != 'Rp 0' && biayaTransportasi.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildRincianRow('Biaya Transportasi', biayaTransportasi),
                        ],
                        if (potonganPph != 'Rp 0' && potonganPph.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildRincianRow('Potongan PPh', potonganPph, isDeduction: true),
                        ],
                        if (biayaAdmin != null && biayaAdmin.isNotEmpty && biayaAdmin != 'Rp 0') ...[
                          const SizedBox(height: 6),
                          _buildRincianRow('Biaya Admin Transfer', biayaAdmin),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Honor :',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            Text(
                              totalHonor,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Status Pembayaran Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pembayaran',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isAdmin)
                          GestureDetector(
                            onTap: _showStatusPicker,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelesai ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelesai ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelesai ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                                          color: isSelesai ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                          size: 15,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _currentStatus,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelesai ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF64748B),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelesai ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelesai ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelesai ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                  color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentStatus,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Lampiran Bukti Pembayaran Card (URL Input)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran Bukti Pembayaran (Bukti Transfer Pembayaran/ Bukti Potong Pajak)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isAdmin)
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _buktiUrlController,
                            builder: (context, val, _) {
                              final text = val.text.trim();
                              return TextField(
                                controller: _buktiUrlController,
                                keyboardType: TextInputType.url,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  hintText: 'Tempel link bukti pembayaran (opsional)',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                                  ),
                                  suffixIcon: text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF2563EB)),
                                          tooltip: 'Buka Link',
                                          onPressed: () async {
                                            final uri = Uri.tryParse(text);
                                            if (uri != null) {
                                              try {
                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              } catch (_) {}
                                            }
                                          },
                                        )
                                      : null,
                                ),
                              );
                            },
                          )
                        else if (_buktiUrlController.text.trim().isNotEmpty)
                          InkWell(
                            onTap: () async {
                              final uri = Uri.tryParse(_buktiUrlController.text.trim());
                              if (uri != null) {
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (_) {}
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link_rounded, size: 18, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _buktiUrlController.text.trim(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2563EB),
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF2563EB)),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'Belum ada bukti pembayaran yang dilampirkan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Action Buttons (Standardized Color)
                  if (_isAdmin)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCBD5E1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: _simpanPerubahan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  int _parseNumeric(dynamic raw) {
    if (raw == null) return 0;
    final s = raw.toString().trim().replaceAll('Rp', '').replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '');
    final d = double.tryParse(s);
    return d?.toInt() ?? 0;
  }


  String _formatHonorValue(dynamic raw, {String fallback = 'Rp 0'}) {
    if (raw == null) return fallback;
    final s = raw.toString().trim();
    if (s.isEmpty || s == '0' || s == '-') return fallback;
    if (s.toLowerCase().startsWith('rp')) return s;
    final numVal = double.tryParse(s.replaceAll(',', ''));
    if (numVal != null) {
      final intVal = numVal.toInt();
      return 'Rp ${intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return s;
  }

  Widget _buildRincianRow(String title, String amount, {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDeduction ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
