import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_chat_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/digital_product_service.dart';
import 'digital_product_chat_room_screen.dart';

class DigitalProductChatListScreen extends StatefulWidget {
  const DigitalProductChatListScreen({super.key});

  @override
  State<DigitalProductChatListScreen> createState() =>
      _DigitalProductChatListScreenState();
}

class _DigitalProductChatListScreenState
    extends State<DigitalProductChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<DigitalProductChatRoom> _rooms = [];
  bool _loading = true;
  String _error = '';
  String _query = '';

  int get _currentUserId {
    final user = AuthRepository.currentUserInstance;
    return int.tryParse(user?.id ?? '0') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final rooms = await DigitalProductService.getChatRooms(limit: 50);
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat pesan';
          _loading = false;
        });
      }
    }
  }

  List<DigitalProductChatRoom> get _filteredRooms {
    if (_query.trim().isEmpty) return _rooms;
    final q = _query.toLowerCase().trim();
    return _rooms.where((r) {
      final counter = r.counterparty(_currentUserId);
      return counter.name.toLowerCase().contains(q) ||
          r.productTitle.toLowerCase().contains(q) ||
          r.lastMessageText.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pesan Produk Digital',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error,
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadRooms,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _rooms.isEmpty
                          ? _buildEmptyState()
                          : _filteredRooms.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Tidak ada pesan yang cocok',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadRooms,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: _filteredRooms.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      height: 1,
                                      thickness: 0.8,
                                      indent: 74,
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    itemBuilder: (context, index) {
                                      final room = _filteredRooms[index];
                                      return _buildRoomTile(room);
                                    },
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _query = val),
        decoration: InputDecoration(
          hintText: 'Cari pesan atau pengguna...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF94A3B8)),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTile(DigitalProductChatRoom room) {
    final counter = room.counterparty(_currentUserId);
    final partyName =
        counter.name.isNotEmpty ? counter.name : 'Pengguna LSP';
    final partyPhoto = counter.photoUrl;
    final isSeller = _currentUserId == room.seller.id;
    final roleLabel = isSeller ? 'Pembeli' : 'Penjual';

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DigitalProductChatRoomScreen(room: room),
          ),
        );
        if (mounted) _loadRooms();
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage:
                  partyPhoto.isNotEmpty ? NetworkImage(partyPhoto) : null,
              child: partyPhoto.isEmpty
                  ? const Icon(LucideIcons.user, size: 22, color: Color(0xFF64748B))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partyName,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(room.lastMessageAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: room.unreadCount > 0
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                          fontWeight: room.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room.productTitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessageText.isNotEmpty
                              ? room.lastMessageText
                              : 'Belum ada pesan',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: room.unreadCount > 0
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF64748B),
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.message_square,
                size: 36,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Pesan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Percakapan antara Anda dengan penjual atau pembeli akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('HH:mm').format(dt);
      }
      return DateFormat('dd/MM/yy').format(dt);
    } catch (_) {
      return raw.length >= 10 ? raw.substring(5, 10) : raw;
    }
  }
}
