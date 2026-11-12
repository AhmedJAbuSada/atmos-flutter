import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';

/// The languages Atmos ships (NF-02). The operating system picks one of them for the app
/// (Android 13+ and iOS per-app language, or the device language); there is no in-app picker,
/// so there is one source of truth (ADR-0005). Any other language falls back to English, the
/// first entry.
const supportedLocales = [Locale('en'), Locale('tr'), Locale('ar')];

/// Our strings, plus Material's own (buttons, tooltips, the back button) and the text
/// direction, from `material_ui`.
///
/// Not `AppLocalizations.localizationsDelegates`: in Flutter 3.50 that generated list still
/// names `flutter_localizations`' deprecated Material delegate (ADR-0016).
const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// Picks the app language from the OS list: the **first** language in the user's order that
/// the app ships, matched by language code (`tr_TR` is Turkish, `ar_EG` is Arabic); English
/// when none matches. This is how the Android, iOS and React Native apps choose.
///
/// Flutter's default does not always do that: for `[de, tr_TR, en]` it returns English,
/// because an exact match (`en`) lower in the list beats a language-only match (`tr_TR`). The
/// user ranked Turkish first, so we pass this function as `localeListResolutionCallback`.
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) return candidate;
    }
  }
  return supported.first;
}

/// Arabic is the only right-to-left language the app ships.
bool isRightToLeft(Locale locale) => locale.languageCode == 'ar';
