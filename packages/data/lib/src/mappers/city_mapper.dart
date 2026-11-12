import 'package:atmos_domain/atmos_domain.dart';

import '../remote/dtos.dart';

/// Trimmed text, or `null` when there is none: a blank country is no country.
String? _text(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

/// A result without an id, a name or valid coordinates cannot be shown or saved: dropped.
City? mapCity(CityDto dto) {
  final (id, name, latitude, longitude) = (dto.id, _text(dto.name), dto.latitude, dto.longitude);
  if (id == null || name == null || latitude == null || longitude == null) return null;
  final coordinates = Coordinates.validated(latitude, longitude);
  if (coordinates == null) return null;
  return City(
    id: id,
    name: name,
    region: _text(dto.admin1),
    country: _text(dto.country),
    countryCode: _text(dto.countryCode),
    coordinates: coordinates,
  );
}

List<City> mapCities(List<CityDto> dtos) => [for (final dto in dtos) ?mapCity(dto)];
