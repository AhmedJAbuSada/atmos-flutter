import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/pump.dart';

/// [text] inside the current-conditions block (the hourly list repeats some temperatures).
Finder inCurrent(String text) =>
    find.descendant(of: find.byKey(const Key('home.current')), matching: find.text(text));

HomeContent content({Duration? outdatedBy, String? placeName, bool refreshing = false}) =>
    HomeContent(
      forecast: istanbulForecast(),
      settings: UserSettings.defaults,
      placeName: placeName,
      outdatedBy: outdatedBy,
      refreshing: refreshing,
    );

void main() {
  for (final language in languages) {
    group('[$language] Home', () {
      late AppLocalizations l10n;
      setUp(() async => l10n = await l10nFor(language));

      Future<Events<HomeEvent>> show(WidgetTester tester, HomeState state) async {
        final events = Events<HomeEvent>();
        await pumpView(
          tester,
          HomeView(state: state, onEvent: events.call),
          language: language,
        );
        return events;
      }

      testWidgets('loading shows the skeleton, announced to screen readers', (tester) async {
        await show(tester, const HomeLoading());
        expect(find.byKey(const Key('home.loading')), findsOneWidget);
        expect(find.bySemanticsLabel(l10n.homeLoading), findsOneWidget);
      });

      testWidgets('without location, offers both ways forward (F-02)', (tester) async {
        final events = await show(tester, const HomeNeedsLocation());
        expect(find.text(l10n.homeNoLocationTitle), findsOneWidget);
        await tester.tap(find.text(l10n.homeAllowLocation));
        await tester.tap(find.text(l10n.homeSearchCity));
        expect(events.sent, [isA<HomeRequestLocation>(), isA<HomeOpenCities>()]);
      });

      testWidgets('a failed load shows a human message and a retry (US-09)', (tester) async {
        final events = await show(tester, const HomeFailed(NoConnection()));
        expect(find.text(l10n.errorNoConnection), findsOneWidget);
        await tester.tap(find.text(l10n.actionRetry));
        expect(events.sent, [isA<HomeRetry>()]);
      });

      testWidgets('a cancelled load is never shown: the skeleton stays', (tester) async {
        await show(tester, const HomeFailed(Cancelled()));
        expect(find.byKey(const Key('home.loading')), findsOneWidget);
        expect(find.text(l10n.actionRetry), findsNothing);
      });

      testWidgets('content shows the current weather, the hours and the days', (tester) async {
        await show(tester, content());
        final format = WeatherFormatter(language, utcOffset: const Duration(hours: 3));
        expect(find.text(l10n.homeCurrentLocation), findsOneWidget);
        expect(
          inCurrent(format.temperature(const Temperature(14.9), TemperatureUnit.celsius)),
          findsOneWidget,
        );
        expect(find.text(l10n.conditionOvercast), findsOneWidget);
        expect(find.text(l10n.homeNow), findsOneWidget);
        expect(find.text(l10n.homeToday), findsOneWidget);
        await tester.dragUntilVisible(
          find.text(l10n.homeAttribution),
          find.byKey(const Key('home.forecast')),
          const Offset(0, -200),
        );
        expect(find.text(l10n.homeAttribution), findsOneWidget);
        expect(
          find.text(
            '🌅 ${l10n.homeSunriseSunset(format.time(istanbulForecast().daily.first.sunrise ?? DateTime(0)), format.time(istanbulForecast().daily.first.sunset ?? DateTime(0)))}',
          ),
          findsOneWidget,
        );
        // 0% is hidden (US-02); 20% is shown.
        expect(find.text(format.percentage(0)), findsNothing);
        expect(find.text(format.percentage(20)), findsOneWidget);
        expect(find.byKey(const Key('home.outdated')), findsNothing);
      });

      testWidgets('outdated data shows "Updated 2 hours ago" (F-08)', (tester) async {
        await show(tester, content(outdatedBy: const Duration(hours: 2)));
        expect(find.text('⚠️ ${l10n.homeUpdatedHours(2)}'), findsOneWidget);
      });

      testWidgets('a saved city shows its name; the top bar opens Cities and Settings', (
        tester,
      ) async {
        final events = await show(tester, content(placeName: 'Ankara', refreshing: true));
        expect(find.text('Ankara'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        await tester.tap(find.byTooltip(l10n.homeOpenCities));
        await tester.tap(find.byTooltip(l10n.homeOpenSettings));
        expect(events.sent, [isA<HomeOpenCities>(), isA<HomeOpenSettings>()]);
      });

      testWidgets('pull to refresh sends Refresh (US-06)', (tester) async {
        final events = await show(tester, content());
        await tester.fling(find.byKey(const Key('home.forecast')), const Offset(0, 400), 1000);
        await tester.pumpAndSettle();
        expect(events.sent, [isA<HomeRefresh>()]);
      });

      testWidgets('the layout direction follows the language', (tester) async {
        await show(tester, content());
        final direction = Directionality.of(tester.element(find.byKey(const Key('home.forecast'))));
        expect(direction, language == 'ar' ? TextDirection.rtl : TextDirection.ltr);
      });

      testWidgets('the largest system font (200%) fits without overflow (NF-03)', (tester) async {
        await pumpView(
          tester,
          HomeView(
            state: content(outdatedBy: const Duration(days: 3)),
            onEvent: (_) {},
          ),
          language: language,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('each hour is read as one sentence', (tester) async {
        await show(tester, content());
        final format = WeatherFormatter(language, utcOffset: const Duration(hours: 3));
        final now =
            '${l10n.homeNow}, ${format.temperature(const Temperature(14.8), TemperatureUnit.celsius)}, ${l10n.conditionPartlyCloudy}';
        expect(find.bySemanticsLabel(now), findsOneWidget);
      });
    });
  }

  testWidgets('Fahrenheit and miles per hour change every value, with no new data (US-08)', (
    tester,
  ) async {
    await pumpView(
      tester,
      HomeView(
        state: HomeContent(
          forecast: istanbulForecast(),
          settings: const UserSettings(
            temperatureUnit: TemperatureUnit.fahrenheit,
            windSpeedUnit: WindSpeedUnit.milesPerHour,
          ),
        ),
        onEvent: (_) {},
      ),
    );
    expect(inCurrent('\u206659°\u2069'), findsOneWidget);
    expect(find.textContaining('15 mph'), findsOneWidget);
  });

  testWidgets('the dark theme renders the same content', (tester) async {
    await pumpView(
      tester,
      HomeView(state: content(), onEvent: (_) {}),
      colors: AtmosColors.dark,
    );
    expect(inCurrent('\u206615°\u2069'), findsOneWidget);
  });
}
