import 'package:atmos/app/atmos_app.dart';
import 'package:atmos/app/composition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app starts on the placeholder screen', (tester) async {
    await tester.pumpWidget(const AtmosApp());

    expect(find.text('Atmos'), findsOneWidget);
  });

  test('the composition root sees every layer', () {
    expect(const AppDependencies().layers, ['domain', 'data', 'presentation']);
  });
}
