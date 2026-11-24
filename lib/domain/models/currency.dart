// ─── Currency ─────────────────────────────────────────────────────

class Currency {
  const Currency({required this.code, required this.name, required this.perUsd});

  final String code;
  final String name;

  /// Units of this currency to one US Dollar.
  final double perUsd;
}

/// The server's fixed rate table and when it was last set (FR-CC-3).
class RateTable {
  const RateTable({required this.rates, required this.updatedAt});

  final List<Currency> rates;
  final DateTime updatedAt;

  Currency? byCode(String code) {
    for (final c in rates) {
      if (c.code == code) return c;
    }
    return null;
  }
}
