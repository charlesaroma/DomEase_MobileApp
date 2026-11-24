// ─── Ad Slot ──────────────────────────────────────────────────────
// Where an AdMob banner or native unit sits on the free plan (FR-AD-1,
// FR-AD-2). Premium households get nothing in its place, not a blank space
// (FR-TD-6). The development flavor shows a labelled placeholder; production
// shows nothing until the AdMob unit ids are added (google_mobile_ads).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

class AdSlot extends ConsumerWidget {
  const AdSlot({super.key, required this.screen, this.native = false});

  /// 'today', 'meals', 'clean' or 'shop', as switched in the admin settings.
  final String screen;

  /// The Shop's "sponsored product" placement (FR-SL-3).
  final bool native;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider.select((s) => s.value?.adsOn(screen) ?? false));
    if (ref.watch(isPremiumProvider) || !on || !ref.watch(flavorProvider).useDemoData) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: native ? 84 : 56,
      margin: const EdgeInsets.symmetric(vertical: AppSpace.md),
      decoration: BoxDecoration(borderRadius: AppRadii.cardAll, border: Border.all(color: scheme.outline)),
      alignment: Alignment.center,
      child: Text(native ? 'Sponsored product' : 'Ad', style: AppText.caption.copyWith(color: scheme.outline)),
    );
  }
}
