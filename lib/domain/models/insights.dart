// ─── Insights Models ──────────────────────────────────────────────
// Premium's records over time: market trips against a food budget, and the
// pay record for whoever helps at home. Amounts are in the household's own
// currency (docs/04-api-contract.md, Trip and Staff).

/// One market trip, saved from Done shopping on Shop.
class Trip {
  const Trip({required this.id, required this.date, required this.estimate, required this.actual, required this.items});

  final String id;
  final DateTime date;

  /// What the ticked items came to on the price table.
  final int estimate;

  /// What was really paid.
  final int actual;
  final int items;
}

class Budget {
  const Budget({this.monthly, this.trips = const []});

  /// The monthly food budget, or null if none is set.
  final int? monthly;

  /// Newest first.
  final List<Trip> trips;

  Budget copyWith({int? Function()? monthly, List<Trip>? trips}) => Budget(monthly: monthly == null ? this.monthly : monthly(), trips: trips ?? this.trips);
}

enum PayKind {
  pay('Salary paid'),
  advance('Advance'),
  deduction('Deduction'),
  bonus('Bonus'),
  leave('Days off');

  const PayKind(this.label);
  final String label;
}

/// One line in the pay record: money for every kind but leave, days for leave.
class PayEntry {
  const PayEntry({required this.id, required this.date, required this.kind, this.amount = 0, this.days = 0, this.note = ''});

  final String id;
  final DateTime date;
  final PayKind kind;
  final int amount;
  final int days;
  final String note;
}

/// Someone who helps at home, and their pay.
class Staff {
  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.salary,
    required this.payday,
    required this.startedOn,
    this.entries = const [],
  });

  final String id;
  final String name;
  final String role;
  final int salary;

  /// Day of the month, 1 to 31; later than a month's last day means its last day.
  final int payday;
  final DateTime startedOn;
  final List<PayEntry> entries;

  Staff copyWith({String? name, String? role, int? salary, int? payday, List<PayEntry>? entries}) => Staff(
        id: id,
        name: name ?? this.name,
        role: role ?? this.role,
        salary: salary ?? this.salary,
        payday: payday ?? this.payday,
        startedOn: startedOn,
        entries: entries ?? this.entries,
      );
}

const staffRoles = ['House help', 'Nanny', 'Cook', 'Driver', 'Gardener', 'Askari'];
