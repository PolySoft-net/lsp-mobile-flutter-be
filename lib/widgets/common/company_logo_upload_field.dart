import 'package:material_ui/material_ui.dart';

import 'company_logo.dart';

/// Unggah logo perusahaan asli (JPG/PNG) untuk form lowongan Career Expo & Magang Hub.
///
/// Hanya menampilkan pratinjau gambar sungguhan dari [imageUrl]; tidak pernah
/// menggambar logo buatan saat kosong/gagal dimuat.
class CompanyLogoUploadField extends StatelessWidget {
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const CompanyLogoUploadField({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = imageUrl.trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompanyLogo(
          imageUrl: imageUrl,
          size: 76,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasLogo ? 'Logo terunggah' : 'Logo perusahaan wajib diunggah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: hasLogo ? const Color(0xFF0F172A) : const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isUploading
                    ? 'Mengunggah gambar ke server...'
                    : 'Format JPG atau PNG, tampil sebagai logo pada kartu lowongan.',
                style: TextStyle(
                  fontSize: 11,
                  color: isUploading
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isUploading ? null : onPick,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0066F6),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0066F6),
                            ),
                          )
                        : const Icon(Icons.image_outlined, size: 18),
                    label: Text(
                      isUploading
                          ? 'Mengunggah...'
                          : (hasLogo ? 'Ganti Logo' : 'Pilih Logo'),
                    ),
                  ),
                  if (hasLogo)
                    TextButton.icon(
                      onPressed: isUploading ? null : onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
