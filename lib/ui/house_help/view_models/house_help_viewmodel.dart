// ─── House Help View Models ───────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/house_help.dart';

final vettingQuestionsProvider = FutureProvider<List<VettingQuestion>>((ref) => ref.watch(houseHelpRepositoryProvider).questions());

final guidesProvider = FutureProvider<List<Guide>>((ref) => ref.watch(houseHelpRepositoryProvider).guides());

class VettingState {
  const VettingState({this.candidate = '', this.answers = const {}, this.result});

  final String candidate;

  /// Question id to the chosen option's index.
  final Map<String, int> answers;
  final VettingResult? result;
}

final vettingProvider = NotifierProvider<VettingNotifier, VettingState>(VettingNotifier.new);

class VettingNotifier extends Notifier<VettingState> {
  @override
  VettingState build() => const VettingState();

  void name(String candidate) => state = VettingState(candidate: candidate, answers: state.answers);

  void answer(String questionId, int option) =>
      state = VettingState(candidate: state.candidate, answers: {...state.answers, questionId: option});

  Future<void> score() async {
    final result = await ref.read(houseHelpRepositoryProvider).score(state.answers);
    state = VettingState(candidate: state.candidate, answers: state.answers, result: result);
  }

  void restart() => state = const VettingState();
}
