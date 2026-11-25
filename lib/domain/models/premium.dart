// ─── Premium ──────────────────────────────────────────────────────

/// Every feature behind Premium (FR-MZ-2), with the line used to sell it.
enum PremiumFeature {
  houseHelp('House Help: vetting questionnaire and guides'),
  payroll('House help pay: salary, advances and payslips'),
  sharing('Household sharing for everyone at home'),
  allergies('Allergy profiles for each person'),
  occasions('Birthday, Christmas, Easter and Eid menus'),
  healthyPastry('Healthier pastry swaps'),
  dietary('Diabetic and PCOS friendly meal ideas'),
  favourites('Favourite meals'),
  trends('Eating trends'),
  budget('Budget insights'),
  autoPlan('Automatic weekly planning'),
  adFree('No ads');

  const PremiumFeature(this.label);
  final String label;
}

enum PremiumPlan { monthly, yearly }
