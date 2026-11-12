import 'package:atmos_domain/atmos_domain.dart';

/// Everything the Home screen can show (US-01, US-02, US-03, US-07, US-09). The view is a pure
/// function of this value, so every state is rendered in tests without a view model.
sealed class HomeState {
  const HomeState();
}

/// First load, nothing cached: the skeleton (US-09).
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// No location permission and no saved city: offer both ways forward (F-02).
final class HomeNeedsLocation extends HomeState {
  const HomeNeedsLocation();
}

/// Nothing to show, and the load failed. A `Cancelled` error is shown as the skeleton.
final class HomeFailed extends HomeState {
  const HomeFailed(this.error);

  final DomainError error;
}

final class HomeContent extends HomeState {
  const HomeContent({
    required this.forecast,
    required this.settings,
    this.placeName,
    this.outdatedBy,
    this.refreshing = false,
  });

  /// The city name, or `null` for the current location.
  final String? placeName;
  final Forecast forecast;
  final UserSettings settings;

  /// Set when a refresh failed and the data is old (F-08): its age.
  final Duration? outdatedBy;

  /// A pull to refresh is running.
  final bool refreshing;
}

/// What the user can do on Home. The view reports; whoever owns the screen decides (step 06).
sealed class HomeEvent {
  const HomeEvent();
}

final class HomeRefresh extends HomeEvent {
  const HomeRefresh();
}

final class HomeRetry extends HomeEvent {
  const HomeRetry();
}

final class HomeRequestLocation extends HomeEvent {
  const HomeRequestLocation();
}

final class HomeOpenCities extends HomeEvent {
  const HomeOpenCities();
}

final class HomeOpenSettings extends HomeEvent {
  const HomeOpenSettings();
}
