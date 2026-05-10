import 'package:flutter/material.dart';

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

/// A clean iOS-style pill badge for statuses.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool glow;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.glow = false,
    this.fontSize,
  });

  Color get _color {
    switch (type) {
      case StatusType.standard:
      case StatusType.approved:
      case StatusType.active:
        return const Color(0xFF34C759);
      case StatusType.defaultStatus:
      case StatusType.rejected:
      case StatusType.inactive:
        return const Color(0xFFFF3B30);
      case StatusType.pending:
        return const Color(0xFFFF9F0A);
      case StatusType.completed:
        return const Color(0xFF007AFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: _color,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple pill badge with custom color and optional icon.
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}