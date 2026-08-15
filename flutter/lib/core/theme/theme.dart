import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 color schemes matching the React app's CSS variables in
/// `src/index.css`. Kept as explicit Color values (not `fromSeed`) because the
/// React design has been hand-tuned and we want a 1:1 visual match.
class AppTheme {
  static const _primaryLight = Color(0xFF4E6174);
  static const _onPrimaryLight = Color(0xFFF6F9FF);
  static const _primaryContainerLight = Color(0xFFD1E5FB);
  static const _onPrimaryContainerLight = Color(0xFF415466);

  static const _secondaryLight = Color(0xFF546354);
  static const _onSecondaryLight = Color(0xFFEDFDEA);
  static const _secondaryContainerLight = Color(0xFFD7E7D4);
  static const _onSecondaryContainerLight = Color(0xFF475547);

  static const _tertiaryLight = Color(0xFF8A4B5D);
  static const _onTertiaryLight = Color(0xFFFFFFFF);
  static const _tertiaryContainerLight = Color(0xFFFAE1E8);
  static const _onTertiaryContainerLight = Color(0xFF4A212F);

  static const _errorLight = Color(0xFFA73B21);
  static const _errorContainerLight = Color(0xFFFD795A);

  static const _surfaceLight = Color(0xFFF9F9F7);
  static const _surfaceContainerLight = Color(0xFFECEEEC);
  static const _onSurfaceLight = Color(0xFF2F3332);
  static const _onSurfaceVariantLight = Color(0xFF5C605E);
  static const _outlineLight = Color(0xFF777C79);
  static const _outlineVariantLight = Color(0xFFAFB3B0);
  static const _inverseSurfaceLight = Color(0xFF0D0F0E);

  static const _primaryDark = Color(0xFFB3CBE6);
  static const _onPrimaryDark = Color(0xFF121F2D);
  static const _primaryContainerDark = Color(0xFF304051);
  static const _onPrimaryContainerDark = Color(0xFFE6F0FA);

  static const _secondaryDark = Color(0xFFB6CCB5);
  static const _onSecondaryDark = Color(0xFF0D1E0D);
  static const _secondaryContainerDark = Color(0xFF334233);
  static const _onSecondaryContainerDark = Color(0xFFDCEBDC);

  static const _tertiaryDark = Color(0xFFEEAABC);
  static const _onTertiaryDark = Color(0xFF3B0014);
  static const _tertiaryContainerDark = Color(0xFF682638);
  static const _onTertiaryContainerDark = Color(0xFFFFD9E4);

  static const _errorDark = Color(0xFFFFA891);
  static const _errorContainerDark = Color(0xFF8C1D00);

  static const _surfaceDark = Color(0xFF121312);
  static const _surfaceContainerDark = Color(0xFF242625);
  static const _onSurfaceDark = Color(0xFFE0E3E0);
  static const _onSurfaceVariantDark = Color(0xFFB0B4B1);
  static const _outlineDark = Color(0xFF888D8A);
  static const _outlineVariantDark = Color(0xFF424644);
  static const _inverseSurfaceDark = Color(0xFFE0E3E0);

  static ColorScheme get lightScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: _primaryLight,
        onPrimary: _onPrimaryLight,
        primaryContainer: _primaryContainerLight,
        onPrimaryContainer: _onPrimaryContainerLight,
        secondary: _secondaryLight,
        onSecondary: _onSecondaryLight,
        secondaryContainer: _secondaryContainerLight,
        onSecondaryContainer: _onSecondaryContainerLight,
        tertiary: _tertiaryLight,
        onTertiary: _onTertiaryLight,
        tertiaryContainer: _tertiaryContainerLight,
        onTertiaryContainer: _onTertiaryContainerLight,
        error: _errorLight,
        onError: Colors.white,
        errorContainer: _errorContainerLight,
        onErrorContainer: Color(0xFF410000),
        surface: _surfaceLight,
        onSurface: _onSurfaceLight,
        surfaceContainerHighest: Color(0xFFE0E3E0),
        surfaceContainerHigh: Color(0xFFE6E9E6),
        surfaceContainer: _surfaceContainerLight,
        surfaceContainerLow: Color(0xFFF3F4F2),
        surfaceContainerLowest: Colors.white,
        onSurfaceVariant: _onSurfaceVariantLight,
        outline: _outlineLight,
        outlineVariant: _outlineVariantLight,
        inverseSurface: _inverseSurfaceLight,
        onInverseSurface: _surfaceLight,
        inversePrimary: _primaryDark,
        shadow: Color(0x1F2F3332),
        scrim: Color(0x4D2F3332),
      );

  static ColorScheme get darkScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryDark,
        onPrimary: _onPrimaryDark,
        primaryContainer: _primaryContainerDark,
        onPrimaryContainer: _onPrimaryContainerDark,
        secondary: _secondaryDark,
        onSecondary: _onSecondaryDark,
        secondaryContainer: _secondaryContainerDark,
        onSecondaryContainer: _onSecondaryContainerDark,
        tertiary: _tertiaryDark,
        onTertiary: _onTertiaryDark,
        tertiaryContainer: _tertiaryContainerDark,
        onTertiaryContainer: _onTertiaryContainerDark,
        error: _errorDark,
        onError: Color(0xFF410000),
        errorContainer: _errorContainerDark,
        onErrorContainer: Color(0xFFFFDAD4),
        surface: _surfaceDark,
        onSurface: _onSurfaceDark,
        surfaceContainerHighest: Color(0xFF303331),
        surfaceContainerHigh: Color(0xFF2A2C2B),
        surfaceContainer: _surfaceContainerDark,
        surfaceContainerLow: Color(0xFF1E201F),
        surfaceContainerLowest: Color(0xFF1A1C1A),
        onSurfaceVariant: _onSurfaceVariantDark,
        outline: _outlineDark,
        outlineVariant: _outlineVariantDark,
        inverseSurface: _inverseSurfaceDark,
        onInverseSurface: _surfaceDark,
        inversePrimary: _primaryLight,
        shadow: Color(0x33000000),
        scrim: Color(0x80000000),
      );

  static ThemeData light() => _build(lightScheme);
  static ThemeData dark() => _build(darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    // Newsreader (serif) for headlines, Manrope (sans) for body and labels —
    // matches the React PWA's Tailwind `--font-headline` / `--font-body`.
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final headline = GoogleFonts.newsreaderTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final body = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final textTheme = base.textTheme.copyWith(
      displayLarge: headline.displayLarge,
      displayMedium: headline.displayMedium,
      displaySmall: headline.displaySmall,
      headlineLarge: headline.headlineLarge,
      headlineMedium: headline.headlineMedium,
      headlineSmall: headline.headlineSmall,
      titleLarge: headline.titleLarge?.copyWith(fontWeight: FontWeight.w500),
      titleMedium: body.titleMedium,
      titleSmall: body.titleSmall,
      bodyLarge: body.bodyLarge,
      bodyMedium: body.bodyMedium,
      bodySmall: body.bodySmall,
      labelLarge: body.labelLarge,
      labelMedium: body.labelMedium,
      labelSmall: body.labelSmall,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: scheme.onSurface,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: const StadiumBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        modalElevation: 0,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        headerBackgroundColor: scheme.primaryContainer,
        headerForegroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        dayShape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return BorderSide.none;
          return BorderSide(color: scheme.outlineVariant);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
