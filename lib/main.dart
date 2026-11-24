// ─── Entry: production ──────────────────────────────────────────────
// The real API. What the stores ship.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DomEaseApp()));
}
