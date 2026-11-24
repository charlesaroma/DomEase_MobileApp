// ─── Demo Assets ──────────────────────────────────────────────────
// assets/demo/ holds the exact JSON the API sends (docs/04-api-contract.md),
// shared with the admin dashboard's demo mode. The `_local` repositories read it.
import 'dart:convert';

import 'package:flutter/services.dart';

Future<Object?> loadDemoJson(String name) async => jsonDecode(await rootBundle.loadString('assets/demo/$name.json'));

Future<List<Map<String, dynamic>>> loadDemoList(String name) async =>
    [for (final e in await loadDemoJson(name) as List) e as Map<String, dynamic>];

Future<Map<String, dynamic>> loadDemoMap(String name) async => await loadDemoJson(name) as Map<String, dynamic>;
