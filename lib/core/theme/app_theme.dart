import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────
  //  LIGHT THEME — iOS 18 HIG: bright, luminous, layered
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
        outline: AppColors.separatorLight,
        surfaceContainerHighest: AppColors.fillLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 34),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -0.4, fontSize: 28),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryLight),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: const Color(0xFF8E8E93)),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: const Color(0xFF8E8E93)),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: const Color(0xFF8E8E93)),
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
          borderSide: BorderSide(color: AppColors.separatorLight.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.separatorLight.withValues(alpha: 0.4)),
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
        hintStyle: TextStyle(color: const Color(0xFF8E8E93).withValues(alpha: 0.6)),
        labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.separatorLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        thickness: 0.33,
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
        backgroundColor: const Color(0xFF1C1C1E),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF8E8E93),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fillLight,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textPrimaryLight,
        unselectedLabelColor: const Color(0xFF8E8E93),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  DARK THEME — True black OLED, luminous accents
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
        outline: AppColors.separatorDark,
        surfaceContainerHighest: AppColors.fillDark,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 34),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, letterSpacing: -0.4, fontSize: 28),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: const Color(0xFF98989D)),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: const Color(0xFF98989D)),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: const Color(0xFF98989D)),
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
        labelStyle: TextStyle(color: const Color(0xFF98989D).withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: const Color(0xFF98989D).withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.separatorDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        thickness: 0.33,
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
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF98989D),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fillDark,
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textPrimaryDark,
        unselectedLabelColor: const Color(0xFF98989D),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }
}