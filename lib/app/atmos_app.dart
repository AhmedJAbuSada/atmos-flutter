import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'routes.dart';

/// The app's root widget: the theme the user chose, the languages the OS can choose from, and
/// Home. It needs a `ProviderScope` above it with the dependencies (`AppDependencies.overrides`
/// in the app, fakes in the journey tests).
class AtmosApp extends ConsumerWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'Atmos',
    theme: atmosTheme(AtmosColors.light),
    darkTheme: atmosTheme(AtmosColors.dark),
    themeMode: themeModeFor(ref.watch(settingsViewModelProvider).theme),
    // No `locale:`: the operating system picks one of these (ADR-0005).
    supportedLocales: supportedLocales,
    localeListResolutionCallback: resolveAppLocale,
    localizationsDelegates: localizationsDelegates,
    home: const HomeRoute(),
  );
}
