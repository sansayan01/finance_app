import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────
  //  LIGHT THEME — iOS-inspired clean, bright look
  // ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.accentLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryLight),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimaryLight),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.textSecondaryLight),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.textTertiaryLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.separatorLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.separatorLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.textTertiaryLight.withValues(alpha: 0.8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.separatorLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separatorLight,
        thickness: 0.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : AppColors.surfaceLight),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.success : AppColors.fillLight),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.fillLight,
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 14,
          elevation: 4,
          pressedElevation: 8,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  DARK THEME — Rich, deep iOS dark mode
  // ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.accentLight,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.separatorDark.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.separatorDark.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: AppColors.textTertiaryDark.withValues(alpha: 0.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.separatorDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separatorDark,
        thickness: 0.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : AppColors.textTertiaryDark),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.success : AppColors.fillDark),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.fillDark,
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 14,
          elevation: 4,
          pressedElevation: 8,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.elevatedDark,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}