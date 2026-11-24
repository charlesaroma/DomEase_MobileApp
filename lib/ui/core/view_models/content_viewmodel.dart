// ─── Content View Models ──────────────────────────────────────────
// What the admin dashboard sets for everyone: nudges, settings and rates.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/content.dart';
import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/legal.dart';
import 'package:domease/domain/models/shopping.dart';

final nudgesProvider = FutureProvider<List<Nudge>>((ref) => ref.watch(contentRepositoryProvider).nudges());

final settingsProvider = FutureProvider<AppSettings>((ref) => ref.watch(contentRepositoryProvider).settings());

final ratesProvider = FutureProvider<RateTable>((ref) => ref.watch(contentRepositoryProvider).rates());

final legalProvider = FutureProvider.family<LegalDoc, LegalDocId>((ref, id) => ref.watch(contentRepositoryProvider).legal(id));

final pricesProvider = FutureProvider<List<MarketPrice>>((ref) => ref.watch(shoppingRepositoryProvider).prices());

/// Today's nudge: one a day, the same all day (FR-TD-3).
final nudgeOfTheDayProvider = FutureProvider<Nudge?>((ref) async {
  final nudges = await ref.watch(nudgesProvider.future);
  if (nudges.isEmpty) return null;
  final day = DateTime.now().difference(DateTime(2026)).inDays;
  return nudges[day % nudges.length];
});
