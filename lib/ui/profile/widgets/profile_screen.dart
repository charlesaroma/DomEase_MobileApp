// ─── Profile ──────────────────────────────────────────────────────
// Name and contact details, how this person signs in, their password, and
// the account itself: leave a home they joined, or delete the account.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/session.dart';
import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/profile/widgets/account_actions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final Session? _start = ref.read(sessionProvider).value;
  late final _name = TextEditingController(text: _start?.name ?? '');
  late final _email = TextEditingController(text: _start?.email ?? '');
  late final _phone = TextEditingController(text: _start?.phone ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _changed =>
      _name.text.trim() != (_start?.name ?? '') || _email.text.trim() != (_start?.email ?? '') || _phone.text.trim() != (_start?.phone ?? '');

  String? get _problem {
    if (checkName(_name.text) != null) return checkName(_name.text);
    if (_email.text.trim().isNotEmpty && checkEmail(_email.text) != null) return checkEmail(_email.text);
    final phone = _phone.text.replaceAll(' ', '');
    if (phone.isNotEmpty && !RegExp(r'^\+\d{9,15}$').hasMatch(phone)) return 'Write the phone number with its country code, like +256 772 123456.';
    return null;
  }

  Future<void> _save() async {
    final problem = _problem;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final s = _start;
      await ref.read(sessionProvider.notifier).updateProfile(
            name: _name.text.trim(),
            email: _email.text.trim() == (s?.email ?? '') ? null : _email.text.trim(),
            phone: _phone.text.replaceAll(' ', '') == (s?.phone ?? '') ? null : _phone.text.replaceAll(' ', ''),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    final home = ref.watch(householdProvider).value;
    final owner = home != null && home.members.any((m) => m.id == session?.userId && m.role == MemberRole.owner);
    final social = session?.method == SignInMethod.google || session?.method == SignInMethod.apple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(onPressed: _busy || !_changed ? null : _save, child: Text(_busy ? 'Saving' : 'Save')),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
          children: [
            Center(child: InitialsAvatar(session?.initials ?? '?', radius: 40)),
            const SizedBox(height: AppSpace.xxl),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: _email,
              enabled: !social,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                labelText: 'Email',
                helperText: social ? 'Managed by your ${session!.method == SignInMethod.google ? 'Google' : 'Apple'} account.' : null,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(labelText: 'Phone number', hintText: '+256 772 123456'),
            ),
            if (_changed && !social)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.sm),
                child: Text('A new email or phone number is confirmed with a link or a code before you can sign in with it.',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            AuthError(_error),

            SettingsGroup(title: 'Sign in', children: [
              SettingsTile(icon: _methodIcon(session?.method), title: _methodLabel(session?.method), subtitle: session?.label),
              if (session?.hasPassword ?? false)
                SettingsTile(icon: Icons.password, title: 'Change password', onTap: () => showChangePassword(context, ref)),
            ]),

            SettingsGroup(
              title: 'Account',
              footer: owner
                  ? 'You set up this home. Deleting your account deletes the home for everyone in it.'
                  : 'Leaving keeps your account; you can set up a new home or join another.',
              children: [
                if (home != null && !owner)
                  SettingsTile(
                    icon: Icons.logout,
                    title: 'Leave ${home.name}',
                    danger: true,
                    onTap: () async {
                      if (await confirmLeave(context, home.name) && context.mounted) {
                        await ref.read(householdProvider.notifier).leave();
                        if (context.mounted) context.go(Routes.setup);
                      }
                    },
                  ),
                SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete account',
                  danger: true,
                  onTap: () => deleteAccountFlow(context, ref, owner: owner),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _methodIcon(SignInMethod? m) => switch (m) {
      SignInMethod.google => Icons.g_mobiledata,
      SignInMethod.apple => Icons.apple,
      SignInMethod.phone => Icons.phone_iphone,
      _ => Icons.mail_outline,
    };

String _methodLabel(SignInMethod? m) => switch (m) {
      SignInMethod.google => 'Signed in with Google',
      SignInMethod.apple => 'Signed in with Apple',
      SignInMethod.phone => 'Signed in with your phone number',
      _ => 'Signed in with email and password',
    };
