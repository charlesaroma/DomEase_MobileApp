// ─── Zone Repository ──────────────────────────────────────────────
import 'package:domease/domain/models/zone.dart';

/// The household's zones, started from the admin's templates (FR-HM-1).
abstract interface class ZoneRepository {
  Future<List<Zone>> zones();
  Future<void> save(List<Zone> zones);
}
