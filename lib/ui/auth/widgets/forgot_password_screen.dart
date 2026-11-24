// ─── Forgot Password ──────────────────────────────────────────────
// Asks for the email and always answers the same way, so the screen never
// reveals whether an address has an account.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/ink_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final problem = checkEmail(_email.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).sendReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_sent) {
      return AuthScaffold(
        bottom: InkButton(label: 'Back to log in', onPressed: () => context.pop()),
        children: [
          Icon(Icons.mark_email_read_outlined, size: 56, color: scheme.primary),
          const SizedBox(height: AppSpace.xl),
          const AuthHeading('Check your ', 'inbox', ''),
          Text(
            'If ${_email.text.trim()} has a DomEase account, a link to set a new password is on its way. It can take a few minutes; check spam too.',
            style: AppText.body.copyWith(color: scheme.onSurface),
          ),
        ],
      );
    }
    return AuthScaffold(
      bottom: InkButton(label: 'Send reset link', busy: _busy, onPressed: _send),
      children: [
        const AuthHeading('Reset your ', 'password', '', lead: "Enter the email you signed up with and we'll send you a link."),
        TextField(
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _send(),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        AuthError(_error),
      ],
    );
  }
}
