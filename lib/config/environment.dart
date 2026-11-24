// ─── Environment ──────────────────────────────────────────────────
// Which backend the app talks to. One entry point per flavor picks it:
//   main_development.dart  demo data on the phone (no server needed)
//   main_staging.dart      the staging API
//   main.dart              production (what the stores ship)
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Flavor {
  development(apiBaseUrl: '', useDemoData: true),
  staging(apiBaseUrl: 'https://staging-api.domease.app', useDemoData: false),
  production(apiBaseUrl: 'https://api.domease.app', useDemoData: false);

  const Flavor({required this.apiBaseUrl, required this.useDemoData});

  final String apiBaseUrl;

  /// Repositories read assets/demo/ instead of the API. Never in production.
  final bool useDemoData;

  String get apiRoot => '$apiBaseUrl/api/v1';
}

/// The running flavor. Defaults to production, so forgetting to choose can
/// never ship demo data; the development and staging entry points override it.
final flavorProvider = Provider<Flavor>((ref) => Flavor.production);
