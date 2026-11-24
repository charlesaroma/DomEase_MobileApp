// ─── App ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/router.dart';
import 'package:domease/ui/core/themes/theme.dart';
import 'package:domease/ui/core/view_models/preferences_viewmodel.dart';

/// The root widget, shared by every entry point (main*.dart).
class DomEaseApp extends ConsumerStatefulWidget {
  const DomEaseApp({super.key});

  @override
  ConsumerState<DomEaseApp> createState() => _DomEaseAppState();
}

class _DomEaseAppState extends ConsumerState<DomEaseApp> {
  // One router for the life of the app, so a rebuild never resets navigation.
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'DomEase',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        darkTheme: buildTheme(brightness: Brightness.dark),
        // Match my phone, Light or Dark, from Settings.
        themeMode: ref.watch(themeModeProvider),
        routerConfig: _router,
      );
}
