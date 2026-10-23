import 'package:material_ui/material_ui.dart';

/// Palet Magang Hub — selaras aksen biru aplikasi.
const Color hubCanvas = Color(0xFFF5F6F8);
const Color hubInk = Color(0xFF0F172A);
const Color hubMuted = Color(0xFF64748B);
const Color hubFaint = Color(0xFF94A3B8);
const Color hubLine = Color(0xFFE2E8F0);
const Color hubAccent = Color(0xFF53A6ED);
const Color hubBlue = Color(0xFF2563EB);

/// Search field: tombol clear reaktif tanpa rebuild seluruh screen.
class MagangHubSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const MagangHubSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hubLine),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(fontSize: 13.5, color: hubInk),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: hubFaint),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: hubMuted),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: hubFaint,
                    ),
                    tooltip: 'Hapus pencarian',
                    onPressed: onClear,
                  ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

/// Segmented control fill penuh (Lowongan, Perusahaan, Magang Saya) — tiap opsi lebar rata.
class MagangHubSegmentedControl extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const MagangHubSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final row = Row(
      children: [
        for (var i = 0; i < options.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == options.length - 1 ? 0 : 8),
              child: _HubSegment(
                label: options[i],
                isSelected: selected == options[i],
                fill: true,
                onTap: () => onSelected(options[i]),
              ),
            ),
          ),
      ],
    );
    // Opsi banyak (mis. kota mitra) tetap terbaca penuh lewat scroll horizontal.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: options.length > 5
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: options.length * 96.0,
                child: row,
              ),
            )
          : row,
    );
  }
}

class _HubSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool fill;
  final VoidCallback onTap;

  const _HubSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? hubBlue : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: fill ? Alignment.center : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? hubBlue : hubLine),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: fill ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : hubMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Daftar kosong/error tetap bisa di-scroll supaya pull-to-refresh jalan.
class MagangHubStateList extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final Widget? action;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MagangHubStateList({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
    this.action,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics ??
          (shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      children: [
        Icon(icon, size: 40, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: hubMuted, height: 1.4),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: hubBlue,
                side: const BorderSide(color: hubLine),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          action!,
        ],
      ],
    );
  }
}

class MagangHubPrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const MagangHubPrimaryAction({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: hubAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
