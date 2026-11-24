// ─── JSON Helpers ─────────────────────────────────────────────────
// Small readers shared by the mappers, so one missing field never crashes a screen.
typedef Json = Map<String, dynamic>;

List<String> strings(Object? v) => [for (final e in (v as List?) ?? const []) e.toString()];

double toDouble(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : double.tryParse('$v') ?? fallback;

int? toIntOrNull(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

T byName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
