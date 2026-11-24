// ─── Code Size Test ───────────────────────────────────────────────
// Short files are read; long ones are skimmed (docs/03-flutter-dos-and-donts.md).
// Generated brand paths are data, not code, and are exempt.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no Dart file in lib/ is over 300 lines', () {
    final long = [
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
        if (f.path.endsWith('.dart') && !f.path.endsWith('brand_paths.dart'))
          if (f.readAsLinesSync().length > 300) '${f.path}: ${f.readAsLinesSync().length} lines',
    ];
    expect(long, isEmpty);
  });
}
