// ─── Splash ───────────────────────────────────────────────────────
// Clay 900, the same colour as the native launch screen, so the hand over is
// seamless. The logo draws itself (the house, the plant, the tulip, then the
// name) while the account and household load; the app opens on Welcome, Setup
// or Today once both are done. Reduced motion shows the finished logo.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/animated_logo.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _drawn = Completer<void>();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Wait for both the drawing and the lookup, whichever is longer; never
    // more than a few seconds, whatever happens to the animation.
    final next = await routeOnLaunch(ref);
    await _drawn.future.timeout(AppDurations.splash, onTimeout: () {});
    if (!mounted) return;
    context.go(next);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.clay900,
        body: Center(
          child: AnimatedDomEaseLogo(
            tone: LogoTone.reversed,
            width: 220,
            speed: 1.3,
            onDrawn: () {
              if (!_drawn.isCompleted) _drawn.complete();
            },
          ),
        ),
      ),
    );
  }
}
