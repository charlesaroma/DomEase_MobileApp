// ─── Option Tile ──────────────────────────────────────────────────
// A big tappable answer: emoji, words, and a radio or a tick box. Selected
// tiles take a clay border and a blush fill.
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
    this.locked = false,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Tick box instead of a radio: "pick as many as you like".
  final bool multi;

  /// Premium only; shown but not choosable on the free plan.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected ? (dark ? AppColors.nightClayTint : AppColors.clay100) : scheme.surfaceContainerHighest;
    final border = selected ? scheme.primary : scheme.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: AppRadii.cardAll,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.lg),
            decoration: BoxDecoration(color: fill, borderRadius: AppRadii.cardAll, border: Border.all(color: border, width: selected ? 1.5 : 1)),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.body.copyWith(color: locked ? scheme.outline : scheme.onSurface, fontWeight: FontWeight.w500),
                  ),
                ),
                if (locked) const PremiumBadge(small: true) else _Mark(selected: selected, multi: multi),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.selected, required this.multi});

  final bool selected;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: multi ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multi ? BorderRadius.circular(6) : null,
        color: selected && multi ? scheme.primary : null,
        border: Border.all(color: selected ? scheme.primary : scheme.outline, width: 1.5),
      ),
      child: selected
          ? (multi
              ? Icon(Icons.check, size: 15, color: scheme.onPrimary)
              : Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary))))
          : null,
    );
  }
}
