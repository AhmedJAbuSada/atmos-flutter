import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:material_ui/material_ui.dart';

/// The app's root widget: themes, the languages the OS can choose from, and Home. Data, view
/// models and navigation arrive in step 06; until then Home asks where the user is.
class AtmosApp extends StatelessWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Atmos',
    theme: atmosTheme(AtmosColors.light),
    darkTheme: atmosTheme(AtmosColors.dark),
    // No `locale:`: the operating system picks one of these (ADR-0005).
    supportedLocales: supportedLocales,
    localeListResolutionCallback: resolveAppLocale,
    localizationsDelegates: localizationsDelegates,
    home: HomeView(state: const HomeNeedsLocation(), onEvent: (_) {}),
  );
}
