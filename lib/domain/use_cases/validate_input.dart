// ─── Validate Input ───────────────────────────────────────────────
// The rules every sign in form uses. Each returns null when the value is
// fine, or the sentence to show under the field.

String? checkName(String v) => v.trim().length < 2 ? 'Tell us what to call you.' : null;

String? checkEmail(String v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v.trim()) ? null : 'That email address does not look right.';

/// At least 8 characters with a letter and a number.
String? checkPassword(String v) {
  if (v.length < 8) return 'Use at least 8 characters.';
  if (!RegExp('[A-Za-z]').hasMatch(v) || !RegExp('[0-9]').hasMatch(v)) return 'Use letters and at least one number.';
  return null;
}

/// A country code and local number as one international number,
/// "+256 772 123 456" → "+256772123456". Drops a leading 0 ("0772…").
String? normalisePhone(String dialCode, String local) {
  final digits = local.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0'), '');
  if (digits.length < 7 || digits.length > 12) return null;
  return '$dialCode$digits';
}

/// Six digits, as texted.
bool isCode(String v) => RegExp(r'^\d{6}$').hasMatch(v);

/// "+256772123456" → "+256 772 123 456", for showing back to the person.
String prettyPhone(String e164) {
  final m = RegExp(r'^(\+\d{3})(\d{3})(\d{3})(\d+)$').firstMatch(e164);
  return m == null ? e164 : '${m[1]} ${m[2]} ${m[3]} ${m[4]}';
}
