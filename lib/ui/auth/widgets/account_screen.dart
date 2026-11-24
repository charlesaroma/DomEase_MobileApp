// ─── Account ──────────────────────────────────────────────────────
// The first step after Welcome: "Create your account" for someone new, or
// "Welcome back" for someone logging in. Google and Apple are one tap; phone and email
// open their own screens.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/session.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/form_parts.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  String? _error;
  bool _busy = false;

  bool get _signUp => widget.mode == AuthMode.signUp;

  Future<void> _oneTap(Future<Session> Function() signIn) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await signIn();
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
  Widget build(BuildContext context) {
    final session = ref.read(sessionProvider.notifier);
    // Apple requires Sign in with Apple on iPhone whenever Google is offered.
    final apple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
    final mode = _signUp ? 'signup' : 'login';

    return AuthScaffold(
      bottom: TextButton(
        onPressed: _busy ? null : () => context.pushReplacement('${Routes.account}?mode=${_signUp ? 'login' : 'signup'}'),
        child: Text(_signUp ? 'Already have an account? Log in' : 'New to DomEase? Create an account'),
      ),
      children: [
        const DomEaseLogo(layout: LogoLayout.mark, height: 52),
        const SizedBox(height: AppSpace.xxl),
        if (_signUp)
          const AuthHeading('Create your ', 'account', '',
              lead: "It's free. Your home stays safe on every phone, and the people you live with can join you.")
        else
          const AuthHeading('Welcome ', 'back', '', lead: 'Log in to pick up where your household left off.'),
        AuthOptionButton(label: 'Continue with Google', leading: const GoogleMark(), onPressed: _busy ? null : () => _oneTap(session.google)),
        if (apple)
          AuthOptionButton(label: 'Continue with Apple', leading: const Icon(Icons.apple), onPressed: _busy ? null : () => _oneTap(session.apple)),
        const OrDivider(),
        AuthOptionButton(
          label: 'Continue with phone number',
          leading: const Icon(Icons.phone_iphone),
          onPressed: _busy ? null : () => context.push(Routes.accountPhone),
        ),
        AuthOptionButton(
          label: 'Continue with email',
          leading: const Icon(Icons.mail_outline),
          onPressed: _busy ? null : () => context.push('${Routes.accountEmail}?mode=$mode'),
        ),
        if (_busy) const Padding(padding: EdgeInsets.only(top: AppSpace.lg), child: Center(child: CircularProgressIndicator())),
        AuthError(_error),
        const TermsNote(),
      ],
    );
  }
}
