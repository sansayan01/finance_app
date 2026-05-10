import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

enum StatusType {
  standard,
  defaultStatus,
  pending,
  approved,
  rejected,
  active,
  inactive,
  completed,
}

class StatusBadge extends StatefulWidget {
  final String label;
  final StatusType type;
  final bool glow;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.glow = true,
    this.fontSize,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case StatusType.standard:
        return AppColors.success;
      case StatusType.defaultStatus:
        return AppColors.error;
      case StatusType.pending:
        return AppColors.warning;
      case StatusType.approved:
      case StatusType.active:
        return AppColors.success;
      case StatusType.rejected:
      case StatusType.inactive:
        return AppColors.error;
      case StatusType.completed:
        return AppColors.primaryTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: _backgroundColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
            border: Border.all(
              color: _backgroundColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: widget.glow
                ? [
                    BoxShadow(
                      color: _backgroundColor.withValues(alpha: _glowAnimation.value * 0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: _backgroundColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: _backgroundColor,
                  fontSize: widget.fontSize ?? 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const PillBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}