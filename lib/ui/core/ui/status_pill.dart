// ─── Status Pill ──────────────────────────────────────────────────
// Status is never colour alone: always a tinted pill, an icon and a word
// (docs/05-design-system.md).
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

enum PillTone { good, low, quiet }

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.icon, this.tone = PillTone.quiet});

  final String label;
  final IconData icon;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg) = switch (tone) {
      PillTone.good => dark ? (const Color(0xFF24352A), AppColors.sage400) : (AppColors.sage100, AppColors.sage800),
      PillTone.low => dark ? (const Color(0xFF4A2016), AppColors.clay200) : (AppColors.danger100, AppColors.danger),
      PillTone.quiet => dark ? (AppColors.nightLine, AppColors.nightText) : (AppColors.paper2, AppColors.ink2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
