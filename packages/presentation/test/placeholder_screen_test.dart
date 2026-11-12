import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('the presentation layer depends on the domain layer', () {
    expect(presentationDependsOn, domainLayer);
  });

  testWidgets('the placeholder shows the app name as a header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlaceholderScreen()));

    expect(find.text('Atmos'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Atmos')),
      matchesSemantics(label: 'Atmos', isHeader: true),
    );
  });
}
