// ─── Convert View Model ───────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/view_models/household_viewmodel.dart';

class ConvertState {
  const ConvertState({required this.amount, required this.from, required this.to});

  final double amount;
  final String from;
  final String to;

  ConvertState copyWith({double? amount, String? from, String? to}) =>
      ConvertState(amount: amount ?? this.amount, from: from ?? this.from, to: to ?? this.to);
}

final convertProvider = NotifierProvider<ConvertNotifier, ConvertState>(ConvertNotifier.new);

/// From defaults to the household's currency (FR-CC-2).
class ConvertNotifier extends Notifier<ConvertState> {
  @override
  ConvertState build() {
    final home = ref.watch(householdProvider).value?.currency ?? 'UGX';
    return ConvertState(amount: 10000, from: home, to: home == 'USD' ? 'UGX' : 'USD');
  }

  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setFrom(String code) => state = state.copyWith(from: code);
  void setTo(String code) => state = state.copyWith(to: code);
  void swap() => state = ConvertState(amount: state.amount, from: state.to, to: state.from);
}
