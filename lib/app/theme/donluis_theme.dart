import 'package:flutter/material.dart';

/// Colores corporativos extraídos del splash (splash_page.dart).
class DonLuisColors {
  DonLuisColors._();

  static const Color primary = Color(0xFF1E5AA8);   // cBlue
  static const Color primaryLight = Color(0xFF2F8ED9); // cBlue2
  static const Color secondary = Color(0xFF0F8A55);   // cGreen2
  static const Color accent = Color(0xFFF5C400);

  /// Degradado de fondo suave (opacidad ~10%) para scaffolds.
  static const List<Color> gradientBackgroundColors = [
    Color(0x1A1E5AA8), // primary with ~10% opacity
    Color(0x1A2F8ED9),
    Color(0x1A0F8A55),
  ];
  static const List<double> gradientBackgroundStops = [0.0, 0.45, 1.0];

  /// Surface para cards (casi blanco con tinte muy leve).
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
}

ThemeData get donluisTheme {
  const primary = DonLuisColors.primary;
  const secondary = DonLuisColors.secondary;
  const surface = DonLuisColors.surface;
  const onPrimary = Colors.white;
  const onSecondary = Colors.white;
  const onSurface = Color(0xFF1A1D21);
  const onSurfaceVariant = Color(0xFF5C6268);
  const outline = Color(0xFFD0D5DD);
  const error = Color(0xFFB3261E);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      error: error,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: onSurface,
      iconTheme: const IconThemeData(color: onSurface, size: 24),
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: DonLuisColors.surfaceCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
      hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
      helperStyle: TextStyle(color: onSurfaceVariant.withOpacity(0.9), fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: primary),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: outline,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      subtitleTextStyle: const TextStyle(fontSize: 13, color: onSurfaceVariant),
    ),
    iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 3,
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontSize: 14),
    ),
  );
}
