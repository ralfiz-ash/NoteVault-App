import 'package:flutter/material.dart';

/// NoteVault "Golden taupe" theme.
///
/// Dark values come from the approved design. Light on-colours, text and
/// border values are derived from the original palette (see docs/colour-palette.md).
const lightGoldenTaupeScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFD4AF37),
  onPrimary: Color(0xFF2B2208),
  secondary: Color(0xFFBDB76B),
  onSecondary: Color(0xFF26240B),
  tertiary: Color(0xFFCE8946),
  onTertiary: Color(0xFF2A1807),
  surface: Color(0xFFFDFBD4),
  onSurface: Color(0xFF1F1D12),
  onSurfaceVariant: Color(0xFF5C5840),
  surfaceContainerHighest: Color(0xFFF3EFBC),
  outline: Color(0xFFD6D09A),
  error: Color(0xFFB3261E),
  onError: Color(0xFFFFFFFF),
);

const darkGoldenTaupeScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFDAC172),
  onPrimary: Color(0xFF261F07),
  secondary: Color(0xFFC8C493),
  onSecondary: Color(0xFF222110),
  tertiary: Color(0xFFD3A273),
  onTertiary: Color(0xFF2A1807),
  surface: Color(0xFF1D1C16),
  onSurface: Color(0xFFF7F5DF),
  // Secondary text colour (#B8B39E) from the design.
  onSurfaceVariant: Color(0xFFB8B39E),
  surfaceContainerHighest: Color(0xFF2C2A20),
  outline: Color(0xFF3B382C),
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
);

/// Text-coloured actions (links, text/outlined buttons) in the light theme.
/// The palette gold (#D4AF37) is only ~2:1 on cream, too faint for text; this
/// darker gold is ~5.8:1 (WCAG AA). Fills keep the palette gold.
const _lightActionText = Color(0xFF7A5E00);

ThemeData _build(ColorScheme scheme) {
  final actionText = scheme.brightness == Brightness.light
      ? _lightActionText
      : scheme.primary;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: actionText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: actionText),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline),
      ),
    ),
  );
}

class AppTheme {
  const AppTheme._();

  static final ThemeData light = _build(lightGoldenTaupeScheme);
  static final ThemeData dark = _build(darkGoldenTaupeScheme);
}
