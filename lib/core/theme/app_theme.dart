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

/// Tema tanımı. Görünen ad `SettingsStrings.themeName(key)`, ikon
/// `AppIcons.theme(key)` ile çözülür.
class AppThemeDef {
  const AppThemeDef(this.key, this.palette);

  final String key;
  final AppPalette palette;
}

const _dangerLight = Color(0xFFC62828);
const _dangerDark = Color(0xFFEF6C6C);

const List<AppThemeDef> kThemes = [
  // Selçuklu Zümrüdü (Varsayılan)
  AppThemeDef(
    'default',
    AppPalette(
      primary: Color(0xFF1B5E43),
      secondary: Color(0xFFC89D3C),
      accent: Color(0xFFEBE3D0),
      dark: Color(0xFF103F2C),
      background: Color(0xFFF8F5EE),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF18261F),
      textLight: Color(0xFF5A6D63),
      danger: _dangerLight,
      isDark: false,
    ),
  ),
  // Gece Kubbesi (Koyu)
  AppThemeDef(
    'dark',
    AppPalette(
      primary: Color(0xFF38B281),
      secondary: Color(0xFFE2B553),
      accent: Color(0xFF1F362D),
      dark: Color(0xFF1F7A56),
      background: Color(0xFF0C1411),
      card: Color(0xFF15221D),
      text: Color(0xFFEAF2EE),
      textLight: Color(0xFF93A89E),
      danger: _dangerDark,
      isDark: true,
    ),
  ),
  // İznik Çinisi (Okyanus)
  AppThemeDef(
    'ocean',
    AppPalette(
      primary: Color(0xFF175D85),
      secondary: Color(0xFF2EA3B8),
      accent: Color(0xFFD9ECF5),
      dark: Color(0xFF0E3F5C),
      background: Color(0xFFF3F8FB),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF142734),
      textLight: Color(0xFF556E7F),
      danger: _dangerLight,
      isDark: false,
    ),
  ),
  // Gül-i Muhammedî (Gül Kurusu)
  AppThemeDef(
    'rose',
    AppPalette(
      primary: Color(0xFF8C3747),
      secondary: Color(0xFFC87A82),
      accent: Color(0xFFF5E1E4),
      dark: Color(0xFF63212E),
      background: Color(0xFFFCF6F7),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF2B171B),
      textLight: Color(0xFF73565C),
      danger: _dangerLight,
      isDark: false,
    ),
  ),
  // Tezhip Altını (Altın)
  AppThemeDef(
    'gold',
    AppPalette(
      primary: Color(0xFF8E6918),
      secondary: Color(0xFFD1A234),
      accent: Color(0xFFF4E9CE),
      dark: Color(0xFF63480C),
      background: Color(0xFFFAF6EC),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF282011),
      textLight: Color(0xFF6E6045),
      danger: _dangerLight,
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
    onPrimary: p.isDark ? const Color(0xFF09130F) : Colors.white,
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
      backgroundColor: p.background,
      foregroundColor: p.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: p.text,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: p.primary.withValues(alpha: p.isDark ? 0.16 : 0.09),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: p.primary.withValues(alpha: p.isDark ? 0.22 : 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? p.primary : p.textLight,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? p.primary : p.textLight,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.card;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return p.text;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: p.primary.withValues(alpha: 0.25)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    dividerColor: p.primary.withValues(alpha: 0.12),
    textTheme: ThemeData(brightness: brightness)
        .textTheme
        .apply(bodyColor: p.text, displayColor: p.text),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : null,
      ),
    ),
  );
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
