import 'package:atmos_domain/atmos_domain.dart';
import 'package:material_ui/material_ui.dart';

/// Design tokens: every colour the screens use, in one place, light and dark. Screens never
/// write `Color(0xFF1D5FBF)`; they read `AtmosColors.of(context).accent`, so dark mode and a
/// redesign change this file only. The same values as the other three apps.
///
/// Text colours meet WCAG AA (4.5 : 1) on their backgrounds (NF-03); a test checks every pair.
@immutable
final class AtmosColors extends ThemeExtension<AtmosColors> {
  const AtmosColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.accent,
    required this.onAccent,
    required this.separator,
    required this.warningBackground,
    required this.warningText,
    required this.skeleton,
  });

  static const light = AtmosColors(
    brightness: Brightness.light,
    background: Color(0xFFF4F7FB),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF111827),
    secondaryText: Color(0xFF4B5563),
    accent: Color(0xFF1D5FBF),
    onAccent: Color(0xFFFFFFFF),
    separator: Color(0xFFD9DEE7),
    warningBackground: Color(0xFFFFF4D6),
    warningText: Color(0xFF7A4B00),
    skeleton: Color(0xFFE3E8EF),
  );

  static const dark = AtmosColors(
    brightness: Brightness.dark,
    background: Color(0xFF0D1420),
    surface: Color(0xFF182233),
    text: Color(0xFFF3F4F6),
    secondaryText: Color(0xFFB6BFCC),
    accent: Color(0xFF7DB2FF),
    onAccent: Color(0xFF0D1420),
    separator: Color(0xFF2B3648),
    warningBackground: Color(0xFF3D2E0A),
    warningText: Color(0xFFFFD98A),
    skeleton: Color(0xFF243047),
  );

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color text;
  final Color secondaryText;
  final Color accent;
  final Color onAccent;
  final Color separator;
  final Color warningBackground;
  final Color warningText;
  final Color skeleton;

  static AtmosColors of(BuildContext context) =>
      Theme.of(context).extension<AtmosColors>() ?? light;

  @override
  AtmosColors copyWith() => this;

  /// Themes switch at once, as in the other apps; no colour animation.
  @override
  AtmosColors lerp(AtmosColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Spacing and sizes, shared by both themes.
abstract final class AtmosSpacing {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;

  /// The smallest touch target: Android's 48 dp, which is larger than Apple's 44 pt.
  static const minTouchTarget = 48.0;
}

/// A Material 3 theme built from the tokens.
ThemeData atmosTheme(AtmosColors colors) => ThemeData(
  brightness: colors.brightness,
  colorScheme: ColorScheme.fromSeed(
    seedColor: colors.accent,
    brightness: colors.brightness,
    primary: colors.accent,
    onPrimary: colors.onAccent,
    surface: colors.surface,
    onSurface: colors.text,
    onSurfaceVariant: colors.secondaryText,
    outlineVariant: colors.separator,
  ),
  scaffoldBackgroundColor: colors.background,
  materialTapTargetSize: MaterialTapTargetSize.padded,
  extensions: [colors],
);

/// The user's choice wins; "system" follows the phone (US-08).
ThemeMode themeModeFor(AppTheme theme) => switch (theme) {
  AppTheme.system => ThemeMode.system,
  AppTheme.light => ThemeMode.light,
  AppTheme.dark => ThemeMode.dark,
};
