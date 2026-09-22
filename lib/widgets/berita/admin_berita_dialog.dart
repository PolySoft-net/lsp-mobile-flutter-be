import 'package:file_picker/file_picker.dart';
import '../../utils/upload_file_validator.dart';
import 'package:material_ui/material_ui.dart';
import '../../services/dashboard/berita_service.dart';

int kategoriNameToId(String? name) {
  if (name == null || name.isEmpty) return 2;
  final n = name.toLowerCase();
  if (n.contains('lsp')) return 4;
  if (n.contains('galeri')) return 9;
  return 2;
}

Future<void> showAdminBeritaFormDialog({
  required BuildContext context,
  int? beritaId,
  String? initialJudul,
  String? initialHeadline,
  String? initialIsi,
  int initialKategori = 2,
  String? initialFoto,
  String initialShowImage = '1',
  required VoidCallback onSuccess,
}) async {
  final formKey = GlobalKey<FormState>();
  final judulController = TextEditingController(text: initialJudul ?? '');
  final headlineController = TextEditingController(text: initialHeadline ?? '');
  final isiController = TextEditingController(text: initialIsi ?? '');
  final fotoController = TextEditingController(text: initialFoto ?? '');
  String? newFotoFileName;
  bool isUploadingFoto = false;

  int selectedKategori = [2, 4, 9].contains(initialKategori)
      ? initialKategori
      : 2;
  bool showImage = initialShowImage != '0';
  bool isSubmitting = false;

  final isEdit = beritaId != null;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEdit ? 'Edit Berita' : 'Tambah Berita Baru',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),

                        // Judul
                        TextFormField(
                          controller: judulController,
                          maxLength: 100,
                          decoration: InputDecoration(
                            labelText: 'Judul Berita *',
                            hintText: 'Masukkan judul berita',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Judul berita wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Headline
                        TextFormField(
                          controller: headlineController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Headline / Ringkasan *',
                            hintText: 'Ringkasan singkat berita',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Headline wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Kategori Dropdown
                        DropdownButtonFormField<int>(
                          initialValue: selectedKategori,
                          decoration: InputDecoration(
                            labelText: 'Kategori Berita *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 2, child: Text('Berita')),
                            DropdownMenuItem(
                              value: 4,
                              child: Text('Berita LSP'),
                            ),
                            DropdownMenuItem(
                              value: 9,
                              child: Text('Galeri Foto'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedKategori = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Konten / Isi Berita
                        TextFormField(
                          controller: isiController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Isi Berita *',
                            hintText: 'Tulis konten lengkap berita...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Isi berita wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Nama File Foto + FilePicker Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fotoController,
                                decoration: InputDecoration(
                                  labelText: 'File Foto (Opsional)',
                                  hintText: 'contoh: berita_kegiatan.jpg',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: (isUploadingFoto
                                  ? null
                                  : () async {
                                      try {
                                        final messenger = ScaffoldMessenger.of(
                                          ctx,
                                        );
                                        final file = await FilePicker.pickFile(
                                          type: FileType.image,
                                        );
                                        if (file != null && file.path != null) {
                                          final valid =
                                              await UploadFileValidator.isValid(
                                                messenger,
                                                file,
                                                UploadFileValidator.beritaMaxMB,
                                              );
                                          if (!ctx.mounted) {
                                            return;
                                          }
                                          if (!valid) {
                                            return;
                                          }
                                          setModalState(
                                            () => isUploadingFoto = true,
                                          );
                                          final uploaded =
                                              await BeritaService.uploadBeritaFoto(
                                                file.path!,
                                              );
                                          if (!ctx.mounted) return;
                                          if (uploaded != null &&
                                              uploaded['filename'] != null) {
                                            final serverName =
                                                uploaded['filename'].toString();
                                            setModalState(() {
                                              newFotoFileName = serverName;
                                              fotoController.text = serverName;
                                            });
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Foto berhasil diunggah',
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Gagal mengunggah foto',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          setModalState(
                                            () => isUploadingFoto = false,
                                          );
                                        }
                                      } catch (e) {
                                        if (ctx.mounted) {
                                          setModalState(
                                            () => isUploadingFoto = false,
                                          );
                                        }
                                        debugPrint('Error picking file: $e');
                                      }
                                    }),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                child: isUploadingFoto
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF2563EB),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Pilih Foto',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Show Image Switch
                        SwitchListTile(
                          title: const Text(
                            'Tampilkan Gambar Berita',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            showImage
                                ? 'Gambar akan ditampilkan'
                                : 'Gambar disembunyikan',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          value: showImage,
                          activeThumbColor: const Color(0xFF2563EB),
                          onChanged: (val) {
                            setModalState(() {
                              showImage = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }

                                    setModalState(() {
                                      isSubmitting = true;
                                    });

                                    bool success = false;
                                    String msg = '';

                                    if (isEdit) {
                                      final res =
                                          await BeritaService.updateAdminBerita(
                                            beritaId,
                                            judul: judulController.text.trim(),
                                            headline: headlineController.text
                                                .trim(),
                                            isi: isiController.text.trim(),
                                            idKategori: selectedKategori,
                                            foto: newFotoFileName,
                                            showImage: showImage ? '1' : '0',
                                          );
                                      success = res != null;
                                      msg =
                                          res?['message']?.toString() ??
                                          (success
                                              ? 'Berita berhasil diperbarui'
                                              : 'Gagal memperbarui berita');
                                    } else {
                                      final res =
                                          await BeritaService.createAdminBerita(
                                            judul: judulController.text.trim(),
                                            headline: headlineController.text
                                                .trim(),
                                            isi: isiController.text.trim(),
                                            idKategori: selectedKategori,
                                            foto: fotoController.text.trim(),
                                            showImage: showImage ? '1' : '0',
                                          );
                                      success = res != null;
                                      msg =
                                          res?['message']?.toString() ??
                                          (success
                                              ? 'Berita berhasil dibuat'
                                              : 'Gagal membuat berita');
                                    }

                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          backgroundColor: success
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      );
                                      if (success) {
                                        onSuccess();
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEdit
                                        ? 'Perbarui Berita'
                                        : 'Simpan Berita',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> confirmDeleteAdminBerita({
  required BuildContext context,
  required int beritaId,
  required String beritaTitle,
  required VoidCallback onSuccess,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Hapus Berita',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus berita "$beritaTitle"? Data yang dihapus tidak akan dapat dikembalikan.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    final success = await BeritaService.deleteAdminBerita(beritaId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Berita berhasil dihapus' : 'Gagal menghapus berita',
          ),
          backgroundColor: success
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
        ),
      );
      if (success) {
        onSuccess();
      }
    }
  }
}
