// ─── Section Label ────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

/// The small uppercase label above a group: "TONIGHT", "THIS WEEK".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.xxl, bottom: AppSpace.md),
        child: Row(
          children: [
            Expanded(child: Text(text.toUpperCase(), style: AppText.eyebrow.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))),
            ?trailing,
          ],
        ),
      );
}
