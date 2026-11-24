// ─── Splash ───────────────────────────────────────────────────────
// Clay 900, the same colour as the native launch screen, so the hand over is
// seamless. The stacked logo fades up while the account and household load,
// then the app opens on Welcome, Setup or Today.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _arrive = AnimationController(vsync: this, duration: AppDurations.splash)..forward();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Wait for both the logo's moment and the lookup, whichever is longer.
    final moment = Future<void>.delayed(AppDurations.splash);
    final next = await routeOnLaunch(ref);
    await moment;
    if (!mounted) return;
    context.go(next);
  }

  @override
  void dispose() {
    _arrive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _arrive, curve: const Interval(0, 0.55, curve: AppCurves.standard));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.clay900,
        body: Center(
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(fade),
              child: const DomEaseLogo(tone: LogoTone.reversed, width: 220),
            ),
          ),
        ),
      ),
    );
  }
}
