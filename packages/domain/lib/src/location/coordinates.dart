/// A point on Earth in decimal degrees.
///
/// The constructor is private: the only way to get one is [Coordinates.validated], which
/// refuses impossible values. So the rest of the app never has to check them (the API answers
/// 400 for latitude 999, see `docs/api/samples/forecast_error.json`). The Dart version of the
/// "branded type" in the React Native app and the failable `init?` in the iOS app.
final class Coordinates {
  const Coordinates._(this.latitude, this.longitude);

  /// The coordinates, or `null` when they are not on Earth (or not numbers at all).
  static Coordinates? validated(double latitude, double longitude) {
    final valid = latitude.abs() <= 90 && longitude.abs() <= 180;
    return valid ? Coordinates._(latitude, longitude) : null;
  }

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}
