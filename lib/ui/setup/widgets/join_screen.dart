// ─── Join A Home ──────────────────────────────────────────────────
// Enter the invite code someone at home shared. A joiner lands straight on
// Today with that household's plan; there are no questions to answer.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/ink_button.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _ready => _code.text.trim().length >= 6;

  Future<void> _join() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final home = await ref.read(householdProvider.notifier).join(_code.text);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go(Routes.today);
      messenger.showSnackBar(SnackBar(content: Text('Welcome to ${home.name}.')));
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        bottom: InkButton(label: 'Join this home', busy: _busy, onPressed: _ready ? _join : null),
        children: [
          const AuthHeading('Join a ', 'home', '', lead: 'Enter the invite code from the person who set up DomEase where you live.'),
          TextField(
            controller: _code,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')), LengthLimitingTextInputFormatter(8)],
            style: AppText.title.copyWith(letterSpacing: 6, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _ready ? _join() : null,
            decoration: const InputDecoration(hintText: 'CODE'),
          ),
          const SizedBox(height: 12),
          Text('They can find it in DomEase under Household, then Invite someone.', style: Theme.of(context).textTheme.bodySmall),
          if (ref.watch(flavorProvider).useDemoData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Demo: the code DOM123 joins a sample family home.', style: Theme.of(context).textTheme.bodySmall),
            ),
          AuthError(_error),
        ],
      );
}
