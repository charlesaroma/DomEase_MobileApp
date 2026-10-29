// ─── Today ────────────────────────────────────────────────────────
// What the household opens on. For now: the brand in place (app bar logo,
// the Tonight card, the week's progress, the tab bar) so every screen built
// next starts from the same parts. Data arrives with the data layer.
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpace.screen,
        title: DomEaseLogo(
          layout: LogoLayout.horizontalNoTagline,
          tone: dark ? LogoTone.reversed : LogoTone.primary,
          height: 34,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.screen),
        children: [
          Text('Today', style: AppText.display.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpace.xs),
          Text('Your week at a glance', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpace.xxl),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(border: Border(left: BorderSide(color: scheme.primary, width: 3))),
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TONIGHT', style: AppText.eyebrow.copyWith(color: scheme.primary)),
                  const SizedBox(height: AppSpace.sm),
                  Text('Groundnut stew', style: AppText.heading.copyWith(color: scheme.onSurface)),
                  Text('with posho and sukuma', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton(onPressed: () {}, child: const Text('Plan the week')),
          const SizedBox(height: AppSpace.xxl),
          Text('THIS WEEK', style: AppText.eyebrow.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: AppSpace.md),
          const _Progress(label: 'Meals planned', done: 10, of: 12),
          const _Progress(label: 'Zones cleared', done: 2, of: 5),
          const _Progress(label: 'List bought', done: 14, of: 19),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.ramen_dining_outlined), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Clean'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: 'Shop'),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.done, required this.of});

  final String label;
  final int done;
  final int of;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppText.label.copyWith(color: scheme.onSurface))),
              Text('$done of $of', style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          ClipRRect(
            borderRadius: AppRadii.pillAll,
            child: LinearProgressIndicator(value: done / of, minHeight: 6),
          ),
        ],
      ),
    );
  }
}
