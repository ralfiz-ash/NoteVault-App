/// Tag colours as "#RRGGBB" strings. The domain and database only ever see
/// these strings; the presentation layer turns them into Flutter colours.
abstract final class TagColors {
  /// Olive from the NoteVault palette. Used for new tags and whenever a
  /// stored value is missing or invalid.
  static const defaultValue = '#BDB76B';

  /// The choices offered by the colour picker.
  static const palette = <String>[
    '#BDB76B', // olive (default)
    '#D4AF37', // gold
    '#CE8946', // bronze
    '#C0392B', // red
    '#E67E22', // orange
    '#F1C40F', // yellow
    '#27AE60', // green
    '#16A085', // teal
    '#2980B9', // blue
    '#8E44AD', // purple
    '#D35400', // rust
    '#7F8C8D', // grey
  ];

  static final _hex = RegExp(r'^#[0-9A-F]{6}$');

  static bool isValid(String? value) =>
      value != null && _hex.hasMatch(value.toUpperCase());

  /// Upper-case "#RRGGBB", or [defaultValue] if [value] is not a colour.
  static String normalize(String? value) =>
      isValid(value) ? value!.toUpperCase() : defaultValue;
}
