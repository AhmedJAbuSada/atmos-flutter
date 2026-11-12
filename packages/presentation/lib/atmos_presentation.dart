/// The screens and view models of Atmos (steps 05 and 06). It knows the domain, never the
/// data layer (ADR-0001).
library;

import 'package:atmos_domain/atmos_domain.dart';

export 'src/placeholder_screen.dart';

/// The name of this layer. A placeholder until step 05.
const String presentationLayer = 'presentation';

/// Proves the allowed direction: presentation may use the domain.
const String presentationDependsOn = domainLayer;
