import 'dart:async';

/// Holds a current value and tells listeners about every change: the Dart equivalent of
/// Kotlin's `StateFlow`, the iOS `ValueStream` and the React Native `ValueStore`.
///
/// [watch] returns a stream that starts with the current value, then emits each change. Setting
/// an equal value (`==`) emits nothing.
final class ValueStore<T> {
  ValueStore(this._value);

  T _value;
  final _changes = StreamController<T>.broadcast();

  T get value => _value;

  set value(T newValue) {
    if (newValue == _value) return;
    _value = newValue;
    _changes.add(newValue);
  }

  /// The current value at once, then every change, until the subscription is cancelled.
  Stream<T> watch() => Stream.multi((listener) {
    listener.add(_value);
    final subscription = _changes.stream.listen(listener.add, onDone: listener.close);
    listener.onCancel = subscription.cancel;
  });

  /// Ends every [watch] stream. Call it when the owner of the store is disposed.
  Future<void> close() => _changes.close();
}
