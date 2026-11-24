// ─── Progress Row ─────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

/// "Meals planned    10 of 12" over a clay bar.
class ProgressRow extends StatelessWidget {
  const ProgressRow({super.key, required this.label, required this.done, required this.of});

  final String label;
  final int done;
  final int of;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppText.label.copyWith(color: onSurface))),
              Text('$done of $of', style: AppText.money.copyWith(fontSize: 13, color: onSurface)),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          ClipRRect(
            borderRadius: AppRadii.pillAll,
            child: LinearProgressIndicator(value: of == 0 ? 0 : done / of, minHeight: 6),
          ),
        ],
      ),
    );
  }
}
