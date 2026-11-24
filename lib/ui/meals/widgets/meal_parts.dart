// ─── Meal Parts ───────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';
import 'package:domease/ui/meals/widgets/suggest_sheet.dart';
import 'package:domease/utils/dates.dart';

/// One day of the week: the dish, its cuisine and who it suits.
class DayMealCard extends StatelessWidget {
  const DayMealCard({super.key, required this.weekday, required this.recipe, this.isToday = false});

  final int weekday;
  final Recipe? recipe;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = recipe;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardAll,
        side: isToday ? BorderSide(color: scheme.primary, width: 1.5) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: r == null ? null : () => context.push(Routes.recipe(r.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Row(children: [
            SizedBox(
              width: 46,
              child: Column(children: [
                Text(weekdays[weekday - 1].substring(0, 3).toUpperCase(), style: AppText.eyebrow.copyWith(color: isToday ? scheme.primary : scheme.outline)),
                if (isToday) Text('Today', style: AppText.caption.copyWith(color: scheme.primary)),
              ]),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r?.name ?? 'Nothing planned', style: AppText.subheading.copyWith(color: scheme.onSurface)),
                if (r != null)
                  Text(
                    [r.cuisine, r.ageGroups.map((a) => a.label).join(', ')].where((s) => s.isNotEmpty).join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ]),
            ),
            Icon(Icons.chevron_right, color: scheme.outline),
          ]),
        ),
      ),
    );
  }
}

/// Diabetic and PCOS friendly ideas: the disclaimer is always visible, on
/// every plan; the suggestions behind it are Premium (FR-MP-12).
class DietarySupportCard extends ConsumerWidget {
  const DietarySupportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final disclaimer = ref.watch(settingsProvider).value?.dietaryDisclaimer ?? 'This is general guidance, not medical advice.';
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final picks = recipes.where((r) => r.dietary.isNotEmpty).take(4).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Special dietary support', style: AppText.subheading.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpace.sm),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 18, color: scheme.outline),
            const SizedBox(width: AppSpace.sm),
            Expanded(child: Text(disclaimer, style: Theme.of(context).textTheme.bodySmall)),
          ]),
          const SizedBox(height: AppSpace.md),
          PremiumLock(
            locked: !ref.watch(isPremiumProvider),
            title: 'Diabetic and PCOS friendly ideas',
            child: Column(children: [
              for (final r in picks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.name),
                  subtitle: Text(r.dietary.map((d) => d == 'pcos' ? 'PCOS friendly' : 'Diabetic friendly').join(' · ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.recipe(r.id)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Birthday, Christmas, Easter and Eid menus: one locked section (FR-MP-9).
class OccasionsCard extends ConsumerWidget {
  const OccasionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    const occasions = {'birthday': 'Birthday', 'christmas': 'Christmas', 'easter': 'Easter', 'eid': 'Eid'};
    return PremiumLock(
      locked: !ref.watch(isPremiumProvider),
      title: 'Special occasion menus',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Special occasions', style: AppText.subheading.copyWith(color: scheme.onSurface)),
            const SizedBox(height: AppSpace.sm),
            for (final e in occasions.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.celebration_outlined, color: scheme.primary),
                title: Text(e.value),
                subtitle: Text(recipes.where((r) => r.occasions.contains(e.key)).map((r) => r.name).join(', ')),
              ),
          ]),
        ),
      ),
    );
  }
}

/// "Suggest a recipe", open to everyone (FR-MP-13).
class SuggestCard extends StatelessWidget {
  const SuggestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
        leading: Icon(Icons.edit_note, color: scheme.primary, size: 28),
        title: Text('Suggest a recipe', style: AppText.bodyStrong.copyWith(color: scheme.onSurface)),
        subtitle: const Text('Send us a dish your home loves. We review every one.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showSuggestSheet(context),
      ),
    );
  }
}
