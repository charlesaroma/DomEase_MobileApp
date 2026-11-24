// ─── Entry: development ─────────────────────────────────────────────
// Demo data on the phone, no server: `flutter run -t lib/main_development.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/app.dart';
import 'package:domease/config/environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [flavorProvider.overrideWithValue(Flavor.development)],
    child: const DomEaseApp(),
  ));
}
