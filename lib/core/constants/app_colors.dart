import 'package:flutter/material.dart';

/// Premium iOS 18+ color system for MicroFlow Pro.
/// Curated for a luxurious fintech aesthetic with refined depth and warmth.
class AppColors {
  AppColors._();

  // ─── Primary Palette — Deep Indigo Blue ───
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFA855F7);

  // ─── Semantic Colors — Refined Apple HIG ───
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);
  static const Color mint = Color(0xFF14B8A6);
  static const Color teal = Color(0xFF06B6D4);
  static const Color pink = Color(0xFFEC4899);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color rose = Color(0xFFF43F5E);

  // ─── Light Theme — Warm, luminous, layered ───
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color separatorLight = Color(0xFFE2E8F0);
  static const Color fillLight = Color(0xFFF1F5F9);
  static const Color groupedBgLight = Color(0xFFF8F9FB);
  static const Color secondaryFillLight = Color(0xFFEDF2F7);

  // ─── Dark Theme — Deep charcoal, not pure black ───
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1D29);
  static const Color cardDark = Color(0xFF1E2230);
  static const Color elevatedDark = Color(0xFF252A3A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color separatorDark = Color(0xFF2A3042);
  static const Color fillDark = Color(0xFF1E2433);
  static const Color groupedBgDark = Color(0xFF0F1117);
  static const Color secondaryFillDark = Color(0xFF1A2030);

  // ─── Legacy aliases (backward compatibility) ───
  static const Color primaryTeal = primary;
  static const Color primaryIndigo = accent;
  static const Color primaryPurple = accentLight;
  static const Color accentCyan = primaryLight;
  static const Color backgroundSlate = surfaceDark;
  static const Color surfaceSlate = elevatedDark;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textMuted = textTertiaryLight;
  static const Color textMutedLight = textTertiaryLight;
  static const Color textPrimaryDarkLegacy = textPrimaryDark;
  static const Color textSecondaryDark2 = textSecondaryDark;
  static const Color glassBackground = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);
  static const Color glassBackgroundLight = Color(0xB3FFFFFF);
  static const Color glassBorderLight = Color(0x330A84FF);

  // ─── Gradient Presets ───
  static const List<Color> premiumGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  static const List<Color> coolGradient = [
    Color(0xFF22D3EE),
    Color(0xFF4F46E5),
  ];

  static const List<Color> auroraGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFFA855F7),
    Color(0xFF22D3EE),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF14B8A6),
  ];

  static const List<Color> cardGradient = [
    Color(0x1A7C3AED),
    Color(0x0D4F46E5),
  ];

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: premiumGradient,
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