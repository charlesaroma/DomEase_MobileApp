// ─── Insights JSON ────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/insights.dart';

DateTime _date(Object? v) => DateTime.tryParse('${v ?? ''}')?.toLocal() ?? DateTime.now();

Budget budgetFromJson(Json j) => Budget(
      monthly: toIntOrNull(j['monthly']),
      trips: [
        for (final t in (j['trips'] as List?) ?? const [])
          Trip(
            id: (t as Json)['id'] as String,
            date: _date(t['date']),
            estimate: toIntOrNull(t['estimate']) ?? 0,
            actual: toIntOrNull(t['actual']) ?? 0,
            items: toIntOrNull(t['items']) ?? 0,
          ),
      ],
    );

Json budgetToJson(Budget b) => {
      'monthly': b.monthly,
      'trips': [
        for (final t in b.trips) {'id': t.id, 'date': t.date.toUtc().toIso8601String(), 'estimate': t.estimate, 'actual': t.actual, 'items': t.items},
      ],
    };

Staff staffFromJson(Json j) => Staff(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? '',
      role: (j['role'] as String?) ?? staffRoles.first,
      salary: toIntOrNull(j['salary']) ?? 0,
      payday: toIntOrNull(j['payday']) ?? 28,
      startedOn: _date(j['startedOn']),
      entries: [
        for (final e in (j['entries'] as List?) ?? const [])
          PayEntry(
            id: (e as Json)['id'] as String,
            date: _date(e['date']),
            kind: byName(PayKind.values, e['kind'], PayKind.pay),
            amount: toIntOrNull(e['amount']) ?? 0,
            days: toIntOrNull(e['days']) ?? 0,
            note: (e['note'] as String?) ?? '',
          ),
      ],
    );

Json staffToJson(Staff s) => {
      'id': s.id,
      'name': s.name,
      'role': s.role,
      'salary': s.salary,
      'payday': s.payday,
      'startedOn': s.startedOn.toUtc().toIso8601String(),
      'entries': [
        for (final e in s.entries)
          {
            'id': e.id,
            'date': e.date.toUtc().toIso8601String(),
            'kind': e.kind.name,
            if (e.kind == PayKind.leave) 'days': e.days else 'amount': e.amount,
            'note': e.note,
          },
      ],
    };
