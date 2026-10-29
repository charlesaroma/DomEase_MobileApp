// ─── Splash ───────────────────────────────────────────────────────
// Clay 900, the same colour as the native launch screen, so the hand over is
// seamless. The stacked logo fades up, then the app opens on Today.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _arrive = AnimationController(vsync: this, duration: AppDurations.splash)..forward();

  @override
  void initState() {
    super.initState();
    _arrive.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) context.go(Routes.today);
    });
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
