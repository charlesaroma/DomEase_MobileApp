// ─── Welcome ──────────────────────────────────────────────────────
// The first thing a new phone sees after the splash: what DomEase does in
// three swipes, then one clear way in. "Get started" creates an account;
// "I already have an account" logs in.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/ink_button.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/welcome/widgets/welcome_slides.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: ReadableWidth(child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, 0),
            child: DomEaseLogo(layout: LogoLayout.horizontalNoTagline, tone: dark ? LogoTone.reversed : LogoTone.primary, height: 34),
          ),

          // ── Three reasons ──
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: welcomeSlides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = welcomeSlides[i];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xxl, AppSpace.screen, AppSpace.lg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    s.picture,
                    const SizedBox(height: AppSpace.xxl),
                    Text(s.title, style: AppText.title.copyWith(color: scheme.onSurface)),
                    const SizedBox(height: AppSpace.md),
                    Text(s.body, style: AppText.lead.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ]),
                );
              },
            ),
          ),

          // ── Where you are in the slides ──
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < welcomeSlides.length; i++)
              AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(color: i == _page ? scheme.primary : scheme.outline, borderRadius: AppRadii.pillAll),
              ),
          ]),

          // ── The way in ──
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, AppSpace.lg),
            child: Column(children: [
              InkButton(label: 'Get started', amber: true, onPressed: () => context.push(Routes.signUp)),
              const SizedBox(height: AppSpace.sm),
              TextButton(onPressed: () => context.push(Routes.logIn), child: const Text('I already have an account')),
            ]),
          ),
        ]),
      )),
    );
  }
}
