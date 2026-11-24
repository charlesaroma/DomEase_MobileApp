// ─── Entry: staging ─────────────────────────────────────────────────
// The staging API: `flutter run -t lib/main_staging.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/app.dart';
import 'package:domease/config/environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [flavorProvider.overrideWithValue(Flavor.staging)],
    child: const DomEaseApp(),
  ));
}
