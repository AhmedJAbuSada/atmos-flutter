import 'package:atmos_domain/atmos_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('an exhaustive switch reaches the value or the error', () {
      String describe(Result<int> result) => switch (result) {
        Ok(:final value) => 'value $value',
        Err(:final error) => 'error $error',
      };
      expect(describe(const Ok(42)), 'value 42');
      expect(describe(const Err(RequestTimeout())), 'error RequestTimeout');
    });

    test('results compare by value', () {
      expect(const Ok(1), const Ok(1));
      expect(const Err<int>(ServerError(503)), const Err<int>(ServerError(503)));
      expect(const Err<int>(ServerError(503)), isNot(const Err<int>(ServerError(500))));
      expect(const Err<int>(NoConnection()), isNot(const Err<int>(RequestTimeout())));
    });
  });

  group('ValueStore', () {
    test('gives a new listener the current value at once', () async {
      final store = ValueStore(1)..value = 2;
      expect(await store.watch().first, 2);
    });

    test('tells every listener about each change, but not about an equal value', () async {
      final store = ValueStore('a');
      final first = <String>[];
      final second = <String>[];
      store.watch().listen(first.add);
      store.watch().listen(second.add);
      await pumpEventQueue();

      store
        ..value = 'a'
        ..value = 'b';
      await pumpEventQueue();

      expect(first, ['a', 'b']);
      expect(second, ['a', 'b']);
    });

    test('stops telling a listener after it cancels', () async {
      final store = ValueStore(0);
      final seen = <int>[];
      final subscription = store.watch().listen(seen.add);
      await pumpEventQueue();
      await subscription.cancel();

      store.value = 1;
      await pumpEventQueue();

      expect(seen, [0]);
    });

    test('closing the store ends the streams', () async {
      final store = ValueStore(0);
      final done = store.watch().toList();
      await pumpEventQueue();
      await store.close();
      expect(await done, [0]);
    });
  });

  test('the system clock gives UTC', () {
    expect(const SystemDateProvider().now().isUtc, isTrue);
  });
}
