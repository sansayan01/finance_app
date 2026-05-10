import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryTeal = Color(0xFF00D9FF);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundSlate = Color(0xFF1E293B);
  static const Color surfaceSlate = Color(0xFF334155);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color glassBackground = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  static const List<Color> auroraGradient = [
    Color(0xFF00D9FF),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  static const List<Color> cardGradient = [
    Color(0x1A6366F1),
    Color(0x0D00D9FF),
  ];

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryIndigo, primaryTeal],
      );

  static LinearGradient get auroraGradientLinear => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: auroraGradient,
      );

  static RadialGradient get radialAurora => const RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: auroraGradient,
      );
}