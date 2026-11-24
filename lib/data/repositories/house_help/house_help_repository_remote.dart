// ─── House Help Repository (API) ──────────────────────────────────
import 'package:domease/data/model/content_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/house_help/house_help_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/domain/models/house_help.dart';

class HouseHelpRepositoryRemote implements HouseHelpRepository {
  HouseHelpRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<List<VettingQuestion>> questions() async =>
      [for (final j in await _api.get('/house-help/questions') as List) questionFromJson(j as Json)];

  @override
  Future<List<Guide>> guides() async => [for (final j in await _api.get('/house-help/guides') as List) guideFromJson(j as Json)];

  @override
  Future<VettingResult> score(Map<String, int> answers) async =>
      resultFromJson(await _api.post('/house-help/score', {'answers': answers}) as Json);
}
