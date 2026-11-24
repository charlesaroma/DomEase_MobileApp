// ─── Bundled Legal ────────────────────────────────────────────────
// The copy of each legal document that ships in the app (assets/legal/), in
// the same JSON the API serves at /legal/:id. The website reads the same files.
import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadBundledLegal(String id) async =>
    jsonDecode(await rootBundle.loadString('assets/legal/$id.json')) as Map<String, dynamic>;
