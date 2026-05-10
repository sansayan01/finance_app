import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium iOS-style card with subtle shadow, smooth corners,
/// and optional tap / hover interactivity.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final double borderRadius;
  final bool enableHover;
  final double blurIntensity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.gradientColors,
    this.borderRadius = 16,
    this.enableHover = true,
    this.blurIntensity = 0, // default = no blur for clean iOS look
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.06);

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
        onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.gradientColors == null ? cardColor : null,
              gradient: widget.gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.gradientColors!
                          .map((c) => c.withValues(alpha: 0.15))
                          .toList(),
                    )
                  : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isHovered
                    ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08))
                    : borderColor,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _isHovered ? 24 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: widget.blurIntensity > 0
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: widget.blurIntensity / 2,
                        sigmaY: widget.blurIntensity / 2,
                      ),
                      child: Padding(
                        padding: widget.padding ?? const EdgeInsets.all(16),
                        child: widget.child,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.all(16),
                      child: widget.child,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// A simpler glass container without interactivity.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final double blurIntensity;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.backgroundColor,
    this.blurIntensity = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity / 2,
            sigmaY: blurIntensity / 2,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}