// ─── Vetting Flow ─────────────────────────────────────────────────
// The questionnaire one section at a time, then the fit score and the
// flagged answers (FR-HH-3, FR-HH-4).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/house_help.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/progress_row.dart';
import 'package:domease/ui/house_help/view_models/house_help_viewmodel.dart';

class VettingFlow extends ConsumerWidget {
  const VettingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(vettingQuestionsProvider);
    final state = ref.watch(vettingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(state.result == null ? 'Vet a candidate' : 'Fit score')),
      body: AsyncView(
        value: questions,
        data: (qs) => state.result == null ? _Questions(questions: qs, state: state) : _Result(result: state.result!, name: state.candidate),
      ),
    );
  }
}

class _Questions extends ConsumerWidget {
  const _Questions({required this.questions, required this.state});

  final List<VettingQuestion> questions;
  final VettingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final flow = ref.read(vettingProvider.notifier);
    final done = questions.every((q) => state.answers.containsKey(q.id));
    return ListView(
      padding: const EdgeInsets.all(AppSpace.screen),
      children: [
        TextFormField(
          initialValue: state.candidate,
          onChanged: flow.name,
          decoration: const InputDecoration(labelText: 'Candidate', hintText: 'A name or a note, for you only'),
        ),
        for (var n = 0; n < questions.length; n++) ...[
          // A heading wherever a new section starts.
          if (n == 0 || questions[n - 1].section != questions[n].section)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xxl, bottom: AppSpace.sm),
              child: Text(questions[n].section.toUpperCase(), style: AppText.eyebrow.copyWith(color: scheme.primary)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md, bottom: AppSpace.sm),
            child: Text(questions[n].text, style: AppText.bodyStrong.copyWith(color: scheme.onSurface)),
          ),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            for (var i = 0; i < questions[n].options.length; i++)
              ChoiceChip(
                label: Text(questions[n].options[i].label),
                selected: state.answers[questions[n].id] == i,
                onSelected: (_) => flow.answer(questions[n].id, i),
              ),
          ]),
        ],
        const SizedBox(height: AppSpace.xxl),
        FilledButton(onPressed: done ? flow.score : null, child: Text(done ? 'See the fit score' : 'Answer every question')),
        const SizedBox(height: AppSpace.huge),
      ],
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.result, required this.name});

  final VettingResult result;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpace.screen),
      children: [
        Text(name.isEmpty ? 'This candidate' : name, style: Theme.of(context).textTheme.bodySmall),
        Text('${result.percent}%', style: AppText.display.copyWith(color: scheme.primary, fontSize: 64)),
        Text('fit for your household', style: AppText.lead.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        const SizedBox(height: AppSpace.xxl),
        for (final e in result.bySection.entries) ProgressRow(label: e.key, done: e.value, of: 100),
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: AppSpace.lg),
          Text('Worth a second conversation', style: AppText.subheading.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpace.sm),
          for (final f in result.flags)
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.flag_outlined, color: scheme.primary), title: Text(f)),
        ],
        const SizedBox(height: AppSpace.xxl),
        OutlinedButton(onPressed: ref.read(vettingProvider.notifier).restart, child: const Text('Vet another candidate')),
      ],
    );
  }
}
