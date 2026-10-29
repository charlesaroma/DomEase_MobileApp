// ─── App ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:domease/routing/router.dart';
import 'package:domease/ui/core/themes/theme.dart';

/// The root widget, shared by every entry point (main*.dart).
class DomEaseApp extends StatelessWidget {
  const DomEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DomEase',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      darkTheme: buildTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
