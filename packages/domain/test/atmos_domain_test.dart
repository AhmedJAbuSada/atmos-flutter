import 'package:atmos_domain/atmos_domain.dart';
import 'package:test/test.dart';

void main() {
  test('the domain runs with dart test, without Flutter', () {
    expect(domainLayer, 'domain');
  });
}
