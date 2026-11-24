// ─── Today ────────────────────────────────────────────────────────
// What the household opens on (FR-TD-1 to FR-TD-7).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/ad_slot.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/progress_row.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/today/view_models/today_viewmodel.dart';
import 'package:domease/ui/today/widgets/today_parts.dart';
import 'package:domease/utils/dates.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final household = ref.watch(householdProvider).value;
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpace.screen,
        title: DomEaseLogo(layout: LogoLayout.horizontalNoTagline, tone: dark ? LogoTone.reversed : LogoTone.primary, height: 32),
        actions: [
          if (household != null) HouseholdChip(household: household, onTap: () => context.push(Routes.household)),
          const SizedBox(width: AppSpace.sm),
          // You: profile, settings, help and legal.
          IconButton(
            tooltip: 'You and settings',
            onPressed: () => context.push(Routes.you),
            icon: InitialsAvatar(ref.watch(sessionProvider).value?.initials ?? '?', radius: 17),
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: ReadableWidth(child: RefreshIndicator(
        onRefresh: () => ref.refresh(todayProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.huge),
          children: [
            Text('Today', style: AppText.display.copyWith(color: scheme.onSurface)),
            Text(longDate(DateTime.now()), style: Theme.of(context).textTheme.bodySmall),
            const NudgeBanner(),
            AsyncView(
              value: today,
              onRetry: () => ref.invalidate(todayProvider),
              data: (t) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpace.lg),
                  TonightCard(recipe: t.tonight),
                  const SectionLabel('This week'),
                  ProgressRow(label: 'Meals planned', done: t.mealsPlanned, of: t.mealsTotal),
                  ProgressRow(label: 'Zones cleared', done: t.zonesClear, of: t.zones),
                  ProgressRow(label: 'List bought', done: t.itemsBought, of: t.itemsTotal),
                  if (t.dueToday.isNotEmpty) ...[
                    SectionLabel('Due today', trailing: Text('${t.dueToday.length}', style: AppText.money.copyWith(fontSize: 13))),
                    DueToday(items: t.dueToday.take(4).toList()),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  ListSnapshot(total: t.listTotal, low: t.lowCount, currency: household?.currency ?? 'UGX'),
                ],
              ),
            ),
            const SectionLabel('Tools'),
            const ToolsRow(),
            const AdSlot(screen: 'today'),
            const PremiumUpsell(),
          ],
        ),
      )),
    );
  }
}
