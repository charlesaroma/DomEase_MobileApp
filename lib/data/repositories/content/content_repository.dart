// ─── Content Repository ───────────────────────────────────────────
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/legal.dart';

/// What the admin dashboard sets for every household: nudges, settings, rates.
abstract interface class ContentRepository {
  Future<List<Nudge>> nudges();
  Future<AppSettings> settings();
  Future<RateTable> rates();

  Future<LegalDoc> legal(LegalDocId id);

  /// A problem or an idea from Help, read by the team in the admin dashboard.
  Future<void> sendReport({required String topic, required String message, required String appVersion});
}
