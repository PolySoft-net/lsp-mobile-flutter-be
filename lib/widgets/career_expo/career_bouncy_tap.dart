import 'package:material_ui/material_ui.dart';

/// Touch feedback widget with smooth springy scale animation
class CareerBouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const CareerBouncyTap({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.92,
  });

  @override
  State<CareerBouncyTap> createState() => _CareerBouncyTapState();
}

class _CareerBouncyTapState extends State<CareerBouncyTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
