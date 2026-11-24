// ─── Code ─────────────────────────────────────────────────────────
// Six boxes for the texted code. Typing, pasting or the phone's own code
// suggestion all fill them; the sixth digit checks it straight away.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/domain/use_cases/validate_input.dart';
import 'package:domease/ui/auth/view_models/auth_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/form_parts.dart';
import 'package:domease/ui/core/ui/ink_button.dart';

class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  static const _wait = 30;
  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _left = _wait;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _countdown();
  }

  void _countdown() {
    _timer?.cancel();
    _left = _wait;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!isCode(_code.text) || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).verifyCode(widget.phone, _code.text);
      if (!mounted) return;
      final next = await routeAfterSignIn(ref);
      if (mounted) context.go(next);
    } catch (e) {
      if (!mounted) return;
      _code.clear();
      setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(sessionProvider.notifier).sendCode(widget.phone);
      if (!mounted) return;
      setState(_countdown);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A new code is on its way.')));
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(flavorProvider).useDemoData;
    return AuthScaffold(
      bottom: InkButton(label: 'Confirm', busy: _busy, onPressed: isCode(_code.text) ? _verify : null),
      children: [
        AuthHeading('Enter the ', 'code', '', lead: 'Sent by text to ${prettyPhone(widget.phone)}.'),
        _CodeBoxes(controller: _code, focus: _focus, onChanged: (v) {
          setState(() => _error = null);
          if (isCode(v)) _verify();
        }),
        const SizedBox(height: AppSpace.lg),
        Row(children: [
          TextButton(onPressed: _left > 0 ? null : _resend, child: Text(_left > 0 ? 'Send a new code in ${_left}s' : 'Send a new code')),
          const Spacer(),
          TextButton(onPressed: () => context.pop(), child: const Text('Change number')),
        ]),
        if (demo) Text('Demo: the code is 123456.', style: Theme.of(context).textTheme.bodySmall),
        AuthError(_error),
      ],
    );
  }
}

/// One hidden field drives six visible boxes, so paste and autofill just work.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.controller, required this.focus, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: focus.requestFocus,
      child: Stack(children: [
        Opacity(
          opacity: 0,
          child: TextField(
            controller: controller,
            focusNode: focus,
            autofocus: true,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            onChanged: onChanged,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 48,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: AppRadii.cardAll,
                    border: Border.all(color: i == value.text.length ? scheme.primary : scheme.outline, width: i == value.text.length ? 2 : 1),
                  ),
                  child: Text(i < value.text.length ? value.text[i] : '', style: AppText.title.copyWith(color: scheme.onSurface)),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
