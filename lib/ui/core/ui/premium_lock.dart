// ─── Premium Lock ─────────────────────────────────────────────────
// Premium content stays visible but inert under one lock (FR-HH-2, FR-MP-8):
// households can see what they would get, never use it.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

class PremiumLock extends StatelessWidget {
  const PremiumLock({super.key, required this.locked, required this.title, required this.child, this.body});

  final bool locked;
  final String title;
  final String? body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        IgnorePointer(
          child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Opacity(opacity: 0.55, child: child)),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(AppSpace.xl),
              padding: const EdgeInsets.all(AppSpace.xl),
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: AppRadii.stageAll),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PremiumBadge(),
                  const SizedBox(height: AppSpace.md),
                  Text(title, textAlign: TextAlign.center, style: AppText.heading.copyWith(color: scheme.onSurface)),
                  if (body != null) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(body!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: scheme.tertiary, foregroundColor: scheme.onTertiary),
                    onPressed: () => context.push(Routes.premium),
                    child: const Text('See Premium'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The small amber "Premium" pill. Amber means "this costs money" (docs/05-design-system.md).
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    final amber = Theme.of(context).colorScheme.tertiary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? AppSpace.sm : AppSpace.md, vertical: small ? 2 : AppSpace.xs),
      decoration: BoxDecoration(borderRadius: AppRadii.pillAll, border: Border.all(color: amber, width: 1.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: small ? 12 : 14, color: amber),
          const SizedBox(width: AppSpace.xs),
          Text('Premium', style: AppText.caption.copyWith(color: amber, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
