import 'package:material_ui/material_ui.dart';

/// A placeholder screen for step 02, proving that the app, the packages and the tooling work
/// together. The real screens arrive in step 05. "Atmos" is the brand name, not a translated
/// text.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          header: true,
          child: Text('Atmos', style: Theme.of(context).textTheme.displaySmall),
        ),
      ),
    );
  }
}
