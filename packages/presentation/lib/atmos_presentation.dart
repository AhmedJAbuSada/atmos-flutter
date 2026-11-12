/// The screens of Atmos: props-only views with sealed states (step 05), and from step 06 their
/// view models. It knows the domain, never the data layer (ADR-0001).
library;

import 'package:atmos_domain/atmos_domain.dart';

export 'src/cities/cities_state.dart';
export 'src/cities/cities_view.dart';
export 'src/error_message.dart';
export 'src/formatting/weather_formatter.dart';
export 'src/home/home_state.dart';
export 'src/home/home_view.dart';
export 'src/l10n/app_language.dart';
export 'src/l10n/app_localizations.dart';
export 'src/placeholder_screen.dart';
export 'src/settings/about_view.dart';
export 'src/settings/settings_view.dart';
export 'src/theme/atmos_colors.dart';
export 'src/weather/condition_ui.dart';

/// The name of this layer. A placeholder until the views replace it (step 05).
const String presentationLayer = 'presentation';

/// Proves the allowed direction: presentation may use the domain.
const String presentationDependsOn = domainLayer;
