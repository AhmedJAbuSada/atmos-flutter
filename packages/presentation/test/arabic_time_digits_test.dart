import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A file of its own on purpose: nothing here calls intl's `initializeDateFormatting`, exactly
/// like the app. Then the date data comes from Material's localization delegate, where `ar`
/// writes Arabic-Indic digits (٧:٤٦). The step-07 Arabic screenshots showed those digits in every
/// time on Home; with intl's data loaded first (as in weather_formatter_test.dart) the bug hides.
void main() {
  test('Arabic times and day names keep Latin digits with the app\'s date data', () async {
    await GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
    final format = WeatherFormatter('ar', utcOffset: const Duration(hours: 3));
    final sunrise = DateTime.utc(2026, 11, 11, 4, 46); // 07:46 in Istanbul

    final time = format.time(sunrise);
    expect(time, isNot(matches(RegExp('[\\u0660-\\u0669\\u06F0-\\u06F9]'))), reason: time);
    expect(time.replaceAll(RegExp('[\\u2066-\\u2069]'), ''), '7:46 ص');
  });
}
