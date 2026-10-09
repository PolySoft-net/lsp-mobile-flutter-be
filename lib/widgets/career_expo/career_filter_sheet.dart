import 'package:material_ui/material_ui.dart';

/// Bottom Sheet untuk filter lowongan pekerjaan Career Expo
class CareerFilterSheet extends StatefulWidget {
  final String selectedEmploymentType;
  final String selectedWorkplaceType;
  final String selectedLocation;
  final Function(String empType, String workplaceType, String location) onApply;

  const CareerFilterSheet({
    super.key,
    required this.selectedEmploymentType,
    required this.selectedWorkplaceType,
    required this.selectedLocation,
    required this.onApply,
  });

  @override
  State<CareerFilterSheet> createState() => _CareerFilterSheetState();
}

class _CareerFilterSheetState extends State<CareerFilterSheet> {
  late String _empType;
  late String _workplaceType;
  late String _location;

  final List<String> _empTypes = ['Semua', 'Full Time', 'Magang', 'Kontrak', 'Part Time'];
  final List<String> _workplaceTypes = ['Semua', 'Remote', 'On Site', 'Hybrid'];
  final List<String> _locations = ['Semua', 'Jakarta', 'Yogyakarta', 'Bandung', 'Surabaya'];

  @override
  void initState() {
    super.initState();
    _empType = widget.selectedEmploymentType;
    _workplaceType = widget.selectedWorkplaceType;
    _location = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Lowongan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _empType = 'Semua';
                    _workplaceType = 'Semua';
                    _location = 'Semua';
                  });
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          // Section Tipe Pekerjaan
          const Text(
            'Tipe Pekerjaan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _empTypes.map((type) {
              final isSelected = _empType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _empType = type);
                },
                selectedColor: const Color(0xFF0066F6),
                backgroundColor: const Color(0xFFF8FAFC),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          // Section Tipe Lokasi Kerja
          const Text(
            'Model Kerja',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _workplaceTypes.map((wp) {
              final isSelected = _workplaceType == wp;
              return ChoiceChip(
                label: Text(wp),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _workplaceType = wp);
                },
                selectedColor: const Color(0xFF0066F6),
                backgroundColor: const Color(0xFFF8FAFC),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          // Section Lokasi Kota
          const Text(
            'Lokasi Kota',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _locations.map((loc) {
              final isSelected = _location == loc;
              return ChoiceChip(
                label: Text(loc),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _location = loc);
                },
                selectedColor: const Color(0xFF0066F6),
                backgroundColor: const Color(0xFFF8FAFC),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_empType, _workplaceType, _location);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
