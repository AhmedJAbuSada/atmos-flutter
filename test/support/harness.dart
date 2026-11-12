import 'package:atmos/app/atmos_app.dart';
import 'package:atmos_domain/testing.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Records what the app asked the phone to do, and answers the permission dialog.
final class FakeAppPlatform implements AppPlatform {
  PermissionAnswer answer = PermissionAnswer.granted;
  void Function(PermissionAnswer answer)? onAnswer;
  final List<String> calls = [];

  @override
  Future<PermissionAnswer> requestLocationPermission() async {
    calls.add('requestLocationPermission');
    onAnswer?.call(answer);
    return answer;
  }

  @override
  Future<void> openAppSettings() async => calls.add('openAppSettings');

  @override
  Future<void> openLanguageSettings() async => calls.add('openLanguageSettings');

  @override
  Future<void> openUrl(Uri url) async => calls.add('openUrl $url');
}

/// The real app (routes, view models, views) over fakes of the domain interfaces: the same
/// overrides the composition root gives the real app, with no network and no plugin.
final class AppHarness {
  final weather = FakeWeatherRepository();
  final cities = FakeCityRepository();
  final settings = FakeSettingsRepository();
  final location = FakeLocationRepository();
  final platform = FakeAppPlatform();

  /// Starts the app on a phone whose language list is [phone].
  Future<void> start(WidgetTester tester, {List<Locale> phone = const [Locale('en')]}) async {
    tester.platformDispatcher.localesTestValue = phone;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(weather),
          cityRepositoryProvider.overrideWithValue(cities),
          settingsRepositoryProvider.overrideWithValue(settings),
          locationRepositoryProvider.overrideWithValue(location),
          dateProviderProvider.overrideWithValue(FixedDateProvider()),
          appPlatformProvider.overrideWithValue(platform),
        ],
        child: const AtmosApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// The current temperature on Home (the hourly list can repeat it).
Finder currentTemperature(String text) =>
    find.descendant(of: find.byKey(const Key('home.current')), matching: find.text(text));
