import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:material_ui/material_ui.dart';

import 'composition.dart';

/// The four screens and the only ways between them (ADR-0010): one typed function per route,
/// so a wrong route or a missing argument is a compile error, and there are no route names.
/// No route takes parameters: the selected place is shared state, so Home always shows what
/// Cities picked.
abstract final class AppRoutes {
  static Future<void> openCities(BuildContext context) =>
      _push(context, (context) => CitiesScreen(onPlaceSelected: () => Navigator.of(context).pop()));

  static Future<void> openSettings(BuildContext context) =>
      _push(context, (context) => SettingsScreen(onOpenAbout: () => openAbout(context)));

  static Future<void> openAbout(BuildContext context) =>
      _push(context, (context) => const AboutScreen(version: appVersion));

  static Future<void> _push(BuildContext context, WidgetBuilder builder) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
}

/// The first screen, with the navigation it can start.
class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) => HomeScreen(
    onOpenCities: () => AppRoutes.openCities(context),
    onOpenSettings: () => AppRoutes.openSettings(context),
  );
}
