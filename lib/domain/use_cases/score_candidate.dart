// ─── Score Candidate ──────────────────────────────────────────────
// The House Help fit score: each answer weighs 0 to 3; the score is the share
// of the best possible total, and any answer weighing 1 or less is flagged
// (FR-HH-4). The server is the source of truth in production; the demo
// repository uses this same rule, so both agree.
import 'package:domease/domain/models/house_help.dart';

VettingResult scoreCandidate(List<VettingQuestion> questions, Map<String, int> answers) {
  var total = 0;
  final flags = <String>[];
  final sections = <String, List<int>>{};
  for (final q in questions) {
    final i = answers[q.id];
    if (i == null || i < 0 || i >= q.options.length) continue;
    final w = q.options[i].weight;
    total += w;
    sections.putIfAbsent(q.section, () => []).add(w);
    if (w <= 1) flags.add(q.text);
  }
  final max = questions.length * 3;
  return VettingResult(
    percent: max == 0 ? 0 : (total * 100 / max).round(),
    flags: flags,
    bySection: {for (final e in sections.entries) e.key: (e.value.fold(0, (a, b) => a + b) * 100 / (e.value.length * 3)).round()},
  );
}
