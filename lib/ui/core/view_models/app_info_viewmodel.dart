// ─── App Info ─────────────────────────────────────────────────────
// The installed version and build, for About and for problem reports.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } catch (_) {
    // Tests and unusual platforms have no package info; never block a screen on it.
    return '1.0.0';
  }
});
