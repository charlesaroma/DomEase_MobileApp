// ─── Zone Repository (demo) ───────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/zone_json.dart';
import 'package:domease/data/repositories/zones/zone_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/zone.dart';

/// Starts from assets/demo/zone_templates.json; changes stay on the phone.
class ZoneRepositoryLocal implements ZoneRepository {
  ZoneRepositoryLocal(this._store);

  final PrefsStore _store;

  @override
  Future<List<Zone>> zones() async {
    final saved = await _store.read('zones') as List?;
    final source = saved ?? await loadDemoList('zone_templates');
    return [for (final j in source) zoneFromJson(j as Json)];
  }

  @override
  Future<void> save(List<Zone> zones) => _store.write('zones', [for (final z in zones) zoneToJson(z)]);
}
