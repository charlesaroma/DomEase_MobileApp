// ─── You ──────────────────────────────────────────────────────────
// One place for the person, their home and the app: profile and sign in,
// the household and its answers, the plan, settings, help and the legal
// pages. Opened from the initials at the top of Today.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/legal.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider).value;
    final home = ref.watch(householdProvider).value;
    final premium = home?.isPremium ?? false;

    Future<void> signOut() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Sign out?'),
          content: const Text('Your home stays safe on your account. Log in again any time to pick up where you left off.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sign out')),
          ],
        ),
      );
      if (ok != true) return;
      await ref.read(sessionProvider.notifier).signOut();
      ref.invalidate(onboardingProvider);
      if (context.mounted) context.go(Routes.welcome);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            // ── The person ──
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push(Routes.profile),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Row(children: [
                    InitialsAvatar(session?.initials ?? '?', radius: 28),
                    const SizedBox(width: AppSpace.lg),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(session?.name ?? 'Your account', style: AppText.heading.copyWith(color: scheme.onSurface)),
                        Text(session?.label ?? 'Not signed in', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: AppSpace.xs),
                        Text('Edit profile', style: AppText.label.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    Icon(Icons.chevron_right, color: scheme.outline),
                  ]),
                ),
              ),
            ),

            // ── The home ──
            SettingsGroup(title: 'Home', children: [
              SettingsTile(
                icon: Icons.home_outlined,
                title: home?.name ?? 'Your household',
                subtitle: home == null ? 'Set up or join a home' : '${home.type.label} · ${home.size} ${home.size == 1 ? 'person' : 'people'}',
                onTap: () => context.push(home == null ? Routes.setup : Routes.household),
              ),
              if (home != null)
                SettingsTile(
                  icon: Icons.tune,
                  title: 'Edit my answers',
                  subtitle: 'Who lives here, goals, meals and diet',
                  onTap: () => context.push(Routes.answers),
                ),
              if (home != null)
                SettingsTile(
                  icon: Icons.insights_outlined,
                  title: 'Insights',
                  subtitle: 'Food budget and eating trends',
                  trailing: premium ? null : const PremiumBadge(small: true),
                  onTap: () => context.push(Routes.insights),
                ),
              SettingsTile(
                icon: premium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                title: premium ? 'Premium' : 'Free plan',
                subtitle: premium ? 'Everything unlocked, no ads' : 'See what Premium adds',
                trailing: premium ? null : const PremiumBadge(small: true),
                onTap: () => context.push(Routes.premium),
              ),
            ]),

            // ── The app ──
            SettingsGroup(title: 'App', children: [
              SettingsTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Appearance, currency and reminders',
                onTap: () => context.push(Routes.settings),
              ),
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help and support',
                subtitle: 'Questions, contact us, report a problem',
                onTap: () => context.push(Routes.help),
              ),
            ]),

            // ── Legal ──
            SettingsGroup(title: 'Legal', children: [
              for (final doc in LegalDocId.values)
                SettingsTile(icon: _legalIcon(doc), title: doc.title, onTap: () => context.push(Routes.legal(doc))),
              SettingsTile(icon: Icons.info_outline, title: 'About DomEase', onTap: () => context.push(Routes.about)),
            ]),

            const SizedBox(height: AppSpace.xxl),
            OutlinedButton.icon(
              onPressed: signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _legalIcon(LegalDocId id) => switch (id) {
      LegalDocId.terms => Icons.description_outlined,
      LegalDocId.privacy => Icons.lock_outline,
      LegalDocId.premium => Icons.receipt_long_outlined,
      LegalDocId.health => Icons.health_and_safety_outlined,
    };
