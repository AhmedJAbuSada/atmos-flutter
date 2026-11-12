import 'package:atmos_domain/atmos_domain.dart';

/// `forecast:41.01,28.97`: two decimals (about 1 km), so tiny GPS changes reuse the cache.
/// `toStringAsFixed` ignores the phone's language, so a Turkish phone never writes `41,01`.
String cacheKey(Coordinates coordinates) =>
    'forecast:${coordinates.latitude.toStringAsFixed(2)},'
    '${coordinates.longitude.toStringAsFixed(2)}';
