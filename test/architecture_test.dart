// ─── Architecture Test ────────────────────────────────────────────
// Enforces docs/02-architecture.md. Reads every file in lib/ and checks its
// imports against the folder it lives in. Dependencies point one way:
//
//   ui widgets → view models → repositories → services → outside world
//                    ↘ domain (models, use cases) ↙
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const app = 'package:domease/';

class Source {
  Source(this.path, this.imports);
  final String path;
  final List<String> imports;
}

List<Source> readLib() => [
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
        if (f.path.endsWith('.dart'))
          Source(f.path.substring('lib/'.length), [
            for (final m in RegExp(r"^import\s+'([^']+)'", multiLine: true).allMatches(f.readAsStringSync()))
              m.group(1)!.startsWith(app) ? m.group(1)!.substring(app.length) : m.group(1)!,
          ]),
    ];

void main() {
  final lib = readLib();
  List<String> offenders(String dir, bool Function(String import) bad) => [
        for (final s in lib.where((s) => s.path.startsWith(dir)))
          for (final i in s.imports)
            if (bad(i)) '${s.path} → $i',
      ];

  test('domain is pure Dart: no Flutter, no data, no ui', () {
    expect(offenders('domain/', (i) => i.startsWith('package:flutter') || i.startsWith('data/') || i.startsWith('ui/')), isEmpty);
  });

  test('data never reaches into ui', () {
    expect(offenders('data/', (i) => i.startsWith('ui/')), isEmpty);
  });

  test('widgets never touch data/ or the composition root', () {
    final widgetFiles = lib.where((s) => s.path.startsWith('ui/') && (s.path.contains('/widgets/') || s.path.startsWith('ui/core/ui/')));
    final bad = [
      for (final s in widgetFiles)
        for (final i in s.imports)
          if (i.startsWith('data/') || i == 'config/dependencies.dart') '${s.path} → $i',
    ];
    expect(bad, isEmpty);
  });

  test('only config/dependencies.dart picks a _local or _remote repository', () {
    final bad = [
      for (final s in lib.where((s) => s.path != 'config/dependencies.dart'))
        for (final i in s.imports)
          if (RegExp(r'^data/repositories/.+_(local|remote)\.dart$').hasMatch(i)) '${s.path} → $i',
    ];
    expect(bad, isEmpty);
  });

  test('screens do not import each other\'s private parts', () {
    String? screen(String p) => RegExp(r'^ui/([^/]+)/').firstMatch(p)?.group(1);
    const shared = {'core'};
    final bad = [
      for (final s in lib.where((s) => s.path.startsWith('ui/') && s.path.contains('/widgets/')))
        for (final i in s.imports)
          if (i.startsWith('ui/') && i.contains('/widgets/') && !shared.contains(screen(i)) && screen(i) != screen(s.path)) '${s.path} → $i',
    ];
    expect(bad, isEmpty);
  });
}
