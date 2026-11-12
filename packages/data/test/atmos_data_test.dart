import 'package:atmos_data/atmos_data.dart';
import 'package:atmos_domain/atmos_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the data layer depends on the domain layer', () {
    expect(dataDependsOn, domainLayer);
  });
}
