// ─── Settings ─────────────────────────────────────────────────────
// How the app looks, the currency the household shops in (FR-ON-2, FR-CC-2),
// measurements (always metric, PRD 7.3) and the reminders it may send.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/preferences.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/household_choices.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/core/view_models/preferences_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final change = ref.read(preferencesProvider.notifier).change;
    final home = ref.watch(householdProvider).value;
    final currency = currencyChoices.where((c) => c.id == home?.currency).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            SettingsGroup(title: 'Appearance', footer: prefs.appearance == Appearance.system ? 'Follows your phone: light by day, dark when your phone is.' : null, children: [
              Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Appearance>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: Appearance.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('Phone')),
                      ButtonSegment(value: Appearance.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                      ButtonSegment(value: Appearance.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
                    ],
                    selected: {prefs.appearance},
                    onSelectionChanged: (s) => change((p) => p.copyWith(appearance: s.first)),
                  ),
                ),
              ),
            ]),

            SettingsGroup(title: 'Region', footer: 'Prices, the shopping total and the converter use your currency. Everyone at home shares it.', children: [
              SettingsTile(
                icon: Icons.payments_outlined,
                title: 'Currency',
                subtitle: currency?.label ?? home?.currency ?? 'Set up a home first',
                onTap: home == null ? null : () => _pickCurrency(context, ref, home.currency),
              ),
              const SettingsTile(icon: Icons.straighten, title: 'Measurements', subtitle: 'Metric: g, kg, ml, l and pieces'),
            ]),

            SettingsGroup(
              title: 'Reminders',
              footer: 'DomEase asks your phone for permission the first time it sends one. You can change these any time.',
              children: [
                _Switch(
                  icon: Icons.cleaning_services_outlined,
                  title: 'Cleaning due today',
                  value: prefs.remindTasks,
                  onChanged: (v) => change((p) => p.copyWith(remindTasks: v)),
                ),
                _Switch(
                  icon: Icons.inventory_2_outlined,
                  title: 'Supplies running low',
                  value: prefs.remindLowStock,
                  onChanged: (v) => change((p) => p.copyWith(remindLowStock: v)),
                ),
                _Switch(
                  icon: Icons.ramen_dining_outlined,
                  title: "Next week's meal plan",
                  subtitle: 'Sunday evening',
                  value: prefs.weeklyPlan,
                  onChanged: (v) => change((p) => p.copyWith(weeklyPlan: v)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.icon, required this.title, required this.value, required this.onChanged, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        value: value,
        onChanged: onChanged,
      );
}

Future<void> _pickCurrency(BuildContext context, WidgetRef ref, String current) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (c) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (c, scroll) => ListView(controller: scroll, children: [
        ListTile(title: Text('Where do you shop?', style: Theme.of(c).textTheme.titleMedium)),
        for (final ch in currencyChoices)
          ListTile(
            leading: SizedBox(
              width: 44,
              child: Text(ch.id, style: AppText.money.copyWith(color: Theme.of(c).colorScheme.onSurface)),
            ),
            title: Text(ch.label),
            selected: ch.id == current,
            trailing: ch.id == current ? Icon(Icons.check, color: Theme.of(c).colorScheme.primary) : null,
            onTap: () => Navigator.pop(c, ch.id),
          ),
      ]),
    ),
  );
  if (picked == null || picked == current) return;
  final home = ref.read(householdProvider).value;
  if (home == null) return;
  await ref.read(householdProvider.notifier).save(home.copyWith(currency: picked));
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prices now show in $picked.')));
}
