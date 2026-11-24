// ─── Report Sheet ─────────────────────────────────────────────────
// A problem or an idea, in the household's own words. The app version goes
// with it so the team can tell which release it came from.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/help/view_models/help_viewmodel.dart';

enum ReportTopic {
  problem('Report a problem', 'What happened, and what were you trying to do?'),
  idea('Share an idea', 'What would make DomEase better for your home?');

  const ReportTopic(this.title, this.prompt);
  final String title;
  final String prompt;
}

Future<void> showReportSheet(BuildContext context, {required ReportTopic topic}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (_) => _Report(topic: topic),
    );

class _Report extends ConsumerStatefulWidget {
  const _Report({required this.topic});

  final ReportTopic topic;

  @override
  ConsumerState<_Report> createState() => _ReportState();
}

class _ReportState extends ConsumerState<_Report> {
  final _text = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_text.text.trim().length < 10) {
      setState(() => _error = 'Tell us a little more so we can help.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sendReportProvider)(widget.topic.name, _text.text.trim());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Thank you. The DomEase team has it.')));
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpace.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(widget.topic.title, style: AppText.heading.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpace.lg),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: widget.topic.prompt, alignLabelWithHint: true),
          ),
          if (ref.watch(flavorProvider).useDemoData)
            Text('Demo: nothing is sent.', style: Theme.of(context).textTheme.bodySmall),
          AuthError(_error),
          const SizedBox(height: AppSpace.lg),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _busy ? null : _send, child: Text(_busy ? 'Sending' : 'Send'))),
        ]),
      );
}
