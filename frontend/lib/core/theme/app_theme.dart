import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF6246EA),
    onPrimary: Colors.white,
    secondary: Color(0xFF9C27B0),
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFD700),
    onTertiary: Color(0xFF1A1A1A),
    surface: Color(0xFF1A1A1A),
    onSurface: Color(0xFFF2F2F2),
    surfaceTint: Color(0xFF6246EA),
    surfaceContainerLowest: Color(0xFF141414),
    surfaceContainerLow: Color(0xFF1A1A1A),
    surfaceContainer: Color(0xFF202020),
    surfaceContainerHigh: Color(0xFF252525),
    surfaceContainerHighest: Color(0xFF2D2D2D),
    error: Color(0xFFFF5B69),
    onError: Colors.white,
    outline: Color(0xFF4A4A4A),
    outlineVariant: Color(0xFF2E2E2E),
    scrim: Color(0xFF000000),
  );

  static TextTheme _textTheme(ColorScheme colorScheme) => TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(
            colorScheme.onSurface.r.round(),
            colorScheme.onSurface.g.round(),
            colorScheme.onSurface.b.round(),
            0.8,
          ),
          letterSpacing: 0.2,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.tertiary,
          letterSpacing: 0.1,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
          letterSpacing: 0.5,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        scaffoldBackgroundColor: _darkColorScheme.surfaceContainerLowest,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkColorScheme.surfaceContainerLowest,
          foregroundColor: _darkColorScheme.onSurface,
          elevation: 4,
          shadowColor: Color.fromRGBO(
            _darkColorScheme.scrim.r.round(),
            _darkColorScheme.scrim.g.round(),
            _darkColorScheme.scrim.b.round(),
            0.5,
          ),
          centerTitle: true,
          titleTextStyle: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.onSurface,
          ),
        ),
        cardTheme: CardTheme(
          color: _darkColorScheme.surfaceContainerLow,
          elevation: 4,
          shadowColor: Color.fromRGBO(
            _darkColorScheme.scrim.r.round(),
            _darkColorScheme.scrim.g.round(),
            _darkColorScheme.scrim.b.round(),
            0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkColorScheme.primary,
            foregroundColor: _darkColorScheme.onPrimary,
            shadowColor: Color.fromRGBO(
              _darkColorScheme.primary.r.round(),
              _darkColorScheme.primary.g.round(),
              _darkColorScheme.primary.b.round(),
              0.3,
            ),
            textStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: _textTheme(_darkColorScheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkColorScheme.surfaceContainerLow,
          hintStyle: TextStyle(
            color: Color.fromRGBO(
              _darkColorScheme.onSurface.r.round(),
              _darkColorScheme.onSurface.g.round(),
              _darkColorScheme.onSurface.b.round(),
              0.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _darkColorScheme.primary,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _darkColorScheme.error,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(
            color: _darkColorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _darkColorScheme.surfaceContainerHigh,
          contentTextStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: _darkColorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
        ),
        iconTheme: IconThemeData(
          color: _darkColorScheme.onSurface,
          size: 24,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _darkColorScheme.surfaceContainerHigh,
          labelStyle: GoogleFonts.outfit(
            fontSize: 12,
            color: _darkColorScheme.onSurface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: _darkColorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.onSurface,
          ),
          contentTextStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: _darkColorScheme.onSurface,
          ),
        ),
      );
}
