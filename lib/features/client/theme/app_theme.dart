import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF5136F0);
  static const Color secondary = Color(0xFFFF8A48);
  static const Color scaffold = Color(0xFFF4F4FB);
  static const Color darkScaffold = Color(0xFF0F172A);
  static const Color success = Color(0xFF0D9488);
  static const Color danger = Color(0xFFDC2626);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light(useMaterial3: true);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffold,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          color: colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkScaffold,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          color: colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(35),
      border: _outlineBorder(colorScheme),
      enabledBorder: _outlineBorder(colorScheme),
      focusedBorder: _outlineBorder(colorScheme, width: 1.8),
      errorBorder: _outlineBorder(colorScheme, color: AppColors.danger),
      focusedErrorBorder: _outlineBorder(
        colorScheme,
        color: AppColors.danger,
        width: 1.8,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(
        color: colorScheme.onSurfaceVariant.withAlpha(70),
      ),
      labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
    );
  }

  static OutlineInputBorder _outlineBorder(
    ColorScheme colorScheme, {
    Color? color,
    double width = 1.2,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color ?? colorScheme.outlineVariant,
        width: width,
      ),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
