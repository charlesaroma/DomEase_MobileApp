// ─── Insights Repository ──────────────────────────────────────────
import 'package:domease/domain/models/insights.dart';

/// The household's food budget with its market trips, and the pay record for
/// whoever helps at home. Both are saved whole, as the web app does.
abstract interface class InsightsRepository {
  Future<Budget> budget();
  Future<void> saveBudget(Budget budget);
  Future<List<Staff>> staff();
  Future<void> saveStaff(List<Staff> staff);
}
