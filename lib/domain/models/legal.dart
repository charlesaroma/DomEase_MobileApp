// ─── Legal ────────────────────────────────────────────────────────
// The Terms, Privacy Policy, Premium terms and the health notice. Served by
// the API so they can be updated without an app release; a copy ships in
// the app (assets/legal/) for a first launch with no connection.

enum LegalDocId {
  terms('Terms of Use'),
  privacy('Privacy Policy'),
  premium('Premium and payments'),
  health('Health and dietary notice');

  const LegalDocId(this.title);
  final String title;
}

class LegalSection {
  const LegalSection({required this.heading, required this.paragraphs});

  final String heading;
  final List<String> paragraphs;
}

class LegalDoc {
  const LegalDoc({required this.id, required this.title, required this.updated, required this.summary, required this.sections});

  final LegalDocId id;
  final String title;

  /// When it last changed, as the API sends it (2026-10-30).
  final DateTime updated;

  /// A plain words version at the top, before the detail.
  final String summary;
  final List<LegalSection> sections;
}
