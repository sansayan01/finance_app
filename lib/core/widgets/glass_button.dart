import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final double? width;
  final double height;
  final List<Color>? gradientColors;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height = AppSpacing.buttonHeightMd,
    this.gradientColors,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppSpacing.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? [AppColors.primaryIndigo, AppColors.primaryTeal];

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading ? _handleTapDown : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading ? _handleTapCancel : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.onPressed != null ? colors : [colors.first.withValues(alpha: 0.5), colors.last.withValues(alpha: 0.5)],
                  ),
            border: Border.all(
              color: widget.isOutlined
                  ? AppColors.glassBorder
                  : (widget.onPressed != null
                      ? AppColors.glassHighlight
                      : AppColors.glassBorder.withValues(alpha: 0.5)),
              width: 1,
            ),
            boxShadow: widget.onPressed != null && !_isPressed
                ? [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? AppColors.textPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}