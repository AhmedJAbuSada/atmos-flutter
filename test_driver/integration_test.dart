import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Runs on the computer that drives the device (`flutter drive`). It receives the screenshots the
/// journey takes and writes them to `$SCREENSHOT_DIR` (`docs/screenshots/android-LANGUAGE`).
Future<void> main() => integrationDriver(
  onScreenshot: (name, image, [args]) async {
    final folder = Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots';
    final file = File('$folder/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(image);
    return true;
  },
);
