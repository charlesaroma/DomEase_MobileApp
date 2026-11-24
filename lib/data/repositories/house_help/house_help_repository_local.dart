// ─── House Help Repository (demo) ─────────────────────────────────
import 'package:domease/data/model/content_json.dart';
import 'package:domease/data/repositories/house_help/house_help_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/domain/models/house_help.dart';
import 'package:domease/domain/use_cases/score_candidate.dart';

/// Scores on the phone with the same rule the server uses.
class HouseHelpRepositoryLocal implements HouseHelpRepository {
  List<VettingQuestion>? _questions;

  @override
  Future<List<VettingQuestion>> questions() async =>
      _questions ??= [for (final j in await loadDemoList('vetting_questions')) questionFromJson(j)];

  @override
  Future<List<Guide>> guides() async => [for (final j in await loadDemoList('house_help_guides')) guideFromJson(j)];

  @override
  Future<VettingResult> score(Map<String, int> answers) async => scoreCandidate(await questions(), answers);
}
