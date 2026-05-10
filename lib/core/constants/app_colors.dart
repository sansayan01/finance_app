import 'package:flutter/material.dart';

/// Refined iOS 18 color system for MicroFlow Pro.
/// Each token is intentionally curated for premium fintech aesthetics.
class AppColors {
  AppColors._();

  // ─── Primary Palette — iOS 18 System Blue ───
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color accent = Color(0xFF5856D6);   // Indigo
  static const Color accentLight = Color(0xFFAF52DE); // Purple

  // ─── Semantic Colors — Apple HIG ───
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);
  static const Color orange = Color(0xFFFF9F0A);
  static const Color mint = Color(0xFF00C7BE);
  static const Color teal = Color(0xFF30B0C7);
  static const Color pink = Color(0xFFFF2D55);
  static const Color indigo = Color(0xFF5856D6);
  static const Color cyan = Color(0xFF32ADE6);

  // ─── Light Theme — Bright, luminous, layered ───
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textTertiaryLight = Color(0xFFC7C7CC);
  static const Color separatorLight = Color(0xFFC6C6C8);
  static const Color fillLight = Color(0xFFE5E5EA);
  static const Color groupedBgLight = Color(0xFFF2F2F7);
  static const Color secondaryFillLight = Color(0xFFEBEBF0);

  // ─── Dark Theme — True black, depth through surfaces ───
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color elevatedDark = Color(0xFF2C2C2E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFF48484A);
  static const Color separatorDark = Color(0xFF38383A);
  static const Color fillDark = Color(0xFF3A3A3C);
  static const Color groupedBgDark = Color(0xFF000000);
  static const Color secondaryFillDark = Color(0xFF39393D);

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
    Color(0xFF007AFF),
    Color(0xFF5856D6),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFFF9F0A),
    Color(0xFFFF3B30),
  ];

  static const List<Color> coolGradient = [
    Color(0xFF5AC8FA),
    Color(0xFF007AFF),
  ];

  static const List<Color> auroraGradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
    Color(0xFF5AC8FA),
  ];

  static const List<Color> successGradient = [
    Color(0xFF34C759),
    Color(0xFF00C7BE),
  ];

  static const List<Color> cardGradient = [
    Color(0x1A5856D6),
    Color(0x0D007AFF),
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