import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/pump.dart';

void main() {
  for (final language in languages) {
    group('[$language] Settings', () {
      late AppLocalizations l10n;
      setUp(() async => l10n = await l10nFor(language));

      Future<Events<SettingsEvent>> show(WidgetTester tester, UserSettings settings) async {
        final events = Events<SettingsEvent>();
        await pumpView(
          tester,
          SettingsView(settings: settings, onEvent: events.call),
          language: language,
        );
        return events;
      }

      testWidgets('shows the current choices as selected', (tester) async {
        await show(tester, UserSettings.defaults.copyWith(theme: AppTheme.dark));
        SegmentedButton<T> segmented<T>(String key) => tester.widget<SegmentedButton<T>>(
          find.descendant(of: find.byKey(Key(key)), matching: find.byType(SegmentedButton<T>)),
        );
        expect(segmented<TemperatureUnit>('settings.temperature').selected, {
          TemperatureUnit.celsius,
        });
        expect(segmented<WindSpeedUnit>('settings.wind').selected, {
          WindSpeedUnit.kilometersPerHour,
        });
        expect(segmented<AppTheme>('settings.theme').selected, {AppTheme.dark});
      });

      testWidgets('each choice reports the new value (US-08)', (tester) async {
        final events = await show(tester, UserSettings.defaults);
        await tester.tap(find.text(isolate(l10n.settingsUnitFahrenheit)));
        await tester.tap(find.text(isolate(l10n.settingsUnitMetersPerSecond)));
        await tester.tap(find.text(l10n.settingsThemeLight));
        expect(events.sent, [
          isA<SettingsTemperatureUnitChanged>().having(
            (e) => e.unit,
            'unit',
            TemperatureUnit.fahrenheit,
          ),
          isA<SettingsWindSpeedUnitChanged>().having(
            (e) => e.unit,
            'unit',
            WindSpeedUnit.metersPerSecond,
          ),
          isA<SettingsThemeChanged>().having((e) => e.theme, 'theme', AppTheme.light),
        ]);
      });

      testWidgets('unit symbols keep their order in every language ("°C", never "C°")', (
        tester,
      ) async {
        await show(tester, UserSettings.defaults);
        for (final symbol in ['°C', '°F', 'km/h', 'm/s', 'mph']) {
          expect(find.text(isolate(symbol)), findsOneWidget, reason: symbol);
        }
      });

      testWidgets('the language row shows the language and opens the system page (ADR-0005)', (
        tester,
      ) async {
        final events = await show(tester, UserSettings.defaults);
        expect(find.textContaining(l10n.languageName), findsOneWidget);
        await tester.tap(find.text(l10n.settingsLanguageOpen));
        await tester.tap(find.text(l10n.settingsAbout));
        expect(events.sent, [isA<SettingsOpenLanguageSettings>(), isA<SettingsOpenAbout>()]);
      });
    });

    testWidgets('[$language] About shows the attribution and the version (US-10)', (tester) async {
      final l10n = await l10nFor(language);
      final events = Events<AboutEvent>();
      await pumpView(
        tester,
        AboutView(version: '1.0.0', onEvent: events.call),
        language: language,
      );
      expect(find.text('Atmos'), findsOneWidget);
      expect(find.text(l10n.aboutVersion('1.0.0')), findsOneWidget);
      expect(find.text(l10n.aboutLicense), findsOneWidget);
      await tester.tap(find.text(l10n.aboutDataSource));
      await tester.tap(find.text(l10n.aboutSourceCode));
      expect(events.sent, [isA<AboutOpenDataSource>(), isA<AboutOpenSourceCode>()]);
    });
  }
}
