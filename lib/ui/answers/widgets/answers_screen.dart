// ─── Edit My Answers ──────────────────────────────────────────────
// The setup questions, answerable again at any time: who lives here, how
// many eat at home (FR-ON-3), goals, the meals they want help with and diet.
// Recipes and amounts follow the new answers as soon as they are saved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/household_choices.dart';
import 'package:domease/ui/core/ui/option_tile.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

class AnswersScreen extends ConsumerStatefulWidget {
  const AnswersScreen({super.key});

  @override
  ConsumerState<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends ConsumerState<AnswersScreen> {
  late final Household? _start = ref.read(householdProvider).value;
  late HouseholdType _type = _start?.type ?? HouseholdType.family;
  late int _size = _start?.size ?? 1;
  late final Set<String> _goals = {...?_start?.goals};
  late final Set<String> _meals = {...?_start?.mealFocus};
  late String _diet = _start?.diet ?? 'none';
  bool _busy = false;

  bool get _changed {
    final s = _start;
    if (s == null) return false;
    return _type != s.type ||
        _size != s.size ||
        _diet != s.diet ||
        _goals.length != s.goals.length ||
        !_goals.containsAll(s.goals) ||
        _meals.length != s.mealFocus.length ||
        !_meals.containsAll(s.mealFocus);
  }

  Future<void> _save() async {
    final s = _start;
    if (s == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(householdProvider.notifier).save(
            s.copyWith(type: _type, size: _size, goals: _goals.toList(), mealFocus: _meals.toList(), diet: _diet),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved. Your plan follows your new answers.')));
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your answers could not be saved just now. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggle(Set<String> set, String id) => setState(() {
        if (!set.remove(id)) set.add(id);
      });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final premium = ref.watch(isPremiumProvider);
    String plain(Heading h) => '${h.$1}${h.$2}${h.$3}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit my answers'),
        actions: [
          TextButton(onPressed: _busy || !_changed ? null : _save, child: Text(_busy ? 'Saving' : 'Save')),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            SectionLabel(plain(whoHeading)),
            for (final (type, emoji) in whoChoices)
              OptionTile(emoji: emoji, label: type.label, selected: _type == type, onTap: () => setState(() => _type = type)),

            SectionLabel(plain(sizeHeading)),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
                child: Row(children: [
                  Expanded(child: Text('People who eat at home', style: AppText.body.copyWith(color: scheme.onSurface))),
                  IconButton(
                    onPressed: _size > 1 ? () => setState(() => _size--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Fewer',
                  ),
                  SizedBox(
                    width: 32,
                    child: Text('$_size', textAlign: TextAlign.center, style: AppText.subheading.copyWith(color: scheme.onSurface)),
                  ),
                  IconButton(onPressed: () => setState(() => _size++), icon: const Icon(Icons.add_circle_outline), tooltip: 'More'),
                ]),
              ),
            ),

            SectionLabel(plain(goalsHeading)),
            for (final c in goalChoices)
              OptionTile(emoji: c.emoji, label: c.label, multi: true, selected: _goals.contains(c.id), onTap: () => _toggle(_goals, c.id)),

            SectionLabel(plain(mealsHeading)),
            for (final c in mealChoices)
              OptionTile(emoji: c.emoji, label: c.label, multi: true, selected: _meals.contains(c.id), onTap: () => _toggle(_meals, c.id)),

            SectionLabel(plain(dietHeading)),
            for (final c in dietChoices)
              OptionTile(
                emoji: c.emoji,
                label: c.label,
                selected: _diet == c.id,
                locked: c.premium && !premium,
                onTap: () => setState(() => _diet = c.id),
              ),

            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed: _busy || !_changed ? null : _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(_busy ? 'Saving' : 'Save my answers'),
            ),
          ],
        ),
      ),
    );
  }
}
