import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/common/app_notification_storage.dart';
import '../../widgets/common/custom_app_bar.dart';
class CareerExpoNotificationSettingsScreen extends StatefulWidget {
  const CareerExpoNotificationSettingsScreen({super.key});

  @override
  State<CareerExpoNotificationSettingsScreen> createState() =>
      _CareerExpoNotificationSettingsScreenState();
}

class _CareerExpoNotificationSettingsScreenState
    extends State<CareerExpoNotificationSettingsScreen> {
  Future<String> _resolveStorageKey() async {
    final identity = await AppNotificationStorage.instance.resolveSessionIdentity();
    final uid = identity?.userId ?? AuthRepository.currentUserInstance?.id ?? 'default';
    return 'career_expo_notif_prefs_$uid';
  }
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  bool _lowonganBaru = true;
  bool _statusLamaran = true;
  bool _jadwalInterview = true;
  bool _infoKarir = true;
  bool _notifEmail = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final key = await _resolveStorageKey();
      final raw = await _storage.read(key: key);
      if (raw != null && raw.isNotEmpty && mounted) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          _lowonganBaru = decoded['lowongan_baru'] as bool? ?? true;
          _statusLamaran = decoded['status_lamaran'] as bool? ?? true;
          _jadwalInterview = decoded['jadwal_interview'] as bool? ?? true;
          _infoKarir = decoded['info_karir'] as bool? ?? true;
          _notifEmail = decoded['notif_email'] as bool? ?? false;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final key = await _resolveStorageKey();
      final payload = {
        'lowongan_baru': _lowonganBaru,
        'status_lamaran': _statusLamaran,
        'jadwal_interview': _jadwalInterview,
        'info_karir': _infoKarir,
        'notif_email': _notifEmail,
      };
      await _storage.write(key: key, value: jsonEncode(payload));
    } catch (_) {}
  }

  void _onToggle(String key, bool value) {
    setState(() {
      switch (key) {
        case 'lowongan_baru':
          _lowonganBaru = value;
          break;
        case 'status_lamaran':
          _statusLamaran = value;
          break;
        case 'jadwal_interview':
          _jadwalInterview = value;
          break;
        case 'info_karir':
          _infoKarir = value;
          break;
        case 'notif_email':
          _notifEmail = value;
          break;
      }
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Pengaturan Notifikasi',
            rightWidget: SizedBox(width: 32),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0066F6)),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Aktivitas Karir & Lamaran'),
                        _buildCardContainer([
                          _buildSwitchTile(
                            icon: Icons.work_outline_rounded,
                            title: 'Lowongan Kerja Baru',
                            subtitle:
                                'Pemberitahuan saat ada lowongan baru yang cocok dengan preferensi Anda',
                            value: _lowonganBaru,
                            onChanged: (v) => _onToggle('lowongan_baru', v),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildSwitchTile(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'Pembaruan Status Lamaran',
                            subtitle:
                                'Update berkala saat lamaran ditinjau, diproses, atau diterima',
                            value: _statusLamaran,
                            onChanged: (v) => _onToggle('status_lamaran', v),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildSwitchTile(
                            icon: Icons.calendar_today_rounded,
                            title: 'Pengingat Wawancara & Tes',
                            subtitle:
                                'Pengingat jadwal interview, batas kirim tugas, atau tes seleksi',
                            value: _jadwalInterview,
                            onChanged: (v) => _onToggle('jadwal_interview', v),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Info & Kanal Pemberitahuan'),
                        _buildCardContainer([
                          _buildSwitchTile(
                            icon: Icons.campaign_outlined,
                            title: 'Event & Tips Karir',
                            subtitle:
                                'Info job fair, webinar, dan tips persiapan karir dari LSP Digital',
                            value: _infoKarir,
                            onChanged: (v) => _onToggle('info_karir', v),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildSwitchTile(
                            icon: Icons.mark_email_unread_outlined,
                            title: 'Salinan Notifikasi via Email',
                            subtitle:
                                'Kirim ringkasan update lamaran penting ke alamat email akun',
                            value: _notifEmail,
                            onChanged: (v) => _onToggle('notif_email', v),
                          ),
                        ]),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF0066F6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0066F6),
            activeTrackColor: const Color(0xFFBFDBFE),
          ),
        ],
      ),
    );
  }
}
