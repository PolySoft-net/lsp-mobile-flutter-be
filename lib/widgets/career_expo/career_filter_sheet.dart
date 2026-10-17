import 'package:material_ui/material_ui.dart';
import '../../models/career_expo_models.dart';
import '../../services/career_expo/career_expo_service.dart';

/// Bottom Sheet untuk filter lowongan pekerjaan Career Expo
class CareerFilterSheet extends StatefulWidget {
  final String selectedEmploymentType;
  final String selectedWorkplaceType;
  final String selectedLocation;
  final CareerFilterOptions? filterOptions;
  final Function(String empType, String workplaceType, String location) onApply;

  const CareerFilterSheet({
    super.key,
    required this.selectedEmploymentType,
    required this.selectedWorkplaceType,
    required this.selectedLocation,
    this.filterOptions,
    required this.onApply,
  });

  @override
  State<CareerFilterSheet> createState() => _CareerFilterSheetState();
}

class _CareerFilterSheetState extends State<CareerFilterSheet> {
  late String _empType;
  late String _workplaceType;
  late String _location;
  List<String> _empTypes = const ['Semua'];
  List<String> _workplaceTypes = const ['Semua'];
  List<String> _locations = const ['Semua'];

  @override
  void initState() {
    super.initState();
    _empType = widget.selectedEmploymentType;
    _workplaceType = widget.selectedWorkplaceType;
    _location = widget.selectedLocation;
    if (widget.filterOptions != null) {
      _empTypes = widget.filterOptions!.employmentTypes;
      _workplaceTypes = widget.filterOptions!.workplaceTypes;
      _locations = widget.filterOptions!.locations;
    } else {
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    final opts = await CareerExpoService.getFilterOptions();
    if (!mounted) return;
    setState(() {
      _empTypes = opts.employmentTypes;
      _workplaceTypes = opts.workplaceTypes;
      _locations = opts.locations;
    });
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF0066F6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066F6) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0066F6).withValues(alpha: 0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: keyboardInset + 16,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF0066F6),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Filter Lowongan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, color: Color(0xFFF1F5F9)),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Tipe Pekerjaan
                    _buildSectionTitle('Tipe Pekerjaan'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _empTypes.map((type) {
                        final isSelected = _empType == type;
                        return _buildFilterChip(
                          label: type,
                          isSelected: isSelected,
                          onTap: () => setState(() => _empType = type),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Model Kerja
                    _buildSectionTitle('Model Kerja'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _workplaceTypes.map((wp) {
                        final isSelected = _workplaceType == wp;
                        return _buildFilterChip(
                          label: wp,
                          isSelected: isSelected,
                          onTap: () => setState(() => _workplaceType = wp),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Lokasi Kota
                    _buildSectionTitle('Lokasi Kota'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locations.map((loc) {
                        final isSelected = _location == loc;
                        return _buildFilterChip(
                          label: loc,
                          isSelected: isSelected,
                          onTap: () => setState(() => _location = loc),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Footer Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _empType = 'Semua';
                        _workplaceType = 'Semua';
                        _location = 'Semua';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onApply(_empType, _workplaceType, _location);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
