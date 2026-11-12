/// The business core of Atmos: entities, repository interfaces and use cases.
///
/// **Rule:** pure Dart only. No Flutter, no `dart:ui`, no `dart:io`, no package at all, so
/// the rules run with `dart test` on the plain Dart VM, in milliseconds (ADR-0001). Other
/// packages import this library, never the other way round.
library;

export 'src/common/date_provider.dart';
export 'src/common/domain_error.dart';
export 'src/common/result.dart';
export 'src/common/value_store.dart';
export 'src/location/city.dart';
export 'src/location/city_use_cases.dart';
export 'src/location/coordinates.dart';
export 'src/location/repositories.dart';
export 'src/settings/units.dart';
export 'src/settings/user_settings.dart';
export 'src/weather/forecast.dart';
export 'src/weather/get_forecast.dart';
export 'src/weather/weather_condition.dart';
