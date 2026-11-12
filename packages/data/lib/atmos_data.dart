/// Talks to the outside world (Open-Meteo, storage, location) and implements the repository
/// interfaces declared in `atmos_domain` (step 04).
library;

import 'package:atmos_domain/atmos_domain.dart';

/// The name of this layer. A placeholder until step 04.
const String dataLayer = 'data';

/// Proves the allowed direction: data may use the domain.
const String dataDependsOn = domainLayer;
