// ─── Onboarding Steps ─────────────────────────────────────────────
// The body of each step. Answers go straight to the onboarding view model.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/content_fallbacks.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/ui/household_choices.dart';
import 'package:domease/ui/core/ui/option_tile.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';
import 'package:domease/ui/onboarding/widgets/step_heading.dart';

class StepBody extends ConsumerWidget {
  const StepBody({super.key, required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.read(onboardingProvider.notifier);
    Widget single(List<Choice> choices, String? value, void Function(String) pick) => Column(children: [
          for (final c in choices)
            OptionTile(emoji: c.emoji, label: c.label, selected: value == c.id, locked: c.premium, onTap: () => pick(c.id)),
        ]);
    Widget multi(List<Choice> choices, Set<String> value, void Function(String) pick) => Column(children: [
          for (final c in choices) OptionTile(emoji: c.emoji, label: c.label, multi: true, selected: value.contains(c.id), onTap: () => pick(c.id)),
        ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: switch (draft.step) {
        OnboardingStep.who => [
            const StepHeading(whoHeading, lead: 'A few quick questions, and DomEase plans a first week that fits your home.'),
            for (final (type, emoji) in whoChoices)
              OptionTile(emoji: emoji, label: type.label, selected: draft.type == type, onTap: () => flow.type(type)),
          ],
        OnboardingStep.size => [
            const StepHeading(sizeHeading, lead: 'Recipes and shopping amounts are sized to this. You can change it any time.'),
            _SizeStepper(value: draft.size, onChanged: flow.size),
          ],
        OnboardingStep.mood => [const StepHeading(moodHeading), single(moodChoices, draft.mood, flow.mood)],
        OnboardingStep.goals => [
            const StepHeading(goalsHeading, lead: 'Pick as many as you like.'),
            multi(goalChoices, draft.goals, flow.toggleGoal),
          ],
        OnboardingStep.meals => [
            const StepHeading(mealsHeading, lead: 'Pick as many as you like. Every meal type is planned either way.'),
            multi(mealChoices, draft.mealFocus, flow.toggleMeal),
          ],
        OnboardingStep.currency => [
            const StepHeading(currencyHeading, lead: 'Prices and the shopping total use this currency.'),
            single(currencyChoices, draft.currency, flow.currency),
          ],
        OnboardingStep.diet => [
            const StepHeading(dietHeading, lead: 'Allergy profiles for each person come with Premium.'),
            single(dietChoices, draft.diet, flow.diet),
          ],
        OnboardingStep.ready => [
            const StepHeading(readyHeading, lead: 'Here is what is waiting for you. You can change any of it later.'),
            _Ready(draft: draft),
          ],
        OnboardingStep.premium => [
            const StepHeading(premiumHeading, lead: 'Everything you need to run the house is free. Premium adds the personal and the automatic.'),
            for (final f in (ref.watch(premiumFeaturesProvider).value ?? fallbackPremiumFeatures).take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Row(children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 22),
                  const SizedBox(width: AppSpace.md),
                  Expanded(child: Text(f.comingSoon ? '${f.title} (coming soon)' : f.title, style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface))),
                ]),
              ),
            const SizedBox(height: AppSpace.sm),
            Text('Pay monthly or yearly with MTN Mobile Money or Airtel Money. Cancel any time.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
      },
    );
  }
}

class _SizeStepper extends StatelessWidget {
  const _SizeStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: AppRadii.stageAll, border: Border.all(color: scheme.outline)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.outlined(onPressed: value > 1 ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove), tooltip: 'Fewer'),
          Column(children: [
            Text('$value', style: AppText.display.copyWith(color: scheme.onSurface)),
            Text(value == 1 ? 'person' : 'people', style: Theme.of(context).textTheme.bodySmall),
          ]),
          IconButton.outlined(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add), tooltip: 'More'),
        ],
      ),
    );
  }
}

/// A summary of what was just set up, like a first look at Today.
class _Ready extends StatelessWidget {
  const _Ready({required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = [
      (Icons.ramen_dining_outlined, '35 meals planned for the week', 'Breakfast to pastries, for ${draft.size} ${draft.size == 1 ? 'person' : 'people'}'),
      (Icons.auto_awesome_outlined, 'Four zones with their tasks', 'Kitchen, bathroom, bedrooms, living room'),
      (Icons.shopping_basket_outlined, 'One shopping list in your currency', 'Written from the meals and the zones'),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: AppRadii.stageAll),
      child: Column(children: [
        for (final (icon, title, sub) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: Row(children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.brightness == Brightness.dark ? AppColors.nightClayTint : AppColors.clay100,
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppText.bodyStrong.copyWith(color: scheme.onSurface)),
                  Text(sub, style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}
