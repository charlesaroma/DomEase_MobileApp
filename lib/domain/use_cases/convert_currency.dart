// ─── Convert Currency ─────────────────────────────────────────────
import 'package:domease/domain/models/currency.dart';

/// Through the US Dollar, with the server's fixed table (FR-CC-1, FR-CC-3).
double convert(double amount, Currency from, Currency to) => amount / from.perUsd * to.perUsd;
