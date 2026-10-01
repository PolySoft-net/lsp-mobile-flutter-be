import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/digital_product_chat_model.dart';
import '../../models/digital_product_models.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/digital_product_service.dart';
import '../../utils/url_helper.dart';
import 'digital_product_detail_screen.dart';

class DigitalProductChatRoomScreen extends StatefulWidget {
  final DigitalProductChatRoom? room;
  final int? roomId;
  final int? productId;
  final int? orderId;

  const DigitalProductChatRoomScreen({
    super.key,
    this.room,
    this.roomId,
    this.productId,
    this.orderId,
  });

  @override
  State<DigitalProductChatRoomScreen> createState() =>
      _DigitalProductChatRoomScreenState();
}

class _DigitalProductChatRoomScreenState
    extends State<DigitalProductChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  DigitalProductChatRoom? _room;
  List<DigitalProductChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String _error = '';
  File? _selectedImage;
  Timer? _pollingTimer;

  int get _currentUserId {
    final user = AuthRepository.currentUserInstance;
    return int.tryParse(user?.id ?? '0') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _initChat();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _room != null && !_sending) {
        _fetchMessagesSilently();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (_room == null) {
        if (widget.productId != null) {
          _room = await DigitalProductService.createOrGetChatRoom(
            productId: widget.productId!,
            orderId: widget.orderId,
          );
        } else if (widget.roomId != null) {
          final rooms = await DigitalProductService.getChatRooms(limit: 50);
          final found = rooms.where((r) => r.id == widget.roomId);
          if (found.isNotEmpty) {
            _room = found.first;
          }
        }
      }

      if (_room != null) {
        final messages = await DigitalProductService.getChatMessages(_room!.id);
        if (mounted) {
          setState(() {
            _messages = messages;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Ruang chat tidak ditemukan';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat chat: ${e.toString().replaceAll("Exception: ", "")}';
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchMessagesSilently() async {
    if (_room == null) return;
    try {
      final messages = await DigitalProductService.getChatMessages(_room!.id);
      if (mounted && messages.isNotEmpty) {
        final hasNew = _messages.isEmpty ||
            messages.length != _messages.length ||
            messages.first.id != _messages.first.id;
        if (hasNew) {
          setState(() => _messages = messages);
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file != null && file.path != null) {
        setState(() {
          _selectedImage = File(file.path!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih gambar')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_room == null) return;
    final text = _messageController.text.trim();
    final image = _selectedImage;

    if (text.isEmpty && image == null) return;

    setState(() => _sending = true);
    _messageController.clear();
    setState(() => _selectedImage = null);

    try {
      final sent = await DigitalProductService.sendChatMessage(
        _room!.id,
        message: text,
        messageType: image != null ? 'image' : 'text',
        filePath: image?.path,
      );

      if (mounted) {
        setState(() {
          _messages = [sent, ..._messages];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengirim pesan: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openProductDetail() {
    if (_room == null) return;
    final item = DigitalProductItem(
      id: _room!.productId.toString(),
      userId: _room!.seller.id,
      title: _room!.productTitle,
      priceValue: _room!.productPrice,
      thumbnailUrl: _room!.productThumbnail,
      category: '',
      productType: 'Produk',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalProductDetailScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counterparty = _room?.counterparty(_currentUserId);
    final partyName = counterparty?.name.isNotEmpty == true
        ? counterparty!.name
        : 'Pengguna LSP';
    final partyPhoto = counterparty?.photoUrl ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage:
                  partyPhoto.isNotEmpty ? NetworkImage(partyPhoto) : null,
              child: partyPhoto.isEmpty
                  ? const Icon(LucideIcons.user, size: 18, color: Color(0xFF64748B))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    partyName,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _room != null && _currentUserId == _room!.buyer.id
                        ? 'Penjual'
                        : 'Pembeli',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_room != null) _buildProductBanner(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error, style: const TextStyle(color: Color(0xFF64748B))),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _initChat,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _messages.isEmpty
                          ? _buildEmptyState()
                          : _buildMessageList(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductBanner() {
    final thumb = _room!.productThumbnailUrl;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: thumb.isNotEmpty
                ? Image.network(
                    thumb,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackThumb(),
                  )
                : _fallbackThumb(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _room!.productTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _currencyFormat.format(_room!.productPrice),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _openProductDetail,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'Lihat',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFFF1F5F9),
      child: const Icon(LucideIcons.package, size: 20, color: Color(0xFF94A3B8)),
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
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.message_circle,
                size: 32,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Mulai Obrolan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Diskusikan spesifikasi produk, negosiasi harga, atau ajukan pertanyaan langsung.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.isMe || message.senderId == _currentUserId;
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(DigitalProductChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFCBD5E1),
              backgroundImage: message.senderPhoto.isNotEmpty
                  ? NetworkImage(UrlHelper.resolveUrl(message.senderPhoto))
                  : null,
              child: message.senderPhoto.isEmpty
                  ? const Icon(LucideIcons.user, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(3),
                  bottomRight: isMe ? const Radius.circular(3) : const Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.attachmentUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.resolvedAttachmentUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(LucideIcons.image, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                    if (message.message.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isMe ? Colors.white : const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? const Color(0xFFBFDBFE) : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13,
                          color: message.isRead
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFFBFDBFE),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return raw.length >= 16 ? raw.substring(11, 16) : raw;
    }
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Foto siap dikirim', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.image, size: 22, color: Color(0xFF64748B)),
                onPressed: _sending ? null : _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _sending ? null : _sendMessage,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            LucideIcons.send,
                            size: 18,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
