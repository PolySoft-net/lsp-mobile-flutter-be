import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/asesi/asesi_portofolio_model.dart';
import '../../services/asesi/asesi_portofolio_service.dart';
import '../../widgets/asesi/tambah_portofolio_modal.dart';

class AsesiPortofolioScreen extends StatefulWidget {
  const AsesiPortofolioScreen({super.key});

  @override
  State<AsesiPortofolioScreen> createState() => _AsesiPortofolioScreenState();
}

class _AsesiPortofolioScreenState extends State<AsesiPortofolioScreen> {
  List<AsesiPortofolioItem> _items = const [];
  String _selectedFilter = 'semua'; // 'semua', 'link', 'dokumen', 'gambar'
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await AsesiPortofolioService.getPortofolioList();
      if (mounted) {
        setState(() => _items = list);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Portofolio belum dapat dimuat');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AsesiPortofolioItem> get _filteredItems {
    if (_selectedFilter == 'semua') return _items;
    return _items.where((item) => item.tipe == _selectedFilter).toList();
  }

  Future<void> _openBukti(AsesiPortofolioItem item) async {
    final targetUrl = item.bukti.trim();
    if (targetUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan/berkas tidak tersedia')),
      );
      return;
    }

    try {
      final uri = Uri.parse(
        targetUrl.startsWith('http://') || targetUrl.startsWith('https://')
            ? targetUrl
            : 'https://$targetUrl',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka URL: $targetUrl')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka tautan: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(AsesiPortofolioItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Portofolio'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await AsesiPortofolioService.deletePortofolio(item.id);
      if (mounted) {
        if (success) {
          setState(() {
            _items = _items.where((i) => i.id != item.id).toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portofolio berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus portofolio')),
          );
        }
      }
    }
  }

  Future<void> _openTambahModal() async {
    final newItem = await TambahPortofolioModal.show(context);
    if (newItem != null && mounted) {
      setState(() {
        _items = [newItem, ..._items];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Portofolio Saya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: Color(0xFF2563EB)),
            tooltip: 'Tambah Portofolio',
            onPressed: _openTambahModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: _openTambahModal,
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text(
            'Tambah Portofolio',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(key: 'semua', label: 'Semua (${_items.length})'),
            const SizedBox(width: 8),
            _filterChip(
              key: 'link',
              label: 'Link / Tautan (${_items.where((i) => i.tipe == "link").length})',
              icon: LucideIcons.link,
            ),
            const SizedBox(width: 8),
            _filterChip(
              key: 'dokumen',
              label: 'Dokumen (${_items.where((i) => i.tipe == "dokumen").length})',
              icon: LucideIcons.file_text,
            ),
            const SizedBox(width: 8),
            _filterChip(
              key: 'gambar',
              label: 'Foto / Gambar (${_items.where((i) => i.tipe == "gambar").length})',
              icon: LucideIcons.image,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String key,
    required String label,
    IconData? icon,
  }) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredItems;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.folder_open,
                  size: 32,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Portofolio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unggah bukti pekerjaan, tautan proyek GitHub, atau dokumen pengalaman kerja Anda untuk mendukung sertifikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openTambahModal,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Tambah Portofolio Sekarang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 90 + bottomPadding),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = filtered[index];
          return _buildPortfolioCard(item);
        },
      ),
    );
  }

  Widget _buildPortfolioCard(AsesiPortofolioItem item) {
    Color typeColor;
    Color typeBg;
    IconData typeIcon;
    String typeLabel;

    if (item.isLink) {
      typeColor = const Color(0xFF2563EB);
      typeBg = const Color(0xFFEFF6FF);
      typeIcon = LucideIcons.link;
      typeLabel = 'Tautan Web / GitHub';
    } else if (item.isGambar) {
      typeColor = const Color(0xFF059669);
      typeBg = const Color(0xFFECFDF5);
      typeIcon = LucideIcons.image;
      typeLabel = 'Foto / Gambar';
    } else {
      typeColor = const Color(0xFFD97706);
      typeBg = const Color(0xFFFFFBEB);
      typeIcon = LucideIcons.file_text;
      typeLabel = 'Dokumen Berkas';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card: Tipe badge & Delete button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 12, color: typeColor),
                    const SizedBox(width: 4),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (item.tanggal.isNotEmpty) ...[
                const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  item.tanggal,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 8),
              ],
              InkWell(
                onTap: () => _handleDelete(item),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Judul Portofolio
          Text(
            item.judul,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Deskripsi
          if (item.deskripsi.isNotEmpty) ...[
            Text(
              item.deskripsi,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer info / Tombol Buka Bukti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Icon(
                  item.isLink ? LucideIcons.external_link : LucideIcons.paperclip,
                  size: 14,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.isLink ? item.bukti : (item.namaFile.isNotEmpty ? item.namaFile : 'Berkas Terunggah'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: item.isLink ? const Color(0xFF2563EB) : const Color(0xFF475569),
                      decoration: item.isLink ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openBukti(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.isLink ? 'Buka Link' : 'Lihat Berkas',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(LucideIcons.arrow_up_right, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
