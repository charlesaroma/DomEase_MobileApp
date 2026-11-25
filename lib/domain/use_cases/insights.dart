// ─── Insights ─────────────────────────────────────────────────────
// The budget month, eating trends and house help pay, worked out the same
// way as the web app (src/ClientApp/lib/insights.js). Change one, change both.
import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';

/// A calendar month, for grouping trips and pay.
typedef Month = ({int year, int month});

Month monthOf(DateTime d) => (year: d.year, month: d.month);

bool _inMonth(DateTime d, Month m) => d.year == m.year && d.month == m.month;

const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

String monthName(Month m) => '${monthNames[m.month - 1]} ${m.year}';

// ── Budget ──

class BudgetMonth {
  const BudgetMonth({required this.spent, required this.trips, this.budget, this.left, this.perDay = 0, this.percent, this.vsEstimate, this.byMonth = const []});

  final int spent;
  final int trips;
  final int? budget;
  final int? left;
  final int perDay;
  final int? percent;

  /// Above zero: the market cost more than the list said, as a whole percent.
  final int? vsEstimate;

  /// The last six months, oldest first: (label, spent).
  final List<(String, int)> byMonth;
}

BudgetMonth budgetMonth(Budget b, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final m = monthOf(now);
  final mine = b.trips.where((t) => _inMonth(t.date, m));
  final spent = mine.fold(0, (n, t) => n + t.actual);
  final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day + 1;
  final left = b.monthly == null ? null : b.monthly! - spent;
  final priced = b.trips.where((t) => t.estimate > 0);
  final estimated = priced.fold(0, (n, t) => n + t.estimate);
  final actual = priced.fold(0, (n, t) => n + t.actual);
  return BudgetMonth(
    spent: spent,
    trips: mine.length,
    budget: b.monthly,
    left: left,
    perDay: left != null && left > 0 ? left ~/ daysLeft : 0,
    percent: b.monthly == null || b.monthly == 0 ? null : (spent * 100 / b.monthly!).round(),
    vsEstimate: estimated == 0 ? null : ((actual - estimated) * 100 / estimated).round(),
    byMonth: [
      for (var i = 5; i >= 0; i--)
        (
          monthNames[DateTime(now.year, now.month - i).month - 1].substring(0, 3),
          b.trips.where((t) => _inMonth(t.date, monthOf(DateTime(now.year, now.month - i)))).fold(0, (n, t) => n + t.actual),
        ),
    ],
  );
}

// ── Eating trends ──

class EatingTrends {
  const EatingTrends({required this.weeks, required this.different, required this.variety, required this.vegForward, required this.top, required this.onRepeat});

  final int weeks;
  final int different;
  final int variety;
  final int vegForward;

  /// Most planned lunches and dinners: (recipe, times).
  final List<(Recipe, int)> top;
  final List<Recipe> onRepeat;
}

/// From past weeks (oldest first) and this week. Lunches and dinners only for
/// the top list and repeats: breakfasts and snacks repeat by design.
EatingTrends eatingTrends({required List<MealPlan> history, required MealPlan current, required Map<String, Recipe> byId}) {
  final weeks = [...history, current];
  final recent = weeks.length > 8 ? weeks.sublist(weeks.length - 8) : weeks;
  List<String> ids(MealPlan p) => [for (final l in p.days.values) ...l.where(byId.containsKey)];
  bool main(String id) => byId[id]!.mealType == MealType.lunch || byId[id]!.mealType == MealType.dinner;
  final all = recent.expand(ids).toList();
  final counts = <String, int>{};
  for (final id in all.where(main)) {
    counts[id] = (counts[id] ?? 0) + 1;
  }
  final top = (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5);
  final thisWeek = ids(current);
  final last4 = [for (final w in recent.skip(recent.length > 4 ? recent.length - 4 : 0)) ids(w).where(main).toSet()];
  final repeats = last4.length < 3 ? <String>[] : {for (final s in last4) ...s}.where((id) => last4.where((s) => s.contains(id)).length >= 3).take(6);
  return EatingTrends(
    weeks: recent.length,
    different: thisWeek.toSet().length,
    variety: thisWeek.isEmpty ? 0 : (thisWeek.toSet().length * 100 / thisWeek.length).round(),
    vegForward: all.isEmpty ? 0 : (all.where((id) => byId[id]!.vegForward).length * 100 / all.length).round(),
    top: [for (final e in top) (byId[e.key]!, e.value)],
    onRepeat: [for (final id in repeats) byId[id]!],
  );
}

// ── House help pay ──

class PayMonth {
  const PayMonth({required this.month, required this.salary, required this.bonus, required this.advances, required this.deductions, required this.paid, required this.daysOff, required this.entries});

  final Month month;
  final int salary;
  final int bonus;
  final int advances;
  final int deductions;
  final int paid;
  final int daysOff;

  /// Newest first.
  final List<PayEntry> entries;

  /// Below zero: paid ahead.
  int get owed => salary + bonus - advances - deductions - paid;
}

PayMonth payMonth(Staff s, {Month? month}) {
  final m = month ?? monthOf(DateTime.now());
  final rows = s.entries.where((e) => _inMonth(e.date, m)).toList()..sort((a, b) => b.date.compareTo(a.date));
  int of(PayKind k) => rows.where((e) => e.kind == k).fold(0, (n, e) => n + e.amount);
  return PayMonth(
    month: m,
    salary: s.salary,
    bonus: of(PayKind.bonus),
    advances: of(PayKind.advance),
    deductions: of(PayKind.deduction),
    paid: of(PayKind.pay),
    daysOff: rows.where((e) => e.kind == PayKind.leave).fold(0, (n, e) => n + e.days),
    entries: rows,
  );
}

/// The next payday on or after [today].
DateTime nextPayday(Staff s, {DateTime? today}) {
  final now = today ?? DateTime.now();
  DateTime on(int y, int m) => DateTime(y, m, s.payday.clamp(1, DateTime(y, m + 1, 0).day));
  final start = DateTime(now.year, now.month, now.day);
  final here = on(now.year, now.month);
  return here.isBefore(start) ? on(now.year, now.month + 1) : here;
}

int daysOffThisYear(Staff s, {DateTime? today}) {
  final year = (today ?? DateTime.now()).year;
  return s.entries.where((e) => e.kind == PayKind.leave && e.date.year == year).fold(0, (n, e) => n + e.days);
}

/// A plain text payslip to send on WhatsApp. [money] formats an amount.
String payslipText({required Staff staff, required PayMonth month, required String home, required String Function(int) money}) => [
      'Payslip, ${monthName(month.month)}',
      '${staff.name}, ${staff.role}',
      home,
      '',
      'Salary: ${money(month.salary)}',
      if (month.bonus > 0) 'Bonus: ${money(month.bonus)}',
      if (month.advances > 0) 'Advances: minus ${money(month.advances)}',
      if (month.deductions > 0) 'Deductions: minus ${money(month.deductions)}',
      'Paid: ${money(month.paid)}',
      month.owed >= 0 ? 'Still to pay: ${money(month.owed)}' : 'Paid ahead: ${money(-month.owed)}',
      if (month.daysOff > 0) 'Days off: ${month.daysOff}',
      '',
      'Kept with DomEase',
    ].join('\n');
