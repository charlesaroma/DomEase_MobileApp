// ─── Onboarding View Model ────────────────────────────────────────
// The questions that set up a new home, after the account exists. One
// question per screen, answers kept here until the household is saved at
// the end (FR-ON-1 to FR-ON-5). Nothing here scores or judges the home:
// no "hours lost" figure, no peace score (FR-ON-6).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

enum OnboardingStep { who, size, mood, goals, meals, currency, diet, ready, premium }

class OnboardingDraft {
  const OnboardingDraft({
    this.step = OnboardingStep.who,
    this.type,
    this.size = 1,
    this.mood,
    this.goals = const {},
    this.mealFocus = const {},
    this.currency = 'UGX',
    this.diet = 'none',
    this.saving = false,
  });

  final OnboardingStep step;
  final HouseholdType? type;
  final int size;
  final String? mood;
  final Set<String> goals;
  final Set<String> mealFocus;
  final String currency;
  final String diet;
  final bool saving;

  /// Continue wakes up once the question has an answer.
  bool get canContinue => switch (step) {
        OnboardingStep.who => type != null,
        OnboardingStep.mood => mood != null,
        OnboardingStep.goals => goals.isNotEmpty,
        OnboardingStep.meals => mealFocus.isNotEmpty,
        _ => !saving,
      };

  double get progress => (step.index + 1) / OnboardingStep.values.length;

  OnboardingDraft copyWith({
    OnboardingStep? step,
    HouseholdType? type,
    int? size,
    String? mood,
    Set<String>? goals,
    Set<String>? mealFocus,
    String? currency,
    String? diet,
    bool? saving,
  }) =>
      OnboardingDraft(
        step: step ?? this.step,
        type: type ?? this.type,
        size: size ?? this.size,
        mood: mood ?? this.mood,
        goals: goals ?? this.goals,
        mealFocus: mealFocus ?? this.mealFocus,
        currency: currency ?? this.currency,
        diet: diet ?? this.diet,
        saving: saving ?? this.saving,
      );
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingDraft>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void next() {
    final i = state.step.index;
    if (i < OnboardingStep.values.length - 1) state = state.copyWith(step: OnboardingStep.values[i + 1]);
  }

  void back() {
    final i = state.step.index;
    if (i > 0) state = state.copyWith(step: OnboardingStep.values[i - 1]);
  }

  /// Choosing who lives at home also sets a sensible size (FR-ON-3).
  void type(HouseholdType t) => state = state.copyWith(type: t, size: t.defaultSize);
  void size(int n) => state = state.copyWith(size: n.clamp(1, 20));
  void mood(String m) => state = state.copyWith(mood: m);
  void currency(String c) => state = state.copyWith(currency: c);
  void diet(String d) => state = state.copyWith(diet: d);

  void toggleGoal(String g) => state = state.copyWith(goals: _toggle(state.goals, g));
  void toggleMeal(String m) => state = state.copyWith(mealFocus: _toggle(state.mealFocus, m));

  Set<String> _toggle(Set<String> s, String v) => s.contains(v) ? ({...s}..remove(v)) : {...s, v};

  /// Save the household and move on to the Premium offer (FR-ON-5).
  Future<void> finish() async {
    state = state.copyWith(saving: true);
    final d = state;
    final me = ref.read(sessionProvider).value;
    final firstName = (me?.name ?? '').trim().split(' ').first;
    try {
      await ref.read(householdProvider.notifier).save(Household(
            id: 'hh_${DateTime.now().millisecondsSinceEpoch}',
            name: firstName.isEmpty ? 'Our home' : "$firstName's home",
            type: d.type ?? HouseholdType.family,
            size: d.size,
            currency: d.currency,
            members: [HouseholdMember(id: me?.userId ?? 'me', name: firstName.isEmpty ? 'You' : firstName, role: MemberRole.owner)],
            goals: d.goals.toList(),
            mealFocus: d.mealFocus.toList(),
            diet: d.diet,
          ));
    } catch (_) {
      state = state.copyWith(saving: false);
      rethrow;
    }
    state = state.copyWith(saving: false, step: OnboardingStep.premium);
  }
}
