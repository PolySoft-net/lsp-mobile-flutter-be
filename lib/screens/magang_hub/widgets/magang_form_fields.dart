import 'package:material_ui/material_ui.dart';

import '../../../models/master_models.dart';

/// Field & bagian form khusus layar input lowongan Magang Hub.
///
/// Semua state (controller, pilihan, status unggah) tetap dimiliki
/// `MagangFormScreen`; widget di sini hanya merender UI.

const Color _accent = Color(0xFF53A6ED);
const Color _textPrimary = Color(0xFF0F172A);
const Color _textSecondary = Color(0xFF475569);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE2E8F0);
const Color _fill = Color(0xFFF8FAFC);

InputDecoration _fieldDecoration({String? hint}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintMaxLines: 1,
    hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: border(const Color(0xFFCBD5E1)),
    enabledBorder: border(_border),
    focusedBorder: border(_accent, 1.5),
    filled: true,
    fillColor: _fill,
  );
}

/// Kartu putih dengan judul bagian dan ikon kecil.
class MagangFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const MagangFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Label di atas input.
class MagangFormLabel extends StatelessWidget {
  final String text;

  const MagangFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _textSecondary),
    );
  }
}

class MagangFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const MagangFormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MagangFormLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: _fieldDecoration(hint: hint),
        ),
      ],
    );
  }
}

class MagangFormDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const MagangFormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MagangFormLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _fieldDecoration(),
        ),
      ],
    );
  }
}

/// Dropdown skema LSP; menampilkan progress selama daftar masih dimuat.
class MagangFormSkemaField extends StatelessWidget {
  final bool isLoading;
  final List<MasterSkema> skemaList;
  final MasterSkema? selected;
  final ValueChanged<MasterSkema?> onChanged;

  const MagangFormSkemaField({
    super.key,
    required this.isLoading,
    required this.skemaList,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MagangFormLabel('Kualifikasi Skema LSP Terkait (Opsional)'),
        const SizedBox(height: 6),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(color: _accent),
          )
        else
          DropdownButtonFormField<MasterSkema>(
            initialValue: selected,
            isExpanded: true,
            style: const TextStyle(fontSize: 14, color: _textPrimary),
            decoration: _fieldDecoration(),
            items: [
              const DropdownMenuItem<MasterSkema>(
                value: null,
                child: Text(
                  'Tidak mewajibkan skema khusus',
                  style: TextStyle(color: _textMuted, fontSize: 13),
                ),
              ),
              ...skemaList.map(
                (s) => DropdownMenuItem<MasterSkema>(
                  value: s,
                  child: Text(
                    s.namaSkema,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
      ],
    );
  }
}

/// Daftar poin dinamis (deskripsi/persyaratan/benefit).
///
/// Penambahan & penghapusan controller tetap dilakukan pemilik state.
class MagangFormPointList extends StatelessWidget {
  final String title;
  final List<TextEditingController> controllers;
  final String hint;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const MagangFormPointList({
    super.key,
    required this.title,
    required this.controllers,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return MagangFormSection(
      title: title,
      icon: Icons.format_list_bulleted_rounded,
      children: [
        ...List.generate(controllers.length, (idx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[idx],
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: '$hint (${idx + 1})',
                      hintStyle: const TextStyle(fontSize: 12.5, color: _textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _accent, width: 1.5),
                      ),
                      filled: true,
                      fillColor: _fill,
                    ),
                  ),
                ),
                if (controllers.length > 1) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 20),
                    tooltip: 'Hapus poin',
                    onPressed: () => onRemove(idx),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF2563EB)),
          label: const Text(
            'Tambah Poin',
            style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Bagian unggah dokumen PDF: nama berkas terpilih + tombol pilih/unggah.
class MagangPdfUploadSection extends StatelessWidget {
  final String fileName;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const MagangPdfUploadSection({
    super.key,
    required this.fileName,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return MagangFormSection(
      title: 'Dokumen Kerangka Acuan / Flyer (PDF)',
      icon: Icons.picture_as_pdf_rounded,
      children: [
        if (fileName.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  tooltip: 'Hapus dokumen',
                  onPressed: onClear,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: isUploading ? null : onPick,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                )
              : const Icon(Icons.upload_file_rounded, size: 20),
          label: Text(
            isUploading ? 'Mengunggah...' : 'Pilih Berkas PDF',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Aksi bawah: Simpan Draft + Publikasikan.
///
/// Di layar sempit atau teks besar tombol ditumpuk penuh selebar layar agar
/// label tetap terbaca (tanpa elipsis).
class MagangFormActions extends StatelessWidget {
  final bool isSubmitting;
  final bool isEditing;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  const MagangFormActions({
    super.key,
    required this.isSubmitting,
    required this.isEditing,
    required this.onSaveDraft,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final stacked = width < 360 || textScale > 1.35;

    final draft = OutlinedButton(
      onPressed: isSubmitting ? null : onSaveDraft,
      style: OutlinedButton.styleFrom(
        foregroundColor: _textSecondary,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Simpan Draft',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );

    final publish = ElevatedButton(
      onPressed: isSubmitting ? null : onPublish,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              isEditing ? 'Perbarui Info' : 'Publikasikan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F8),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: stacked
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: double.infinity, child: draft),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: publish),
              ],
            )
          : Row(
              children: [
                Expanded(child: draft),
                const SizedBox(width: 12),
                Expanded(child: publish),
              ],
            ),
    );
  }
}
