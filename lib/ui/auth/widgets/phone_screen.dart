// ─── Phone Number ─────────────────────────────────────────────────
// The way most Ugandan households will sign in (PRD 7.2): a number, then a
// texted code. Uganda first; the rest of East Africa and the 12 market
// countries follow.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/ink_button.dart';

const _countries = [
  ('🇺🇬', '+256', 'Uganda'),
  ('🇰🇪', '+254', 'Kenya'),
  ('🇹🇿', '+255', 'Tanzania'),
  ('🇷🇼', '+250', 'Rwanda'),
  ('🇸🇸', '+211', 'South Sudan'),
  ('🇬🇭', '+233', 'Ghana'),
  ('🇳🇬', '+234', 'Nigeria'),
  ('🇿🇦', '+27', 'South Africa'),
  ('🇬🇧', '+44', 'United Kingdom'),
  ('🇺🇸', '+1', 'United States'),
];

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _number = TextEditingController();
  String _dial = '+256';
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  String? get _phone => normalisePhone(_dial, _number.text);

  Future<void> _send() async {
    final phone = _phone;
    if (phone == null) {
      setState(() => _error = 'That number does not look complete.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).sendCode(phone);
      if (mounted) context.push('${Routes.accountCode}?phone=${Uri.encodeQueryComponent(phone)}');
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        bottom: InkButton(label: 'Send code', busy: _busy, onPressed: _phone == null ? null : _send),
        children: [
          const AuthHeading("What's your ", 'number', '?', lead: "We'll text you a 6 digit code to confirm it's you."),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 116,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Country', contentPadding: EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.md)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _dial,
                    isDense: true,
                    isExpanded: true,
                    items: [
                      for (final (flag, dial, name) in _countries)
                        DropdownMenuItem(value: dial, child: Text('$flag $dial', semanticsLabel: name)),
                    ],
                    onChanged: (v) => setState(() => _dial = v ?? _dial),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: TextField(
                controller: _number,
                autofocus: true,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(labelText: 'Phone number', hintText: '772 123 456'),
              ),
            ),
          ]),
          const SizedBox(height: AppSpace.md),
          Text('Standard SMS rates from your network may apply.', style: Theme.of(context).textTheme.bodySmall),
          AuthError(_error),
        ],
      );
}
