import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The ARB files, read as JSON: what translators and the AI agent edit.
Map<String, Object?> arb(String language) =>
    jsonDecode(File('lib/src/l10n/arb/app_$language.arb').readAsStringSync())
        as Map<String, Object?>;

Iterable<String> messageKeys(Map<String, Object?> file) =>
    file.keys.where((k) => !k.startsWith('@'));

/// `{name}` and `{count, plural, …}` placeholders, without the text inside plural forms.
Set<String> placeholders(String message) =>
    RegExp(r'\{(\w+)(?=[,}])').allMatches(message).map((m) => m.group(1) ?? '').toSet();

void main() {
  final english = arb('en');

  for (final language in ['tr', 'ar']) {
    group(language, () {
      final translated = arb(language);

      test('has exactly the English keys', () {
        expect(messageKeys(translated).toSet(), messageKeys(english).toSet());
      });

      test('uses the same placeholders as English in every message', () {
        for (final key in messageKeys(english)) {
          expect(placeholders('${translated[key]}'), placeholders('${english[key]}'), reason: key);
        }
      });

      test('is marked as AI-written and not reviewed by a native speaker', () {
        expect(translated['@@x-translation'], contains('not reviewed by a native speaker'));
      });
    });
  }

  test('Arabic plurals have all six forms', () {
    final arabic = arb('ar');
    final plurals = messageKeys(arabic).where((k) => '${arabic[k]}'.contains(', plural,'));
    expect(plurals, isNotEmpty);
    for (final key in plurals) {
      for (final form in ['zero', 'one', 'two', 'few', 'many', 'other']) {
        expect('${arabic[key]}', contains(' $form{'), reason: '$key: $form');
      }
    }
  });

  test('every language names itself, not another language', () {
    expect(
      [
        for (final l in ['en', 'tr', 'ar']) arb(l)['languageName'],
      ],
      ['English', 'Türkçe', 'العربية'],
    );
  });
}
