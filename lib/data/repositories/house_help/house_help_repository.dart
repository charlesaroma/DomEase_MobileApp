// ─── House Help Repository ────────────────────────────────────────
import 'package:domease/domain/models/house_help.dart';

/// The Premium vetting questionnaire and guides (PRD section 12).
abstract interface class HouseHelpRepository {
  Future<List<VettingQuestion>> questions();
  Future<List<Guide>> guides();

  /// The fit score is worked out by the server (FR-HH-4).
  Future<VettingResult> score(Map<String, int> answers);
}
