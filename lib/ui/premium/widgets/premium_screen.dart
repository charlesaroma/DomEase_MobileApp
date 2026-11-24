// ─── Premium ──────────────────────────────────────────────────────
// What Premium adds and what it costs, paid by mobile money (FR-MZ-3). The
// price comes from the admin settings; until it is set, the screen says so
// instead of inventing one.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/content_fallbacks.dart';
import 'package:domease/domain/models/premium.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/utils/money.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  PremiumPlan _plan = PremiumPlan.yearly;
  bool _busy = false;

  Future<void> _upgrade() async {
    setState(() => _busy = true);
    try {
      await ref.read(householdProvider.notifier).upgrade(_plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Premium.')));
      context.pop();
    } on NoHouseholdFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        action: SnackBarAction(label: 'Set up', onPressed: () => context.go(Routes.setup)),
      ));
    } on Failure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      // Never show a raw error to a household.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium could not start just now. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    final premium = ref.watch(isPremiumProvider);
    // Premium belongs to a home. With none on this phone, offer to set one up
    // instead of a payment that cannot go anywhere.
    final hasHome = ref.watch(householdProvider).value != null;
    final monthly = settings?.monthlyPrice;
    final yearly = settings?.yearlyPrice;
    // The development flavor can always try Premium, priced or not.
    final priced = monthly != null || yearly != null || ref.watch(flavorProvider).useDemoData;

    return Scaffold(
      backgroundColor: AppColors.clay900,
      appBar: AppBar(foregroundColor: AppColors.white),
      body: ReadableWidth(child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            const DomEaseLogo(layout: LogoLayout.mark, tone: LogoTone.reversed, height: 64),
            const SizedBox(height: AppSpace.xl),
            Text(premium ? "You're on Premium" : 'Run the house your way', style: AppText.display.copyWith(color: AppColors.white)),
            const SizedBox(height: AppSpace.sm),
            Text('Everything free stays free. Premium adds the personal and the automatic.', style: AppText.lead.copyWith(color: AppColors.clay200)),
            const SizedBox(height: AppSpace.xxl),
            for (final f in ref.watch(premiumFeaturesProvider).value ?? fallbackPremiumFeatures)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: AppColors.sage400, size: 22),
                  const SizedBox(width: AppSpace.md),
                  Expanded(child: Text(f.comingSoon ? '${f.title} (coming soon)' : f.title, style: AppText.body.copyWith(color: AppColors.white))),
                ]),
              ),
            const SizedBox(height: AppSpace.xl),
            if (!premium && !hasHome) ...[
              Text('Premium is added to a home. Set yours up first, then come back here.',
                  style: AppText.body.copyWith(color: AppColors.clay200)),
              const SizedBox(height: AppSpace.lg),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: AppColors.white),
                onPressed: () => context.go(Routes.setup),
                child: const Text('Set up my home'),
              ),
            ],
            if (!premium && hasHome) ...[
              _PlanTile(
                selected: _plan == PremiumPlan.yearly,
                title: 'Yearly',
                price: yearly == null ? 'Price at launch' : money(yearly),
                onTap: () => setState(() => _plan = PremiumPlan.yearly),
              ),
              _PlanTile(
                selected: _plan == PremiumPlan.monthly,
                title: 'Monthly',
                price: monthly == null ? 'Price at launch' : money(monthly),
                onTap: () => setState(() => _plan = PremiumPlan.monthly),
              ),
              const SizedBox(height: AppSpace.lg),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: AppColors.white),
                onPressed: _busy || !priced ? null : _upgrade,
                child: Text(_busy ? 'Opening mobile money' : 'Pay with mobile money'),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                priced ? 'MTN Mobile Money or Airtel Money. Cancel any time.' : 'Premium opens when the price is announced. Everything free works today.',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(color: AppColors.clay200),
              ),
            ],
          ],
        ),
      )),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.selected, required this.title, required this.price, required this.onTap});

  final bool selected;
  final String title;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadii.cardAll,
              color: selected ? AppColors.clay800 : null,
              border: Border.all(color: selected ? AppColors.clay400 : AppColors.clay800, width: 1.5),
            ),
            child: Row(children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.clay200),
              const SizedBox(width: AppSpace.md),
              Expanded(child: Text(title, style: AppText.subheading.copyWith(color: AppColors.white))),
              Text(price, style: AppText.bodyStrong.copyWith(color: AppColors.white)),
            ]),
          ),
        ),
      );
}
