// ─── Insights ─────────────────────────────────────────────────────
// Premium's view of the home over time: the food budget against what each
// market trip really cost, and what the family eats most.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/insights/widgets/budget_view.dart';
import 'package:domease/ui/insights/widgets/trends_view.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = !ref.watch(isPremiumProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Insights'),
          bottom: const TabBar(tabs: [Tab(text: 'Budget'), Tab(text: 'Eating trends')]),
        ),
        body: ReadableWidth(
          child: TabBarView(children: [
            PremiumLock(
              locked: locked,
              title: 'Budget insights come with Premium',
              body: 'Set a monthly food budget and see what every market trip really cost.',
              child: const BudgetView(),
            ),
            PremiumLock(
              locked: locked,
              title: 'Eating trends come with Premium',
              body: 'See what your home eats most and how varied each week is.',
              child: const TrendsView(),
            ),
          ]),
        ),
      ),
    );
  }
}
