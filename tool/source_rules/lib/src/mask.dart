/// Returns [source] with comments and the text inside string literals replaced by spaces.
///
/// Line breaks and the length of every line are kept, so a match in the result has the same
/// line and column as in [source]. Code inside string interpolation (`'${a.b()}'`) stays
/// visible, because it is code. The rules then look at code only: a rule's words inside a
/// comment or a message are not a violation.
String maskCommentsAndStrings(String source) {
  final out = StringBuffer();
  // Each frame is the code or string we are inside. Code frames count `{` so the `}` that
  // ends an interpolation can be told apart from the end of a block.
  final stack = <_Frame>[_Code(interpolation: false)];
  var i = 0;

  void keep(int count) {
    out.write(source.substring(i, i + count));
    i += count;
  }

  void blank(int count) {
    for (var k = 0; k < count; k++) {
      out.write(source[i + k] == '\n' ? '\n' : ' ');
    }
    i += count;
  }

  bool startsWith(String s) => source.startsWith(s, i);

  while (i < source.length) {
    switch (stack.last) {
      case final _Code code:
        if (startsWith('//')) {
          final end = source.indexOf('\n', i);
          blank((end == -1 ? source.length : end) - i);
        } else if (startsWith('/*')) {
          final end = source.indexOf('*/', i + 2);
          blank((end == -1 ? source.length : end + 2) - i);
        } else if (_quoteAt(source, i) case final quote?) {
          final raw = i > 0 && source[i - 1] == 'r';
          stack.add(_String(quote, raw: raw));
          keep(quote.length);
        } else if (source[i] == '{') {
          code.depth++;
          keep(1);
        } else if (source[i] == '}' && code.depth == 0 && code.interpolation) {
          stack.removeLast();
          blank(1);
        } else {
          if (source[i] == '}') code.depth--;
          keep(1);
        }
      case final _String string:
        if (!string.raw && source[i] == '\\') {
          blank(i + 1 < source.length ? 2 : 1);
        } else if (startsWith(string.quote)) {
          stack.removeLast();
          keep(string.quote.length);
        } else if (!string.raw && startsWith(r'${')) {
          stack.add(_Code(interpolation: true));
          blank(2);
        } else {
          blank(1);
        }
    }
  }
  return out.toString();
}

String? _quoteAt(String source, int i) {
  for (final quote in const ["'''", '"""', "'", '"']) {
    if (source.startsWith(quote, i)) return quote;
  }
  return null;
}

sealed class _Frame {}

final class _Code extends _Frame {
  _Code({required this.interpolation});

  final bool interpolation;
  int depth = 0;
}

final class _String extends _Frame {
  _String(this.quote, {required this.raw});

  final String quote;
  final bool raw;
}
