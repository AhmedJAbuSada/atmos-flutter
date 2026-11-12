import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_domain/testing.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

/// Journeys through the real app: routes, view models and views, with fakes behind the
/// providers. They tap what a user taps, in the user's language.
void main() {
  final ankara = city(323786, 'Ankara');

  testWidgets('[tr] search a city, add it, pick it: Home shows it (US-04, US-05)', (tester) async {
    final app = AppHarness()..cities.searchResult = Ok([ankara]);
    await app.start(tester, phone: const [Locale('tr', 'TR')]);
    expect(find.text('Mevcut konum'), findsOneWidget);
    expect(currentTemperature('\u206615°\u2069'), findsOneWidget);

    await tester.tap(find.byTooltip('Şehirler'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cities.search')), 'ank');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(app.cities.searches, [(query: 'ank', languageCode: 'tr')]);

    await tester.tap(find.byTooltip('Ankara ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ankara'));
    await tester.pumpAndSettle();

    expect(find.text('Ankara'), findsOneWidget); // the title on Home
    expect(find.byKey(const Key('home.current')), findsOneWidget);
  });

  testWidgets('[en] °F in Settings changes Home, with no new download (US-08)', (tester) async {
    final app = AppHarness();
    await app.start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(currentTemperature('\u206659°\u2069'), findsOneWidget);
    expect(app.weather.fetchCount, 1);
  });

  testWidgets('[en] the dark theme from Settings applies to the whole app', (tester) async {
    final app = AppHarness();
    await app.start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(Scaffold).last)).brightness, Brightness.dark);
  });

  testWidgets('[en] the language row and the About links open the system (ADR-0005, F-11)', (
    tester,
  ) async {
    final app = AppHarness();
    await app.start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change language'));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Version 1.0.0'), findsOneWidget);
    await tester.tap(find.text('Weather data by Open-Meteo.com'));
    await tester.tap(find.text('Source code on GitHub'));
    await tester.pump();

    expect(app.platform.calls, [
      'openLanguageSettings',
      'openUrl https://open-meteo.com/',
      'openUrl https://github.com/AhmedJAbuSada/atmos-flutter',
    ]);
  });

  testWidgets('[ar] explanation first, then the dialog; allowed, the forecast loads (US-01)', (
    tester,
  ) async {
    final app = AppHarness()..location.result = const Err(LocationPermissionDenied());
    app.platform.onAnswer = (_) => app.location.result = Ok(istanbul);
    await app.start(tester, phone: const [Locale('ar')]);
    expect(find.text('أين أنت؟'), findsOneWidget);
    expect(app.platform.calls, isEmpty);

    await tester.tap(find.text('السماح بالموقع'));
    await tester.pumpAndSettle();

    expect(app.platform.calls, ['requestLocationPermission']);
    expect(find.text('الموقع الحالي'), findsOneWidget);
    expect(currentTemperature('\u206615°\u2069'), findsOneWidget);
  });

  testWidgets('[en] when the system will not ask again, the app settings open', (tester) async {
    final app = AppHarness()..location.result = const Err(LocationPermissionDenied());
    app.platform.answer = PermissionAnswer.blocked;
    await app.start(tester);
    await tester.tap(find.text('Allow location'));
    await tester.pumpAndSettle();
    expect(app.platform.calls, ['requestLocationPermission', 'openAppSettings']);
    expect(find.text('Where are you?'), findsOneWidget);
  });

  testWidgets('[en] without location, "Search for a city" leads to Cities (F-02)', (tester) async {
    final app = AppHarness()..location.result = const Err(LocationPermissionDenied());
    await app.start(tester);
    await tester.tap(find.text('Search for a city'));
    await tester.pumpAndSettle();
    expect(find.text('Cities'), findsOneWidget);
    expect(find.byKey(const Key('cities.search')), findsOneWidget);
  });
}
