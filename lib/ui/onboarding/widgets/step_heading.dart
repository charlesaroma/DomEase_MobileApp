// ─── Step Heading ─────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/household_choices.dart';

/// "Who lives in your home?" with "home" in clay.
class StepHeading extends StatelessWidget {
  const StepHeading(this.heading, {super.key, this.lead});

  final Heading heading;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = AppText.title.copyWith(color: scheme.onSurface, fontSize: 30);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(style: base, children: [
          TextSpan(text: heading.$1),
          TextSpan(text: heading.$2, style: TextStyle(color: scheme.primary)),
          TextSpan(text: heading.$3),
        ])),
        if (lead != null) ...[
          const SizedBox(height: AppSpace.md),
          Text(lead!, style: AppText.lead.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
        const SizedBox(height: AppSpace.xxl),
      ],
    );
  }
}
