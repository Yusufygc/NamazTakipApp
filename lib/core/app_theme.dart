import 'package:flutter/material.dart';

/// Eski RN temalarının birebir karşılığı.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.dark,
    required this.background,
    required this.card,
    required this.text,
    required this.textLight,
    required this.danger,
    required this.isDark,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color dark;
  final Color background;
  final Color card;
  final Color text;
  final Color textLight;
  final Color danger;
  final bool isDark;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? dark,
    Color? background,
    Color? card,
    Color? text,
    Color? textLight,
    Color? danger,
    bool? isDark,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      dark: dark ?? this.dark,
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      textLight: textLight ?? this.textLight,
      danger: danger ?? this.danger,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      dark: Color.lerp(dark, other.dark, t)!,
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

class AppThemeDef {
  const AppThemeDef(this.key, this.name, this.icon, this.palette);

  final String key;
  final String name;
  final String icon;
  final AppPalette palette;
}

const _danger = Color(0xFFFF8A80);

const List<AppThemeDef> kThemes = [
  AppThemeDef(
    'default',
    'Varsayılan',
    '🌿',
    AppPalette(
      primary: Color(0xFFA5C89E),
      secondary: Color(0xFFD8E983),
      accent: Color(0xFFFFFBB1),
      dark: Color(0xFFAEB877),
      background: Color(0xFFFAFAFA),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF2C3E50),
      textLight: Color(0xFF7F8C8D),
      danger: _danger,
      isDark: false,
    ),
  ),
  AppThemeDef(
    'dark',
    'Koyu',
    '🌙',
    AppPalette(
      primary: Color(0xFF5C8A6E),
      secondary: Color(0xFF8BC34A),
      accent: Color(0xFFFFD54F),
      dark: Color(0xFF37474F),
      background: Color(0xFF121212),
      card: Color(0xFF1E1E1E),
      text: Color(0xFFE0E0E0),
      textLight: Color(0xFF9E9E9E),
      danger: _danger,
      isDark: true,
    ),
  ),
  AppThemeDef(
    'ocean',
    'Okyanus',
    '🌊',
    AppPalette(
      primary: Color(0xFF5B9BD5),
      secondary: Color(0xFF81D4FA),
      accent: Color(0xFFB3E5FC),
      dark: Color(0xFF1565C0),
      background: Color(0xFFF5F9FF),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF1A237E),
      textLight: Color(0xFF5C6BC0),
      danger: _danger,
      isDark: false,
    ),
  ),
  AppThemeDef(
    'rose',
    'Gül Kurusu',
    '🌹',
    AppPalette(
      primary: Color(0xFFC2727A),
      secondary: Color(0xFFF48FB1),
      accent: Color(0xFFFCE4EC),
      dark: Color(0xFF880E4F),
      background: Color(0xFFFFF5F7),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF3E2723),
      textLight: Color(0xFF8D6E63),
      danger: _danger,
      isDark: false,
    ),
  ),
  AppThemeDef(
    'gold',
    'Altın',
    '✨',
    AppPalette(
      primary: Color(0xFFC9A94E),
      secondary: Color(0xFFFFD54F),
      accent: Color(0xFFFFF8E1),
      dark: Color(0xFF6D5F1B),
      background: Color(0xFFFFFEF5),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF3E2723),
      textLight: Color(0xFF8D6E63),
      danger: _danger,
      isDark: false,
    ),
  ),
];

AppThemeDef themeByKey(String key) =>
    kThemes.firstWhere((t) => t.key == key, orElse: () => kThemes.first);

ThemeData buildTheme(AppPalette p) {
  final brightness = p.isDark ? Brightness.dark : Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: brightness,
  ).copyWith(
    primary: p.primary,
    secondary: p.secondary,
    surface: p.card,
    onSurface: p.text,
    error: p.danger,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    extensions: [p],
    appBarTheme: AppBarTheme(
      backgroundColor: p.primary,
      foregroundColor: p.isDark ? p.text : Colors.white,
      elevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: p.isDark ? p.text : Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: p.background, width: 280),
    dividerColor: p.dark.withValues(alpha: 0.15),
    textTheme: ThemeData(brightness: brightness)
        .textTheme
        .apply(bodyColor: p.text, displayColor: p.text),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : null),
    ),
  );
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
