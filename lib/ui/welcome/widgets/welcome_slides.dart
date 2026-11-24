// ─── Welcome Slides ───────────────────────────────────────────────
// Three short reasons to start, each a small drawing of the real app: the
// week of meals, the cleaning rota, the shared list. No stock photos.
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/illustrations/dish_illustration.dart';

class WelcomeSlide {
  const WelcomeSlide({required this.title, required this.body, required this.picture});

  final String title;
  final String body;
  final Widget picture;
}

const welcomeSlides = [
  WelcomeSlide(
    title: 'Plan a week of meals in minutes',
    body: 'Breakfast to pastries, sized to your household, with swaps for whatever the market has.',
    picture: _Dishes(),
  ),
  WelcomeSlide(
    title: 'Share the cleaning fairly',
    body: 'Every part of the home has its tasks and its person, so nobody has to remind anybody.',
    picture: _Rota(),
  ),
  WelcomeSlide(
    title: 'One list for the whole house',
    body: 'Written from your meals and what is running low, priced in your currency.',
    picture: _List(),
  ),
];

/// The soft clay stage every picture sits on.
class _Stage extends StatelessWidget {
  const _Stage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.xl),
        decoration: BoxDecoration(color: AppColors.clay100, borderRadius: AppRadii.stageAll),
        child: child,
      );
}

class _Dishes extends StatelessWidget {
  const _Dishes();

  static const _items = [
    (Dish.groundnutStew, 'Groundnut stew', AppColors.white),
    (Dish.matokeKatogo, 'Matoke katogo', AppColors.sage100),
    (Dish.rolex, 'Rolex', AppColors.amber200),
    (Dish.tilapia, 'Tilapia', AppColors.clay200),
    (Dish.beefPilau, 'Beef pilau', AppColors.sage200),
    (Dish.mandazi, 'Mandazi', AppColors.white),
  ];

  @override
  Widget build(BuildContext context) => _Stage(
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.sm,
          crossAxisSpacing: AppSpace.sm,
          children: [
            for (final (dish, name, colour) in _items)
              Container(
                decoration: BoxDecoration(color: colour, borderRadius: AppRadii.cardAll),
                padding: const EdgeInsets.all(AppSpace.xs),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(child: FittedBox(child: DishIllustration(dish, size: 64))),
                  const SizedBox(height: 2),
                  Text(name, textAlign: TextAlign.center, maxLines: 2, style: AppText.caption.copyWith(color: AppColors.ink)),
                ]),
              ),
          ],
        ),
      );
}

class _Rota extends StatelessWidget {
  const _Rota();

  static const _zones = [('Kitchen', 'Grace', 1.0), ('Bathroom', 'Joy', 0.35), ('Living room', 'Tendo', 0.6)];

  @override
  Widget build(BuildContext context) => _Stage(
        child: Column(children: [
          for (final (zone, who, done) in _zones)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpace.sm),
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadii.cardAll),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.sage),
                  const SizedBox(width: AppSpace.sm),
                  Text(zone, style: AppText.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  Text('  ·  $who', style: AppText.caption),
                  const Spacer(),
                  Text(done == 1 ? 'Clear' : '${(done * 100).round()}%', style: AppText.caption.copyWith(color: AppColors.sage800)),
                ]),
                const SizedBox(height: AppSpace.sm),
                ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: LinearProgressIndicator(value: done, minHeight: 5, color: AppColors.clay, backgroundColor: AppColors.paper2),
                ),
              ]),
            ),
        ]),
      );
}

class _List extends StatelessWidget {
  const _List();

  static const _items = [('Groundnuts, 1 kg', '8,000', true), ('Posho, 2 kg', '6,500', true), ('Tomatoes, 1 kg', '5,000', false), ('Soap, 3 bars', '7,500', false)];

  @override
  Widget build(BuildContext context) => _Stage(
        child: Container(
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadii.cardAll),
          child: Column(children: [
            Row(children: [
              Text('Saturday list', style: AppText.label.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('UGX 27,000', style: AppText.money.copyWith(fontSize: 13, color: AppColors.clay)),
            ]),
            const Divider(),
            for (final (item, price, done) in _items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? AppColors.clay : AppColors.line2),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(item,
                        style: AppText.label.copyWith(color: AppColors.ink, decoration: done ? TextDecoration.lineThrough : null)),
                  ),
                  Text(price, style: AppText.money.copyWith(fontSize: 12, color: AppColors.ink)),
                ]),
              ),
          ]),
        ),
      );
}
