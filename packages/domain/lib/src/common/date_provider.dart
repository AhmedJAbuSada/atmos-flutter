/// Where "now" comes from. Injected instead of calling `DateTime.now()`, so tests can control
/// time ("data fetched exactly 30 minutes ago is stale") without waiting.
abstract interface class DateProvider {
  /// The current instant, in UTC.
  DateTime now();
}

/// The real clock. The only place in the app that reads it.
final class SystemDateProvider implements DateProvider {
  const SystemDateProvider();

  @override
  DateTime now() => DateTime.now().toUtc();
}
