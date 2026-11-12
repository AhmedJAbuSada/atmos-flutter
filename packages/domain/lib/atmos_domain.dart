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

/// The name of this layer. The placeholders of the other layers use it to prove the allowed
/// direction of their imports until they have real code (presentation: step 05).
const String domainLayer = 'domain';
