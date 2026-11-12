/// Talks to the outside world (Open-Meteo, storage, location) and implements the repository
/// interfaces of `atmos_domain`.
///
/// This file is the layer's public surface: only the composition root (the app) imports it,
/// and it exports **no DTO and no concrete repository**. It exports the [DataModule], the real
/// store and location platform the app passes to it, and the interfaces of those inputs.
library;

export 'src/data_module.dart' show DataModule;
export 'src/local/key_value_store.dart' show InMemoryKeyValueStore, KeyValueStore;
export 'src/local/shared_preferences_store.dart' show SharedPreferencesStore;
export 'src/location/geolocator_location_platform.dart' show GeolocatorLocationPlatform;
export 'src/location/geolocator_permissions.dart'
    show GeolocatorPermissions, LocationPermissionAnswer;
export 'src/location/location_repository.dart' show LocationPermissionStatus, LocationPlatform;
export 'src/remote/http_client.dart' show HttpClient, HttpResponse;
