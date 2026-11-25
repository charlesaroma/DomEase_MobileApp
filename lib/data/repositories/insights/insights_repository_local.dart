// ─── Insights Repository (demo) ───────────────────────────────────
// Kept on the phone. The first read gives the demo home some history, as on
// the web demo: twelve weeks of market trips and Grace's pay record.
import 'package:domease/data/model/insights_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/insights/insights_repository.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/insights.dart';

class InsightsRepositoryLocal implements InsightsRepository {
  InsightsRepositoryLocal(this._store);

  final PrefsStore _store;

  @override
  Future<Budget> budget() async {
    final json = await _store.read('budget');
    return json == null ? _demoBudget() : budgetFromJson(json as Json);
  }

  @override
  Future<void> saveBudget(Budget budget) => _store.write('budget', budgetToJson(budget));

  @override
  Future<List<Staff>> staff() async {
    final json = await _store.read('staff');
    return json == null ? _demoStaff() : [for (final j in json as List) staffFromJson(j as Json)];
  }

  @override
  Future<void> saveStaff(List<Staff> staff) => _store.write('staff', [for (final s in staff) staffToJson(s)]);
}

Budget _demoBudget() {
  final now = DateTime.now();
  return Budget(monthly: 650000, trips: [
    for (var i = 0; i < 12; i++)
      () {
        final estimate = 118000 + ((i * 7919) % 41) * 1000;
        return Trip(
          id: 'trip_demo_$i',
          date: now.subtract(Duration(days: i * 7 + 2)),
          estimate: estimate,
          actual: (estimate * (94 + (i * 37) % 17) / 100 / 500).round() * 500,
          items: 14 + i % 6,
        );
      }(),
  ]);
}

List<Staff> _demoStaff() {
  final now = DateTime.now();
  DateTime on(int monthsAgo, int day) => DateTime(now.year, now.month - monthsAgo, day, 10);
  return [
    Staff(id: 'staff_demo', name: 'Grace', role: 'House help', salary: 250000, payday: 28, startedOn: on(8, 1), entries: [
      PayEntry(id: 'pay_demo_1', date: on(2, 28), kind: PayKind.pay, amount: 250000),
      PayEntry(id: 'pay_demo_2', date: on(1, 12), kind: PayKind.leave, days: 2, note: 'Visiting family in Masaka'),
      PayEntry(id: 'pay_demo_3', date: on(1, 18), kind: PayKind.advance, amount: 40000, note: 'School fees'),
      PayEntry(id: 'pay_demo_4', date: on(1, 28), kind: PayKind.pay, amount: 210000),
      PayEntry(id: 'pay_demo_5', date: on(0, 6), kind: PayKind.advance, amount: 50000, note: 'Transport home'),
    ]),
  ];
}
