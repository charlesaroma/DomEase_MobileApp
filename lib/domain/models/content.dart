// ─── App Content ──────────────────────────────────────────────────
// What the admin dashboard controls besides recipes.

/// A light, rotating tip on Today (FR-TD-3).
class Nudge {
  const Nudge({required this.id, required this.text});

  final String id;
  final String text;
}

/// A question in You → Help, managed in the admin.
class Faq {
  const Faq({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// A line on the Premium screen. [comingSoon] features are listed as such.
class PremiumFeatureInfo {
  const PremiumFeatureInfo({required this.id, required this.title, required this.description, this.comingSoon = false});

  final String id;
  final String title;
  final String description;
  final bool comingSoon;
}

/// A special occasion menu (FR-MP-9): Birthday, Christmas, Easter, Eid.
class Occasion {
  const Occasion({required this.id, required this.name});

  final String id;
  final String name;
}

/// Where an ad may appear (admin → Ads → Placements). Never full screen (FR-AD-2).
class AdPlacement {
  const AdPlacement({required this.id, required this.enabled, this.native = false, this.admobAndroid = '', this.admobIos = ''});

  final String id;
  final bool enabled;
  final bool native;
  final String admobAndroid;
  final String admobIos;
}

/// A product a brand pays DomEase for directly; shown before any AdMob ad.
class SponsoredDeal {
  const SponsoredDeal({
    required this.id,
    required this.brand,
    required this.product,
    required this.link,
    required this.screens,
    this.headline = '',
    this.imageUrl,
    this.matchItems = const [],
  });

  final String id;
  final String brand;
  final String product;
  final String headline;
  final String link;
  final String? imageUrl;
  final List<String> screens;

  /// On Shop, shown only beside these items; empty means any list.
  final List<String> matchItems;
}

class AppSettings {
  const AppSettings({
    required this.ads,
    required this.dietaryDisclaimer,
    required this.supportEmail,
    this.monthlyPrice,
    this.yearlyPrice,
    this.placements = const [],
    this.sponsored = const [],
    this.trialDays = 0,
    this.minAppVersion = '1.0.0',
    this.maintenance,
  });

  /// Premium prices in UGX; null until agreed.
  final int? monthlyPrice;
  final int? yearlyPrice;

  /// Ad placements switched on per screen for the free plan (FR-AD-2).
  final Map<String, bool> ads;

  /// Shown on every dietary suggestion, on every plan (FR-MP-12).
  final String dietaryDisclaimer;
  final String supportEmail;

  /// Per placement, with AdMob unit ids (newer servers). Takes over from [ads].
  final List<AdPlacement> placements;

  /// Sponsored products running now.
  final List<SponsoredDeal> sponsored;
  final int trialDays;

  /// Older apps are asked to update.
  final String minAppVersion;

  /// When set, the app shows this message instead of the household's screens.
  final String? maintenance;

  AdPlacement? placement(String screen) => placements.where((p) => p.id == screen).firstOrNull;

  bool adsOn(String screen) => placements.isEmpty ? (ads[screen] ?? false) : (placement(screen)?.enabled ?? false);

  /// The deal for this screen, if one is running (and matches the list on Shop).
  SponsoredDeal? dealFor(String screen, {List<String> items = const []}) {
    final names = [for (final i in items) i.toLowerCase()];
    return sponsored
        .where((d) => d.screens.contains(screen) && (d.matchItems.isEmpty || d.matchItems.any((m) => names.any((n) => n.contains(m)))))
        .firstOrNull;
  }
}
