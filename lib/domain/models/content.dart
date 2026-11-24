// ─── App Content ──────────────────────────────────────────────────
// What the admin dashboard controls besides recipes.

/// A light, rotating tip on Today (FR-TD-3).
class Nudge {
  const Nudge({required this.id, required this.text});

  final String id;
  final String text;
}

class AppSettings {
  const AppSettings({
    required this.ads,
    required this.dietaryDisclaimer,
    required this.supportEmail,
    this.monthlyPrice,
    this.yearlyPrice,
  });

  /// Premium prices in UGX; null until agreed.
  final int? monthlyPrice;
  final int? yearlyPrice;

  /// Ad placements switched on per screen for the free plan (FR-AD-2).
  final Map<String, bool> ads;

  /// Shown on every dietary suggestion, on every plan (FR-MP-12).
  final String dietaryDisclaimer;
  final String supportEmail;

  bool adsOn(String screen) => ads[screen] ?? false;
}
