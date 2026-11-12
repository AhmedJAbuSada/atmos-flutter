import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Locale pick(List<Locale>? phone) => resolveAppLocale(phone, supportedLocales);

  test('the first shipped language in the user order wins, by language code', () {
    expect(pick(const [Locale('de'), Locale('tr', 'TR'), Locale('en')]), const Locale('tr'));
    expect(pick(const [Locale('ar', 'EG')]), const Locale('ar'));
    expect(pick(const [Locale('en', 'US'), Locale('ar')]), const Locale('en'));
  });

  test('no shipped language, or no list at all, is English', () {
    expect(pick(const [Locale('de'), Locale('fr')]), const Locale('en'));
    expect(pick(const []), const Locale('en'));
    expect(pick(null), const Locale('en'));
  });

  test('only Arabic is right to left', () {
    expect([for (final l in supportedLocales) isRightToLeft(l)], [false, false, true]);
  });
}
