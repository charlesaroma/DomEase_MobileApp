// ─── House Help ───────────────────────────────────────────────────
// The Premium vetting questionnaire and guides (PRD section 12).

class VettingOption {
  const VettingOption({required this.label, required this.weight});

  final String label;

  /// 0 to 3; 1 or less is flagged (FR-HH-4).
  final int weight;
}

class VettingQuestion {
  const VettingQuestion({required this.id, required this.section, required this.text, required this.options});

  final String id;
  final String section;
  final String text;
  final List<VettingOption> options;
}

class VettingResult {
  const VettingResult({required this.percent, required this.flags, required this.bySection});

  /// The fit score, 0 to 100.
  final int percent;

  /// Questions answered with a weight of 1 or less, worth a second conversation.
  final List<String> flags;
  final Map<String, int> bySection;
}

class Guide {
  const Guide({required this.id, required this.title, required this.summary, required this.pages, required this.fileUrl});

  final String id;
  final String title;
  final String summary;
  final int pages;
  final String fileUrl;
}
