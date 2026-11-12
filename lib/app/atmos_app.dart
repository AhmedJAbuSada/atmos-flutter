import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:material_ui/material_ui.dart';

/// The app's root widget. Theme, localization, navigation and Riverpod's `ProviderScope`
/// arrive in steps 05 and 06.
class AtmosApp extends StatelessWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Atmos', home: PlaceholderScreen());
  }
}
