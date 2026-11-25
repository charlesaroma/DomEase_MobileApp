// ─── Insights Repository (API) ────────────────────────────────────
import 'package:domease/data/model/insights_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/insights/insights_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/domain/models/insights.dart';

class InsightsRepositoryRemote implements InsightsRepository {
  InsightsRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<Budget> budget() async => budgetFromJson(await _api.get('/households/me/budget') as Json);

  @override
  Future<void> saveBudget(Budget budget) => _api.put('/households/me/budget', budgetToJson(budget));

  @override
  Future<List<Staff>> staff() async => [for (final j in await _api.get('/households/me/staff') as List) staffFromJson(j as Json)];

  @override
  Future<void> saveStaff(List<Staff> staff) => _api.put('/households/me/staff', [for (final s in staff) staffToJson(s)]);
}
