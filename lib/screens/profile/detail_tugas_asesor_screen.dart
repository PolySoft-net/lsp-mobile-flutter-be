import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/asesor/asesor_service.dart';
import 'detail_honor_screen.dart';
import '../../utils/url_helper.dart';

class DetailTugasAsesorScreen extends StatefulWidget {
  final Map<String, dynamic> asesorData;

  const DetailTugasAsesorScreen({
    super.key,
    required this.asesorData,
  });

  @override
  State<DetailTugasAsesorScreen> createState() => _DetailTugasAsesorScreenState();
}

class _DetailTugasAsesorScreenState extends State<DetailTugasAsesorScreen> {
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _loadedTasks = [];
  Map<String, dynamic>? _taskCounts;
  Map<String, dynamic>? _jadwalInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTugasData();
  }

  Future<void> _fetchTugasData() async {
    final int? targetId = widget.asesorData['id'] is int
        ? widget.asesorData['id']
        : int.tryParse(widget.asesorData['id']?.toString() ?? '');
    if (targetId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String tabStatus = _selectedTabIndex == 1 ? 'selesai' : 'semua';

      final res = await AsesorService.getAdminHonorAsesorTugas(
        targetId,
        status: tabStatus,
      );

      if (mounted && res != null) {
        final List<dynamic> list = res['tugas'] as List<dynamic>? ?? [];
        setState(() {
          _loadedTasks = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _taskCounts = res['counts'] as Map<String, dynamic>?;
          _jadwalInfo = res['jadwal_info'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching tugas data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  int get _totalCount =>
      _asCount(_taskCounts?['semua']) ?? _loadedTasks.length;

  int get _selesaiCount {
    final fromBackend = _asCount(_taskCounts?['selesai']);
    if (fromBackend != null) return fromBackend;
    return _loadedTasks.where(_isTaskSelesai).length;
  }

  static int? _asCount(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _isTaskSelesai(Map<String, dynamic> task) {
    final status = (task['status'] ?? '').toString().trim().toLowerCase();
    return status == 'selesai' || status == 'complete' || status == 'lunas';
  }

  void _navigateToDetailHonor(Map<String, dynamic> task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHonorScreen(
          detail: {
            ...task,
            'id': task['id'],
            'id_jadwal': task['id_jadwal'] ?? widget.asesorData['id'],
            'judul_asesmen': task['judul_asesmen'] ??
                task['judul'] ??
                _jadwalInfo?['judul'] ??
                widget.asesorData['nama_jadwal'] ??
                widget.asesorData['judul_asesmen'],
            'nama_asesor': task['nama_asesor'] ?? widget.asesorData['nama_asesor'],
            'tipe_asesor': task['tipe_asesor'] ?? widget.asesorData['tipe_asesor'],
            'honor': task['honor'],
            'akomodasi': task['akomodasi'] ?? task['biaya_transportasi'],
            'potongan_pph': task['potongan_pph'] ?? task['pajak'] ?? task['pph'],
            'biaya_admin_transfer': task['biaya_admin_transfer'],
            'link_bukti_pembayaran': task['link_bukti_pembayaran'],
            'jumlah_asesi': task['jumlah_asesi'],
            'total_honor': task['total_honor'],
            'avatar_url': task['avatar_url'],
            'tanggal': task['waktu'] ??
                task['tanggal'] ??
                _jadwalInfo?['tanggal'] ??
                widget.asesorData['tanggal'],
            'tuk': task['tuk'] ?? _jadwalInfo?['tuk'] ?? widget.asesorData['tuk'],
            'status': task['status'],
          },
          status: task['status'] ?? 'Selesai',
          metodePembayaran: 'Transfer Bank',
          tanggalPembayaran: task['waktu'] ??
              task['tanggal'] ??
              _jadwalInfo?['tanggal'] ??
              widget.asesorData['tanggal'] ??
              '-',
          noTransfer: task['no_transfer'] ?? '-',
          jumlahAsesmen: 1,
        ),
      ),
    );

    if (result == true) {
      _fetchTugasData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String judulJadwal = _jadwalInfo?['judul'] ??
        widget.asesorData['nama_jadwal'] ??
        widget.asesorData['judul_asesmen'] ??
        widget.asesorData['nama_asesor'] ??
        'Jadwal Asesmen';

    final String infoTuk = _jadwalInfo?['tuk'] ??
        widget.asesorData['tuk'] ??
        widget.asesorData['tipe_asesor'] ??
        '-';

    final String tanggalJadwal = _jadwalInfo?['tanggal'] ??
        widget.asesorData['tanggal'] ??
        widget.asesorData['waktu'] ??
        '';

    final String totalHonor = _jadwalInfo?['total_honor'] ??
        widget.asesorData['total_honor'] ??
        widget.asesorData['honor'] ??
        'Rp 0';

    final String statusJadwal = _jadwalInfo?['status'] ??
        widget.asesorData['status'] ??
        widget.asesorData['status_asesor'] ??
        'Selesai';

    final bool isSelesai = statusJadwal.toLowerCase() == 'selesai' ||
        statusJadwal.toLowerCase() == 'sudah ditransfer' ||
        statusJadwal.toLowerCase() == 'complete' ||
        statusJadwal.toLowerCase() == 'lunas';

    final bool isDibayarTUK = _jadwalInfo?['is_dibayar_tuk'] == true ||
        widget.asesorData['is_dibayar_tuk'] == true ||
        totalHonor.toLowerCase().contains('tuk');

    final String? noInvoice = (_jadwalInfo?['no_invoice'] ?? widget.asesorData['no_invoice'])?.toString();
    final String? nominalInvoice = (_jadwalInfo?['nominal_invoice'] ?? widget.asesorData['nominal_invoice'])?.toString();
    final String? tglPelunasan = (_jadwalInfo?['tgl_pelunasan'] ?? widget.asesorData['tgl_pelunasan'])?.toString();
    final String? linkBuktiInvoice = (_jadwalInfo?['link_bukti_invoice'] ?? widget.asesorData['link_bukti_invoice'])?.toString();
    // Backend sudah memfilter sesuai status tab — jangan difilter ulang di FE.
    final currentTasks = _loadedTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

          // Header
          CustomAppBar(
            title: 'Detail Honor Asesor',
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

          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 1. Jadwal Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    judulJadwal,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (infoTuk.isNotEmpty && infoTuk != '-') ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            infoTuk,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  if (tanggalJadwal.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tanggalJadwal,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isDibayarTUK
                                    ? const Color(0xFFE0F2FE)
                                    : (isSelesai ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                isDibayarTUK
                                    ? 'Dibayar TUK'
                                    : (isSelesai ? 'Selesai' : 'Menunggu'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDibayarTUK
                                      ? const Color(0xFF0284C7)
                                      : (isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Honor Jadwal :',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
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
                        if (noInvoice != null && noInvoice.isNotEmpty && noInvoice != '-') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('No. Invoice', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                    Text(noInvoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  ],
                                ),
                                if (nominalInvoice != null && nominalInvoice.isNotEmpty && nominalInvoice != '0') ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Nominal Invoice', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      Text(_formatNominal(nominalInvoice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ],
                                if (tglPelunasan != null && tglPelunasan.isNotEmpty && tglPelunasan != '1970-01-01') ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Tgl Pelunasan', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      Text(tglPelunasan, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                                    ],
                                  ),
                                ],
                                if (linkBuktiInvoice != null && linkBuktiInvoice.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Bukti Invoice', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      InkWell(
                                        onTap: () => UrlHelper.launchURL(linkBuktiInvoice),
                                        child: const Text('Lihat Bukti', style: TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Main Content Container with Tabs
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Tab Bar Header
                        Row(
                          children: [
                            _buildUnderlineTab(
                              index: 0,
                              label: 'Semua',
                              count: _totalCount,
                            ),
                            _buildUnderlineTab(
                              index: 1,
                              label: 'Selesai',
                              count: _selesaiCount,
                            ),
                          ],
                        ),

                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),

                        // Tasks List
                        if (currentTasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Tidak ada tugas',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemCount: currentTasks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _buildTaskCard(currentTasks[index]);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildUnderlineTab({
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _fetchTugasData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    count > 999 ? '999+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String namaAsesor = (task['nama_asesor'] ?? '').toString().trim();
    final String tipeAsesor = (task['tipe_asesor'] ?? '').toString().trim();
    String tipeAsesorClean = tipeAsesor.replaceAll(RegExp(r'^Asesor\s*', caseSensitive: false), '').trim();
    if (tipeAsesorClean.isEmpty) tipeAsesorClean = 'Internal';

    final String judul = (task['judul'] ?? task['judul_asesmen'] ?? '').toString().trim();
    final String tuk = (task['tuk'] ?? '').toString().trim();
    final int jumlahAsesi = task['jumlah_asesi'] is int
        ? task['jumlah_asesi']
        : int.tryParse(task['jumlah_asesi']?.toString() ?? '') ?? 0;

    final String rawAvatar = (task['avatar_url'] ?? task['foto_user'] ?? '').toString().trim();
    final String avatarUrl = rawAvatar.isNotEmpty ? UrlHelper.resolveUrl(rawAvatar) : '';

    final bool hasAsesor = namaAsesor.isNotEmpty;
    final String cardTitle = hasAsesor ? namaAsesor : (judul.isNotEmpty ? judul : 'Asesor');

    final String rawPph = (task['potongan_pph'] ?? task['pph'] ?? '0').toString().trim();
    final String pphFormatted = _formatNominal(rawPph);
    final bool hasPph = rawPph.isNotEmpty && rawPph != '0' && rawPph != '-';
    final String totalHonorTask = task['total_honor'] ?? task['honor'] ?? 'Rp 0';

    final String status = task['status'] ?? 'Selesai';
    final bool isSelesai = status.toLowerCase() == 'selesai' ||
        status.toLowerCase() == 'sudah ditransfer' ||
        status.toLowerCase() == 'complete' ||
        status.toLowerCase() == 'lunas';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _navigateToDetailHonor(task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                // Avatar / Profile Picture
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Color(0xFF3B82F6),
                              size: 22,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: Color(0xFF3B82F6),
                            size: 22,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Task / Asesor details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (hasAsesor) ...[
                        Text(
                          tipeAsesorClean,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (!hasAsesor && tuk.isNotEmpty) ...[
                        Text(
                          'TUK : $tuk',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jumlahAsesi > 0 ? '$jumlahAsesi Asesi yang diuji' : 'Jumlah Asesi: -',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Amount & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalHonorTask,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (hasPph) ...[
                      const SizedBox(height: 2),
                      Text(
                        'PPh: -$pphFormatted',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNominal(String raw) {
    if (raw.toLowerCase().startsWith('rp')) return raw;
    final numVal = double.tryParse(raw.replaceAll(',', ''));
    if (numVal != null) {
      final intVal = numVal.toInt();
      return 'Rp ${intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return 'Rp $raw';
  }
}
