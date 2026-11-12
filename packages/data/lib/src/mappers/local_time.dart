/// Open-Meteo sends local times without an offset: `"2026-11-11T10:15"` means 10:15 *at the
/// place*. Dart's core libraries cannot convert a time in a named zone, so we use the offset the
/// API reports with the response (`utc_offset_seconds`, ADR-0015).
library;

final _localTime = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}))?$');

/// Reads `"2026-11-11T10:15"` or `"2026-11-11"` (the start of that day) as a time at a place
/// that is [offset] ahead of UTC, and returns the UTC instant.
///
/// Returns `null` for text in any other format and for impossible dates (`2026-02-30`), which
/// `DateTime.utc` would otherwise silently roll over to March.
DateTime? parseLocalTime(String? text, Duration offset) {
  final match = text == null ? null : _localTime.firstMatch(text);
  if (match == null) return null;
  int part(int group) => int.parse(match.group(group) ?? '0');
  final (year, month, day, hour, minute) = (part(1), part(2), part(3), part(4), part(5));
  final wallClock = DateTime.utc(year, month, day, hour, minute);
  final exact =
      wallClock.year == year &&
      wallClock.month == month &&
      wallClock.day == day &&
      wallClock.hour == hour &&
      wallClock.minute == minute;
  return exact ? wallClock.subtract(offset) : null;
}
