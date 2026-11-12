import 'package:atmos_domain/atmos_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/atmos_colors.dart';

/// What the user can do in Settings (US-08).
sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsTemperatureUnitChanged extends SettingsEvent {
  const SettingsTemperatureUnitChanged(this.unit);

  final TemperatureUnit unit;
}

final class SettingsWindSpeedUnitChanged extends SettingsEvent {
  const SettingsWindSpeedUnitChanged(this.unit);

  final WindSpeedUnit unit;
}

final class SettingsThemeChanged extends SettingsEvent {
  const SettingsThemeChanged(this.theme);

  final AppTheme theme;
}

/// Opens the system page where the app language is changed: the OS owns it (ADR-0005).
final class SettingsOpenLanguageSettings extends SettingsEvent {
  const SettingsOpenLanguageSettings();
}

final class SettingsOpenAbout extends SettingsEvent {
  const SettingsOpenAbout();
}

/// Settings (US-08): the user's settings in, events out. The language row shows the current
/// language (from the app's locale, which the OS chose) and opens the system settings; there is
/// no language picker in the app.
class SettingsView extends StatelessWidget {
  const SettingsView({required this.settings, required this.onEvent, super.key});

  final UserSettings settings;
  final ValueChanged<SettingsEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
        children: [
          _Choice<TemperatureUnit>(
            key: const Key('settings.temperature'),
            title: l10n.settingsTemperature,
            selected: settings.temperatureUnit,
            options: {
              TemperatureUnit.celsius: l10n.settingsUnitCelsius,
              TemperatureUnit.fahrenheit: l10n.settingsUnitFahrenheit,
            },
            onChanged: (unit) => onEvent(SettingsTemperatureUnitChanged(unit)),
          ),
          _Choice<WindSpeedUnit>(
            key: const Key('settings.wind'),
            title: l10n.settingsWindSpeed,
            selected: settings.windSpeedUnit,
            options: {
              WindSpeedUnit.kilometersPerHour: l10n.settingsUnitKilometersPerHour,
              WindSpeedUnit.metersPerSecond: l10n.settingsUnitMetersPerSecond,
              WindSpeedUnit.milesPerHour: l10n.settingsUnitMilesPerHour,
            },
            onChanged: (unit) => onEvent(SettingsWindSpeedUnitChanged(unit)),
          ),
          _Choice<AppTheme>(
            key: const Key('settings.theme'),
            title: l10n.settingsThemeTitle,
            selected: settings.theme,
            options: {
              AppTheme.system: l10n.settingsThemeSystem,
              AppTheme.light: l10n.settingsThemeLight,
              AppTheme.dark: l10n.settingsThemeDark,
            },
            onChanged: (theme) => onEvent(SettingsThemeChanged(theme)),
          ),
          const Divider(height: AtmosSpacing.xl),
          ListTile(
            key: const Key('settings.language'),
            contentPadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.settingsLanguageTitle),
            subtitle: Text(
              '${l10n.languageName}\n${l10n.settingsLanguageFooter}',
              style: TextStyle(color: colors.secondaryText),
            ),
            isThreeLine: true,
            trailing: TextButton(
              onPressed: () => onEvent(const SettingsOpenLanguageSettings()),
              child: Text(l10n.settingsLanguageOpen),
            ),
          ),
          const Divider(height: AtmosSpacing.xl),
          ListTile(
            key: const Key('settings.about'),
            contentPadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.settingsAbout),
            // A chevron that points forward: Material mirrors this icon in Arabic.
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onEvent(const SettingsOpenAbout()),
          ),
        ],
      ),
    );
  }
}

/// A title and one segmented choice. Screen readers hear each segment as a selectable button,
/// "°C, selected".
class _Choice<T extends Enum> extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.selected,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String title;
  final T selected;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AtmosSpacing.m),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: AtmosSpacing.s),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: [
              for (final MapEntry(key: value, value: label) in options.entries)
                ButtonSegment(
                  value: value,
                  label: Text(label, key: Key('settings.option.${value.name}')),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (values) => onChanged(values.single),
          ),
        ),
      ],
    ),
  );
}
