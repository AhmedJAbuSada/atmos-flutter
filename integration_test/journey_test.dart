import 'package:atmos/app/atmos_app.dart';
import 'package:atmos/app/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

/// The language the device script set as the app's per-app language before this run. The test
/// checks that the app really shows it: the OS owns the language (ADR-0005).
const expectedLanguage = String.fromEnvironment('EXPECTED_LANGUAGE', defaultValue: 'en');

/// Ankara's id in the geocoding service: the same in every language.
const ankara = 323786;

/// The main journey on a device, with the real data layer and the real API (ADR-0011, ADR-0018):
/// a user who has not allowed location searches, adds and opens a city, then changes the unit
/// (F-02, US-04, US-05, US-08). The same journey as the Android, iOS and React Native apps. The
/// current-location path is covered by the journey tests with fakes: an emulator gives no coarse
/// (Wi-Fi or cell) location. Widgets are found by key, so the same steps run in every language.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('journey without location: search, add, open a city, then °F', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: AppDependencies().overrides, child: const AtmosApp()),
    );
    // Android: screenshots need the Flutter surface as an image, once, before the first one.
    await binding.convertFlutterSurfaceToImage();

    Future<void> screenshot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    // Home explains why it needs the location and offers city search instead.
    await waitFor(tester, find.byKey(const Key('message.secondaryAction')), seconds: 45);
    final language = Localizations.localeOf(tester.element(find.byType(Scaffold).first));
    expect(language.languageCode, expectedLanguage, reason: 'the per-app language set by the OS');
    await screenshot('1-home');
    await tester.tap(find.byKey(const Key('message.secondaryAction')));
    await tester.pumpAndSettle();

    // Search for a city and add it. The real API: the app may take up to ~48 s (15 s timeout,
    // two retries), so the test waits longer.
    await tester.enterText(find.byKey(const Key('cities.search')), 'Ankara');
    await waitFor(tester, find.byKey(const Key('cities.add.$ankara')), seconds: 60);
    FocusManager.instance.primaryFocus?.unfocus(); // hide the keyboard for the screenshot
    await screenshot('2-search');
    await tester.tap(find.byKey(const Key('cities.add.$ankara')));
    await waitFor(tester, find.byKey(const Key('city-$ankara')), seconds: 15);
    await screenshot('3-cities');

    // Open it: Home shows Ankara, with the forecast from the real API.
    await tester.tap(find.byKey(const Key('city-$ankara')));
    await waitFor(tester, find.byKey(const Key('home.current')), seconds: 60);
    await screenshot('4-city');

    // Change the unit in Settings (US-08).
    await tester.tap(find.byKey(const Key('home.openSettings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.option.fahrenheit')));
    await screenshot('5-settings');
  });
}

/// Pumps frames until [finder] finds something, or fails after [seconds] with what was on screen.
Future<void> waitFor(WidgetTester tester, Finder finder, {required int seconds}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = [
    for (final element in find.byType(Text).evaluate())
      if (element.widget case Text(:final data?)) data,
  ];
  fail('Not found after $seconds s: $finder. Texts on screen: ${texts.take(15).join(' | ')}');
}
