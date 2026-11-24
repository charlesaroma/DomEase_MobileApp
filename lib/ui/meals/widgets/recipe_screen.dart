// ─── Recipe ───────────────────────────────────────────────────────
// A dish sized to the household (FR-MP-2, FR-MP-3): tags, ingredients with
// market swaps (FR-MP-4), numbered steps, and the Premium layer: allergy
// warning, favourite, healthier version (FR-MP-7, FR-MP-10, FR-MP-11).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/use_cases/scale_recipe.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/recipe_photo.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/ui/status_pill.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeProvider(id));
    final premium = ref.watch(isPremiumProvider);
    final favourite = ref.watch(favouritesProvider.select((f) => f.contains(id)));
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          tooltip: premium ? 'Favourite' : 'Favourites come with Premium',
          icon: Icon(favourite ? Icons.favorite : Icons.favorite_border),
          onPressed: premium ? () => ref.read(favouritesProvider.notifier).toggle(id) : null,
        ),
      ]),
      body: ReadableWidth(child: AsyncView(
        value: recipe,
        data: (r) => r == null ? const Center(child: Text('This recipe is no longer in the library.')) : _Body(recipe: r),
      )),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final household = ref.watch(householdProvider).value;
    final people = household?.size ?? recipe.servings;
    final premium = household?.isPremium ?? false;
    final allergic = premium && recipe.contains(household!.allergies);
    final disclaimer = ref.watch(settingsProvider).value?.dietaryDisclaimer;
    final r = recipe;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
      children: [
        RecipePhoto(recipe: r, radius: AppRadii.cardAll, iconSize: 56),
        const SizedBox(height: AppSpace.xl),
        Text(r.mealType.label.toUpperCase(), style: AppText.eyebrow.copyWith(color: scheme.primary)),
        const SizedBox(height: AppSpace.sm),
        Text(r.name, style: AppText.display.copyWith(color: scheme.onSurface, fontSize: 34)),
        const SizedBox(height: AppSpace.md),
        Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
          StatusPill(label: r.cuisine, icon: Icons.public),
          if (r.totalMinutes > 0) StatusPill(label: '${r.totalMinutes} min', icon: Icons.schedule),
          if (r.isPremium) const StatusPill(label: 'Premium', icon: Icons.workspace_premium_outlined),
          for (final a in r.ageGroups) StatusPill(label: a.label, icon: Icons.people_outline),
          for (final b in r.benefits) StatusPill(label: b, icon: Icons.spa_outlined, tone: PillTone.good),
        ]),
        if (allergic) ...[
          const SizedBox(height: AppSpace.lg),
          const _Warning(text: 'Someone at home is allergic to an ingredient in this dish.'),
        ],
        if (r.dietary.isNotEmpty && disclaimer != null) ...[
          const SizedBox(height: AppSpace.lg),
          _Note(icon: Icons.info_outline, text: disclaimer),
        ],
        SectionLabel('Ingredients for $people', trailing: Text('Serves ${r.servings} as written', style: Theme.of(context).textTheme.bodySmall)),
        PremiumLock(
          locked: r.isPremium && !premium,
          title: 'This recipe comes with Premium',
          body: 'See every ingredient and step, sized to your home.',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Ingredients(items: scaleIngredients(r.ingredients, from: r.servings, to: people)),
            const SectionLabel('Method'),
            _Steps(steps: r.steps),
          ]),
        ),
        if (r.healthyVariant != null) ...[
          const SectionLabel('Healthier version'),
          PremiumLock(
            locked: !premium,
            title: 'The healthier swap',
            body: 'Lighter flours, less sugar, baked not fried.',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.healthyVariant!.summary, style: AppText.body.copyWith(color: scheme.onSurface)),
                  const SizedBox(height: AppSpace.md),
                  _Ingredients(items: scaleIngredients(r.healthyVariant!.ingredients, from: r.servings, to: people)),
                  const SizedBox(height: AppSpace.md),
                  _Steps(steps: r.healthyVariant!.steps),
                ]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Ingredients extends StatelessWidget {
  const _Ingredients({required this.items});

  final List<Ingredient> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      for (final i in items)
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.5)))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(i.name, style: AppText.body.copyWith(color: scheme.onSurface))),
              Text(formatAmount(i), style: AppText.money.copyWith(color: scheme.onSurface)),
            ]),
            if (i.substitute != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text("Can't find it? Try ${i.substitute!.toLowerCase()}", style: AppText.caption.copyWith(color: scheme.primary)),
              ),
          ]),
        ),
    ]);
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.lg),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.primary,
              child: Text('${i + 1}', style: AppText.caption.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(child: Text(steps[i], style: AppText.body.copyWith(color: scheme.onSurface))),
          ]),
        ),
    ]);
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(color: AppColors.danger100, borderRadius: AppRadii.cardAll),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(text, style: AppText.label.copyWith(color: AppColors.danger))),
        ]),
      );
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ]);
}
