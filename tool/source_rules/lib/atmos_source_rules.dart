/// Checks that no built-in lint covers (ADR-0012): the allowed imports per layer, locale-safe
/// casing, and `start`/`end` instead of `left`/`right`; and the coverage gate (ADR-0014).
library;

export 'src/check.dart';
export 'src/coverage.dart';
export 'src/mask.dart';
