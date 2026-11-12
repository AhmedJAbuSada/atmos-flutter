import 'package:atmos_domain/atmos_domain.dart';

import '../remote/json_reading.dart';

/// How a saved city is written to storage. Our own format, separate from the API's DTO, so an
/// API change never breaks the saved list.
Map<String, Object?> cityToJson(City city) => {
  'id': city.id,
  'name': city.name,
  'region': city.region,
  'country': city.country,
  'countryCode': city.countryCode,
  'latitude': city.coordinates.latitude,
  'longitude': city.coordinates.longitude,
};

/// The saved cities in [json]; an entry that cannot be read is dropped, and anything that is
/// not a list is an empty list.
List<City> citiesFromJson(Object? json) => [
  for (final item in readList(json, readObject) ?? const <Map<String, Object?>?>[])
    ?_cityFromJson(item),
];

City? _cityFromJson(Map<String, Object?>? json) {
  if (json == null) return null;
  final (id, name) = (readInt(json['id']), readString(json['name']));
  final (latitude, longitude) = (readDouble(json['latitude']), readDouble(json['longitude']));
  if (id == null || name == null || latitude == null || longitude == null) return null;
  final coordinates = Coordinates.validated(latitude, longitude);
  if (coordinates == null) return null;
  return City(
    id: id,
    name: name,
    region: readString(json['region']),
    country: readString(json['country']),
    countryCode: readString(json['countryCode']),
    coordinates: coordinates,
  );
}
