// ─── Zone Repository (API) ────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/zone_json.dart';
import 'package:domease/data/repositories/zones/zone_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/domain/models/zone.dart';

class ZoneRepositoryRemote implements ZoneRepository {
  ZoneRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<List<Zone>> zones() async => [for (final j in await _api.get('/households/me/zones') as List) zoneFromJson(j as Json)];

  @override
  Future<void> save(List<Zone> zones) => _api.put('/households/me/zones', [for (final z in zones) zoneToJson(z)]);
}
