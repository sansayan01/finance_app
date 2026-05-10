import 'package:flutter/material.dart';

enum StatusType {
  active,
  standard,
  pending,
  completed,
  defaultStatus,
  warning,
}

/// iOS-style status pill with semantic coloring.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool glow;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.standard,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colorsFor(type, Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color bg, Color fg) _colorsFor(StatusType type, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (type) {
      case StatusType.active:
      case StatusType.standard:
        return (
          isDark
              ? const Color(0xFF34C759).withValues(alpha: 0.18)
              : const Color(0xFF34C759).withValues(alpha: 0.12),
          const Color(0xFF34C759),
        );
      case StatusType.pending:
        return (
          isDark
              ? const Color(0xFFFF9F0A).withValues(alpha: 0.18)
              : const Color(0xFFFF9F0A).withValues(alpha: 0.12),
          const Color(0xFFFF9F0A),
        );
      case StatusType.completed:
        return (
          isDark
              ? const Color(0xFF007AFF).withValues(alpha: 0.18)
              : const Color(0xFF007AFF).withValues(alpha: 0.12),
          const Color(0xFF007AFF),
        );
      case StatusType.defaultStatus:
        return (
          isDark
              ? const Color(0xFFFF3B30).withValues(alpha: 0.18)
              : const Color(0xFFFF3B30).withValues(alpha: 0.12),
          const Color(0xFFFF3B30),
        );
      case StatusType.warning:
        return (
          isDark
              ? const Color(0xFFFF9F0A).withValues(alpha: 0.18)
              : const Color(0xFFFF9F0A).withValues(alpha: 0.12),
          const Color(0xFFFF9F0A),
        );
    }
  }
}