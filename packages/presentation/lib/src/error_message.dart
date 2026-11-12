import 'package:atmos_domain/atmos_domain.dart';

import 'l10n/app_localizations.dart';

/// The message for each error. `Cancelled` has **none**: the user left, or a newer request
/// replaced this one, so there is nothing to tell them (ADR-0006). The exhaustive switch makes a
/// new error a compile error here until it has a message.
String? errorMessage(DomainError error, AppLocalizations l10n) => switch (error) {
  NoConnection() => l10n.errorNoConnection,
  RequestTimeout() => l10n.errorTimeout,
  ServerError() => l10n.errorServer,
  NotFound() => l10n.errorNotFound,
  LocationPermissionDenied() => l10n.errorLocationDenied,
  LocationUnavailable() => l10n.errorLocationUnavailable,
  UnknownError() => l10n.errorUnknown,
  Cancelled() => null,
};
