import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';

/// The composition root (ADR-0004): the one place that creates the real implementations from
/// `atmos_data` and hands them to the view models. From step 06 it builds the overrides for
/// Riverpod's root `ProviderScope`. In step 02 there is nothing to wire yet.
final class AppDependencies {
  const AppDependencies();

  /// Proves that the composition root, and only the composition root, sees every layer.
  List<String> get layers => const [domainLayer, dataLayer, presentationLayer];
}
