// ─── Suggest Sheet ────────────────────────────────────────────────
// Name, ingredients and method, sent for review. It is never shown in
// anyone's plan until a moderator approves it (FR-MP-13).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';

Future<void> showSuggestSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (_) => const _SuggestForm(),
    );

class _SuggestForm extends ConsumerStatefulWidget {
  const _SuggestForm();

  @override
  ConsumerState<_SuggestForm> createState() => _SuggestFormState();
}

class _SuggestFormState extends ConsumerState<_SuggestForm> {
  final _name = TextEditingController();
  final _ingredients = TextEditingController();
  final _method = TextEditingController();
  MealType? _type;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _ingredients.dispose();
    _method.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty && _ingredients.text.trim().isNotEmpty && _method.text.trim().isNotEmpty;

  Future<void> _send() async {
    setState(() => _sending = true);
    await suggestRecipe(
      ref,
      RecipeSuggestion(name: _name.text.trim(), ingredients: _ingredients.text.trim(), method: _method.text.trim(), mealType: _type),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Sent for review. Thank you.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpace.xl),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Suggest a recipe', style: AppText.title.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpace.lg),
          TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Dish name')),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, children: [
            for (final t in MealType.values)
              ChoiceChip(label: Text(t.label), selected: _type == t, onSelected: (on) => setState(() => _type = on ? t : null)),
          ]),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _ingredients,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Ingredients', hintText: 'Matoke, beans, tomatoes'),
          ),
          const SizedBox(height: AppSpace.md),
          TextField(controller: _method, onChanged: (_) => setState(() {}), maxLines: 4, decoration: const InputDecoration(labelText: 'Method')),
          const SizedBox(height: AppSpace.xl),
          FilledButton(onPressed: _ready && !_sending ? _send : null, child: Text(_sending ? 'Sending' : 'Send for review')),
        ]),
      ),
    );
  }
}
