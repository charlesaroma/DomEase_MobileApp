// ─── Account Actions ──────────────────────────────────────────────
// The careful ones: change password, leave a home, delete the account.
// Deleting says exactly what goes, asks for a deliberate tick, and only
// then shows the red button (Apple 5.1.1(v), Google Play account deletion).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/onboarding/view_models/onboarding_viewmodel.dart';

Future<void> showChangePassword(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (_) => const _ChangePassword(),
    );

class _ChangePassword extends ConsumerStatefulWidget {
  const _ChangePassword();

  @override
  ConsumerState<_ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<_ChangePassword> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  bool _show = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = checkPassword(_next.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).changePassword(_current.text, _next.text);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Password changed.')));
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
          Text('Change password', style: AppText.heading.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpace.lg),
          TextField(
            controller: _current,
            obscureText: !_show,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _next,
            obscureText: !_show,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'New password',
              helperText: 'At least 8 characters, with a letter and a number.',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _show = !_show),
                icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                tooltip: _show ? 'Hide passwords' : 'Show passwords',
              ),
            ),
          ),
          AuthError(_error),
          const SizedBox(height: AppSpace.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? 'Saving' : 'Change password')),
          ),
        ]),
      );
}

Future<bool> confirmLeave(BuildContext context, String home) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Leave $home?'),
        content: const Text('You will stop seeing its meals, rota and list. The home carries on for everyone else, '
            'and you can join again with a new invite code.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Stay')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Leave home'),
          ),
        ],
      ),
    ) ??
    false;

Future<void> deleteAccountFlow(BuildContext context, WidgetRef ref, {required bool owner}) async {
  final ok = await showDialog<bool>(context: context, builder: (_) => _ConfirmDelete(owner: owner));
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(sessionProvider.notifier).deleteAccount();
    ref.invalidate(onboardingProvider);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.go(Routes.welcome);
    messenger.showSnackBar(const SnackBar(content: Text('Your account has been deleted.')));
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageFor(e))));
  }
}

class _ConfirmDelete extends StatefulWidget {
  const _ConfirmDelete({required this.owner});

  final bool owner;

  @override
  State<_ConfirmDelete> createState() => _ConfirmDeleteState();
}

class _ConfirmDeleteState extends State<_ConfirmDelete> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goes = [
      'Your profile and sign in details',
      if (widget.owner) 'Your home, for everyone in it: meals, rota, list and members' else 'Your place in the home you joined',
      'Your settings and favourites',
    ];
    return AlertDialog(
      icon: Icon(Icons.delete_forever_outlined, color: scheme.error),
      title: const Text('Delete your account?'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('This is permanent. We delete:'),
        const SizedBox(height: AppSpace.sm),
        for (final g in goes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.close, size: 18, color: scheme.error),
              const SizedBox(width: AppSpace.sm),
              Expanded(child: Text(g)),
            ]),
          ),
        const SizedBox(height: AppSpace.sm),
        Text('A Premium plan stops with the account. Payment records we must keep by law are kept as the Privacy Policy explains.',
            style: Theme.of(context).textTheme.bodySmall),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _understood,
          onChanged: (v) => setState(() => _understood = v ?? false),
          title: const Text('I understand this cannot be undone'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep my account')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: scheme.error),
          onPressed: _understood ? () => Navigator.pop(context, true) : null,
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}
