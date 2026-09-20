import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class InteractiveFavoriteButton extends StatefulWidget {
  final bool initialIsFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showFeedbackSnackBar;
  final EdgeInsetsGeometry padding;

  const InteractiveFavoriteButton({
    super.key,
    this.initialIsFavorite = false,
    this.onFavoriteChanged,
    this.size = 18,
    this.activeColor = const Color(0xFFEF4444),
    this.inactiveColor = const Color(0xFF64748B),
    this.showFeedbackSnackBar = true,
    this.padding = const EdgeInsets.all(4.0),
  });

  @override
  State<InteractiveFavoriteButton> createState() =>
      _InteractiveFavoriteButtonState();
}

class _InteractiveFavoriteButtonState extends State<InteractiveFavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant InteractiveFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite) {
      _isFavorite = widget.initialIsFavorite;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    setState(() {
      _isFavorite = !_isFavorite;
    });

    _controller.forward(from: 0.0);
    widget.onFavoriteChanged?.call(_isFavorite);

    if (widget.showFeedbackSnackBar) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
          ),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: widget.padding,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            size: widget.size,
            color: _isFavorite ? widget.activeColor : widget.inactiveColor,
          ),
        ),
      ),
    );
  }
}
