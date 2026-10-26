import 'package:material_ui/material_ui.dart';

import '../../models/investment_models.dart';
import '../../services/investment/investment_service.dart';
import '../../utils/number_format_helper.dart';

class InvestmentInterestModal extends StatefulWidget {
  final InvestmentStartupItem startup;
  final VoidCallback? onSuccess;

  const InvestmentInterestModal({
    super.key,
    required this.startup,
    this.onSuccess,
  });

  @override
  State<InvestmentInterestModal> createState() =>
      _InvestmentInterestModalState();
}

class _InvestmentInterestModalState extends State<InvestmentInterestModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final cleanAmountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(cleanAmountStr) ?? 0;

    final submission = InvestmentInterestSubmission(
      startupId: int.tryParse(widget.startup.id) ?? 0,
      investorName: _nameController.text.trim(),
      investorEmail: _emailController.text.trim(),
      investorPhone: _phoneController.text.trim(),
      offeredAmount: amount,
      notes: _notesController.text.trim(),
    );

    try {
      await InvestmentService.submitInterest(submission);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Minat investasi berhasil dikirim! Founder akan segera menghubungi Anda.',
          ),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim minat investasi. Silakan coba lagi.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minTicketFormatted = NumberFormatHelper.formatWithDots(widget.startup.minimumTicket);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ajukan Minat Investasi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.startup.nama,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.startup.minimumTicket > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF0D9488),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Minimum tiket investasi pada startup ini adalah Rp $minTicketFormatted.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF115E59),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Form fields
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap Calon Investor *',
                hint: 'Masukkan nama lengkap Anda / entitas',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _phoneController,
                label: 'Nomor WhatsApp / HP *',
                hint: 'Contoh: 081234567890',
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nomor telepon wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _emailController,
                label: 'Alamat Email',
                hint: 'Contoh: investor@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _amountController,
                label: 'Nominal Minat Investasi (Rp) *',
                hint: widget.startup.minimumTicket > 0
                    ? 'Minimal Rp $minTicketFormatted'
                    : 'Contoh: 50.000.000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nominal investasi wajib diisi';
                  }
                  final cleanStr = v.replaceAll(RegExp(r'[^0-9]'), '');
                  final val = int.tryParse(cleanStr) ?? 0;
                  if (val <= 0) return 'Nominal harus lebih dari 0';
                  if (widget.startup.minimumTicket > 0 &&
                      val < widget.startup.minimumTicket) {
                    return 'Nominal kurang dari tiket minimum (Rp $minTicketFormatted)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _notesController,
                label: 'Catatan / Rencana Sinergi',
                hint: 'Tuliskan pesan penawaran atau sinergi strategis yang diharapkan...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Minat Investasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
