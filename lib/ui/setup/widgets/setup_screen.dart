// ─── Set Up Or Join ───────────────────────────────────────────────
// Straight after creating an account (or logging in without a home): is
// this person starting a home, or joining one someone else runs? Joiners
// skip the questions entirely.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider).value;
    final firstName = (session?.name ?? '').trim().split(' ').first;

    return Scaffold(
      body: ReadableWidth(child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xxl, AppSpace.screen, AppSpace.xl),
          children: [
            const DomEaseLogo(layout: LogoLayout.mark, height: 52),
            const SizedBox(height: AppSpace.xxl),
            Text(firstName.isEmpty ? "You're in" : 'Welcome, $firstName', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.xs),
            Text.rich(TextSpan(style: AppText.title.copyWith(color: scheme.onSurface, fontSize: 30), children: [
              const TextSpan(text: "Let's get your "),
              TextSpan(text: 'home', style: TextStyle(color: scheme.primary)),
              const TextSpan(text: ' ready'),
            ])),
            const SizedBox(height: AppSpace.xxl),
            _Choice(
              icon: Icons.add_home_outlined,
              title: 'Set up a new home',
              body: 'Answer a few quick questions and DomEase plans your first week. About two minutes.',
              onTap: () {
                ref.invalidate(onboardingProvider);
                context.push(Routes.questions);
              },
            ),
            _Choice(
              icon: Icons.group_add_outlined,
              title: 'Join a home',
              body: 'Someone you live with already uses DomEase and sent you an invite code.',
              onTap: () => context.push(Routes.join),
            ),
            const SizedBox(height: AppSpace.lg),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(sessionProvider.notifier).signOut();
                  if (context.mounted) context.go(Routes.welcome);
                },
                child: Text(session == null ? 'Back to the start' : 'Not ${session.label}? Sign out'),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.icon, required this.title, required this.body, required this.onTap});

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.cardAll, side: BorderSide(color: scheme.outline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: dark ? AppColors.nightClayTint : AppColors.clay100,
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.subheading.copyWith(color: scheme.onSurface)),
                const SizedBox(height: AppSpace.xs),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            Icon(Icons.chevron_right, color: scheme.outline),
          ]),
        ),
      ),
    );
  }
}
