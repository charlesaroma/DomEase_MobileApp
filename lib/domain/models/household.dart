// ─── Household ────────────────────────────────────────────────────
// The home the app is set up for: who lives there, which currency they shop
// in, and their plan. Captured once at onboarding (FR-ON-1 to FR-ON-5).

enum HouseholdType {
  bachelor('Just me'),
  couple('Me and my partner'),
  family('Family with kids'),
  singleParent('Single parent');

  const HouseholdType(this.label);
  final String label;

  /// A sensible starting size, still editable (FR-ON-3).
  int get defaultSize => switch (this) {
        HouseholdType.bachelor => 1,
        HouseholdType.couple => 2,
        HouseholdType.family => 4,
        HouseholdType.singleParent => 3,
      };
}

enum MemberRole { owner, member, houseHelp }

enum AgeGroup {
  kids('Kids'),
  adults('Adults'),
  elderly('Elders');

  const AgeGroup(this.label);
  final String label;
}

enum Tier { free, premium }

class HouseholdMember {
  const HouseholdMember({
    required this.id,
    required this.name,
    this.role = MemberRole.member,
    this.ageGroup = AgeGroup.adults,
    this.allergies = const [],
  });

  final String id;
  final String name;
  final MemberRole role;
  final AgeGroup ageGroup;

  /// Premium only (FR-MZ-2); empty on the free plan.
  final List<String> allergies;
}

class Household {
  const Household({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.currency,
    this.tier = Tier.free,
    this.members = const [],
    this.goals = const [],
    this.mealFocus = const [],
    this.diet = 'none',
  });

  final String id;
  final String name;
  final HouseholdType type;

  /// How many people eat at home; recipes scale to it (FR-MP-3).
  final int size;

  /// ISO code, UGX by default (FR-ON-2).
  final String currency;
  final Tier tier;
  final List<HouseholdMember> members;

  /// What they said would make the week easier, from onboarding.
  final List<String> goals;

  /// The meal types they want help with first.
  final List<String> mealFocus;
  final String diet;

  bool get isPremium => tier == Tier.premium;

  /// Every allergy anyone at home has, for filtering suggestions (Premium).
  Set<String> get allergies => {for (final m in members) ...m.allergies.map((a) => a.toLowerCase())};

  Household copyWith({
    String? name,
    HouseholdType? type,
    int? size,
    String? currency,
    Tier? tier,
    List<HouseholdMember>? members,
    List<String>? goals,
    List<String>? mealFocus,
    String? diet,
  }) =>
      Household(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        size: size ?? this.size,
        currency: currency ?? this.currency,
        tier: tier ?? this.tier,
        members: members ?? this.members,
        goals: goals ?? this.goals,
        mealFocus: mealFocus ?? this.mealFocus,
        diet: diet ?? this.diet,
      );
}
