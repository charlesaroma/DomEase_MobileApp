// ─── Money ────────────────────────────────────────────────────────

/// "UGX 46,500". Whole units for shillings; two decimals for currencies that use them.
String money(num amount, [String currency = 'UGX']) {
  const whole = {'UGX', 'KES', 'TZS', 'NGN'};
  final fixed = whole.contains(currency) ? amount.round().toString() : amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts.first.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  return '$currency ${parts.length > 1 ? '$digits.${parts[1]}' : digits}';
}
