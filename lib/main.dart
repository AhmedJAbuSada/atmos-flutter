import 'package:atmos/app/atmos_app.dart';
import 'package:atmos/app/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // The plugins (storage, location) need the engine before the dependencies are created.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(overrides: AppDependencies().overrides, child: const AtmosApp()));
}
