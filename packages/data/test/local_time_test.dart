import 'package:atmos_data/src/mappers/local_time.dart';
import 'package:flutter_test/flutter_test.dart';

const istanbulOffset = Duration(hours: 3);

void main() {
  group('parseLocalTime', () {
    test('reads a local time at the place: 10:15 in Istanbul is 07:15 UTC', () {
      expect(parseLocalTime('2026-11-11T10:15', istanbulOffset), DateTime.utc(2026, 11, 11, 7, 15));
    });

    test('a date without a time is the start of that day at the place', () {
      expect(parseLocalTime('2026-11-11', istanbulOffset), DateTime.utc(2026, 11, 10, 21));
    });

    test('a negative offset works too: 12:00 in New York in January is 17:00 UTC', () {
      expect(
        parseLocalTime('2026-01-15T12:00', const Duration(hours: -5)),
        DateTime.utc(2026, 1, 15, 17),
      );
    });

    for (final text in [null, '', '11/11/2026 10:15', '2026-11-11T10:15:00Z', '2026-11-11T10']) {
      test('given text in another format ("$text"), then returns null', () {
        expect(parseLocalTime(text, Duration.zero), isNull);
      });
    }

    for (final text in ['2026-02-30', '2026-13-01', '2026-11-11T24:00', '2026-11-11T10:60']) {
      test(
        'given an impossible date or time ("$text"), then returns null, never a rolled-over date',
        () {
          expect(parseLocalTime(text, Duration.zero), isNull);
        },
      );
    }

    /// ADR-0015: one offset for the whole response. This test pins down the known limitation so
    /// a change to it is deliberate.
    test('known limitation: a time after a clock change uses the offset of the request', () {
      // A request in New York in winter (UTC-5) that reaches past the spring change (8 March).
      const winter = Duration(hours: -5);
      final afterChange = parseLocalTime('2026-03-09T12:00', winter);
      // The true instant is 16:00 UTC (summer time, UTC-4); we compute 17:00 UTC: 1 hour off.
      expect(afterChange, DateTime.utc(2026, 3, 9, 17));
      // The local time shown (instant + the same offset) is still the API's own 12:00.
      expect(afterChange?.add(winter).hour, 12);
    });
  });
}
