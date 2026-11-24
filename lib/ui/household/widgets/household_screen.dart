// ─── Household ────────────────────────────────────────────────────
// Who the app is set up for, and the plan. Size and currency can change at
// any time (FR-ON-3); Premium households manage members and allergies.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/animated_logo.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final h = ref.watch(householdProvider).value;
    if (h == null) return const Scaffold(body: Center(child: LogoLoader()));
    final save = ref.read(householdProvider.notifier).save;

    return Scaffold(
      appBar: AppBar(title: const Text('Your household')),
      body: ReadableWidth(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
        children: [
          Text(h.name, style: AppText.title.copyWith(color: scheme.onSurface)),
          Text(h.type.label, style: Theme.of(context).textTheme.bodySmall),
          const SectionLabel('Home'),
          Card(
            child: Column(children: [
              ListTile(
                title: const Text('People who eat at home'),
                subtitle: const Text('Recipes and amounts scale to this'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(onPressed: h.size > 1 ? () => save(h.copyWith(size: h.size - 1)) : null, icon: const Icon(Icons.remove_circle_outline)),
                  Text('${h.size}', style: AppText.subheading.copyWith(color: scheme.onSurface)),
                  IconButton(onPressed: () => save(h.copyWith(size: h.size + 1)), icon: const Icon(Icons.add_circle_outline)),
                ]),
              ),
              const Divider(),
              ListTile(
                title: const Text('Currency'),
                trailing: Text(h.currency, style: AppText.money.copyWith(color: scheme.onSurface)),
                onTap: () => context.push(Routes.settings),
              ),
              const Divider(),
              ListTile(
                title: const Text('Edit my answers'),
                subtitle: const Text('Who lives here, goals, meals and diet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.answers),
              ),
            ]),
          ),
          const SectionLabel('Plan'),
          Card(
            child: ListTile(
              leading: Icon(h.isPremium ? Icons.workspace_premium : Icons.lock_open_outlined, color: scheme.primary),
              title: Text(h.isPremium ? 'Premium' : 'Free'),
              subtitle: Text(h.isPremium ? 'Everything unlocked, no ads.' : 'Everything you need to run the house.'),
              trailing: h.isPremium ? null : const PremiumBadge(small: true),
              onTap: h.isPremium ? null : () => context.push(Routes.premium),
            ),
          ),
          const SectionLabel('People'),
          PremiumLock(
            locked: !h.isPremium,
            title: 'Household sharing and allergy profiles',
            child: Card(
              child: Column(children: [
                for (final m in h.members)
                  ListTile(
                    leading: CircleAvatar(child: Text(m.name.isEmpty ? '?' : m.name[0])),
                    title: Text(m.name),
                    subtitle: Text(_memberLine(m)),
                  ),
                const Divider(),
                const _InviteTile(),
              ]),
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Set up again?'),
                  content: const Text('This clears the household on this phone. You stay signed in and can set up a new home or join one.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Start again')),
                  ],
                ),
              );
              if (ok != true) return;
              await ref.read(householdProvider.notifier).reset();
              ref.invalidate(onboardingProvider);
              if (context.mounted) context.go(Routes.setup);
            },
            child: const Text('Set up the household again'),
          ),
        ],
      ),
      ),
    );
  }
}

/// The code someone types on "Join a home" to share this household.
class _InviteTile extends ConsumerWidget {
  const _InviteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(inviteCodeProvider);
    return ListTile(
      leading: const Icon(Icons.person_add_alt_1_outlined),
      title: const Text('Invite someone'),
      subtitle: Text(code.when(
        data: (c) => 'Share code $c. They choose Join a home after signing in.',
        loading: () => 'Getting your invite code',
        error: (_, _) => 'The invite code could not load just now.',
      )),
      trailing: code.hasValue
          ? IconButton(
              tooltip: 'Copy code',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code.value!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied.')));
                }
              },
            )
          : null,
    );
  }
}

String _memberLine(HouseholdMember m) {
  final role = switch (m.role) {
    MemberRole.owner => 'Owner',
    MemberRole.member => m.ageGroup.label,
    MemberRole.houseHelp => 'House Help',
  };
  return m.allergies.isEmpty ? role : '$role · allergic to ${m.allergies.join(', ')}';
}
