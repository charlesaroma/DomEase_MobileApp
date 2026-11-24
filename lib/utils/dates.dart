// ─── Dates ────────────────────────────────────────────────────────

const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// "Thursday, 29 October".
String longDate(DateTime d) => '${weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// "30 October 2026", for documents.
String fullDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "29 Oct 2026".
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

/// The Monday of the week [d] falls in, used to seed a week's plan.
DateTime weekStart(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
