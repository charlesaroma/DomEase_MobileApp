// ─── Email ────────────────────────────────────────────────────────
// Create an account (name, email, password) or log in (email, password,
// forgot password). The same screen, switched by [mode].
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/ink_button.dart';

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;
  String? _error;

  bool get _signUp => widget.mode == AuthMode.signUp;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = ref.read(sessionProvider.notifier);
    try {
      if (_signUp) {
        await session.emailSignUp(_name.text.trim(), _email.text.trim(), _password.text);
      } else {
        await session.emailLogIn(_email.text.trim(), _password.text);
      }
      if (!mounted) return;
      final next = await routeAfterSignIn(ref);
      if (mounted) context.go(next);
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        bottom: InkButton(label: _signUp ? 'Create account' : 'Log in', busy: _busy, onPressed: _submit),
        children: [
          if (_signUp)
            const AuthHeading('Create your ', 'account', '', lead: 'Free, and it keeps your home in sync on every phone.')
          else
            const AuthHeading('Log in with ', 'email', ''),
          Form(
            key: _form,
            child: AutofillGroup(
              child: Column(children: [
                if (_signUp) ...[
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(labelText: 'Your name'),
                    validator: (v) => checkName(v ?? ''),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => checkEmail(v ?? ''),
                ),
                const SizedBox(height: AppSpace.md),
                TextFormField(
                  controller: _password,
                  obscureText: _hidden,
                  autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: _signUp ? 'At least 8 characters, with a number.' : null,
                    suffixIcon: IconButton(
                      tooltip: _hidden ? 'Show password' : 'Hide password',
                      icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    ),
                  ),
                  validator: (v) => _signUp ? checkPassword(v ?? '') : ((v ?? '').isEmpty ? 'Enter your password.' : null),
                ),
              ]),
            ),
          ),
          if (!_signUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => context.push(Routes.accountForgot), child: const Text('Forgot password?')),
            ),
          AuthError(_error),
          if (_signUp) const TermsNote(),
        ],
      );
}
