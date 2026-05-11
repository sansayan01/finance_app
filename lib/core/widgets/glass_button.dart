import 'package:flutter/material.dart';

/// Premium button with iOS-grade press animation and
/// optional gradient or tinted surface styling.
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final bool isDestructive;
  final Color? color;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;

  const GlassButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.isDestructive = false,
    this.color,
    this.width,
    this.height = 50,
    this.borderRadius = 14,
    this.fontSize = 16,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;

    if (widget.isDestructive) {
      bgColor = theme.colorScheme.error;
      fgColor = Colors.white;
    } else if (widget.isPrimary) {
      bgColor = widget.color ?? theme.colorScheme.primary;
      fgColor = Colors.white;
    } else {
      bgColor = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.04);
      fgColor = widget.color ?? theme.colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fgColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: fgColor, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
