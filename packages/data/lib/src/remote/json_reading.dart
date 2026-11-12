/// Small, safe readers for decoded JSON (`Object?`). Each returns `null` instead of throwing
/// when the value has another type, so a surprising response cannot crash the app; the mappers
/// decide what is truly required.
library;

double? readDouble(Object? value) => switch (value) {
  final num number when number.isFinite => number.toDouble(),
  _ => null,
};

int? readInt(Object? value) => switch (value) {
  final int number => number,
  final double number when number.isFinite && number == number.roundToDouble() => number.toInt(),
  _ => null,
};

String? readString(Object? value) => value is String ? value : null;

/// A list whose items are read with [item]; an item of the wrong type becomes `null`, so the
/// indexes of parallel arrays stay aligned.
List<T?>? readList<T>(Object? value, T? Function(Object?) item) =>
    value is List<Object?> ? [for (final element in value) item(element)] : null;

/// The JSON object, or `null`.
Map<String, Object?>? readObject(Object? value) => value is Map<String, Object?> ? value : null;
