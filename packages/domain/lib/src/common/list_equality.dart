/// Element-by-element equality, for the `==` of entities that hold lists. The domain has no
/// dependencies, so it does not use `package:collection` for this one function.
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
