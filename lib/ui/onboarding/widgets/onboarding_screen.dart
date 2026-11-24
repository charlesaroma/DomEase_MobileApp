// ─── Set Up Your Home ─────────────────────────────────────────────
// The questions for a new home, once the account exists. One question per
// screen under a progress bar, Continue pinned at the bottom and asleep until
// there is an answer. It ends on "your home is ready" (the household is
// saved there) and a gentle Premium offer that is easy to skip.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/ink_button.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';
import 'package:domease/ui/onboarding/widgets/onboarding_steps.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingProvider);
    final flow = ref.read(onboardingProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final first = draft.step == OnboardingStep.who;
    final last = draft.step == OnboardingStep.premium;

    // The Premium offer only makes sense once the home is saved; if it is
    // gone (signed out, set up again), start the questions over.
    if (last && ref.watch(householdProvider).value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.invalidate(onboardingProvider));
    }

    void back() {
      if (first) {
        if (context.canPop()) context.pop();
      } else {
        flow.back();
      }
    }

    Future<void> onContinue() async {
      switch (draft.step) {
        case OnboardingStep.ready:
          try {
            await flow.finish();
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your home could not be saved just now. Please try again.')),
              );
            }
          }
        case OnboardingStep.premium:
          context.go(Routes.today);
        default:
          flow.next();
      }
    }

    return PopScope(
      canPop: first,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !last) flow.back();
      },
      child: Scaffold(
        body: ReadableWidth(child: SafeArea(
          child: Column(
            children: [
              // ── Progress ──
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.sm, AppSpace.screen, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: last ? null : back, icon: const Icon(Icons.chevron_left), tooltip: 'Back'),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadii.pillAll,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: draft.progress),
                          duration: AppDurations.base,
                          builder: (context, v, _) => LinearProgressIndicator(
                            value: v,
                            minHeight: 8,
                            backgroundColor: scheme.brightness == Brightness.dark ? AppColors.nightLine : AppColors.clay100,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── The question ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.base,
                  child: SingleChildScrollView(
                    key: ValueKey(draft.step),
                    padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xxl, AppSpace.screen, AppSpace.xxl),
                    child: StepBody(draft: draft),
                  ),
                ),
              ),

              // ── Continue ──
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.lg),
                child: Column(
                  children: [
                    InkButton(
                      label: switch (draft.step) {
                        OnboardingStep.ready => "I'm ready",
                        OnboardingStep.premium => 'Start free',
                        _ => 'Continue',
                      },
                      amber: last,
                      busy: draft.saving,
                      onPressed: draft.canContinue ? onContinue : null,
                    ),
                    if (last)
                      TextButton(
                        onPressed: () {
                          context.go(Routes.today);
                          context.push(Routes.premium);
                        },
                        child: const Text('See Premium plans'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
