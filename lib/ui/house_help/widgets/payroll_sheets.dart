// ─── Payroll Sheets ───────────────────────────────────────────────
// Add or edit someone, record a payment or day off, and send a payslip.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/house_help/view_models/payroll_viewmodel.dart';
import 'package:domease/utils/dates.dart';

Future<void> _sheet(BuildContext context, Widget child) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(c).bottom + AppSpace.xl),
        child: SingleChildScrollView(child: child),
      ),
    );

int _digits(String v) => int.tryParse(v.replaceAll(RegExp(r'\D'), '')) ?? 0;

Widget _title(BuildContext context, String text) =>
    Padding(padding: const EdgeInsets.only(bottom: AppSpace.lg), child: Text(text, style: AppText.title.copyWith(color: Theme.of(context).colorScheme.onSurface)));

// ── Add or edit someone ──

Future<void> showStaffSheet(BuildContext context, {Staff? person, required List<String> suggestions, required String currency}) =>
    _sheet(context, _StaffForm(person: person, suggestions: suggestions, currency: currency));

class _StaffForm extends ConsumerStatefulWidget {
  const _StaffForm({this.person, required this.suggestions, required this.currency});

  final Staff? person;
  final List<String> suggestions;
  final String currency;

  @override
  ConsumerState<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends ConsumerState<_StaffForm> {
  late final _name = TextEditingController(text: widget.person?.name ?? (widget.suggestions.isEmpty ? '' : widget.suggestions.first));
  late final _salary = TextEditingController(text: widget.person == null ? '' : '${widget.person!.salary}');
  late final _payday = TextEditingController(text: '${widget.person?.payday ?? 28}');
  late String _role = widget.person?.role ?? staffRoles.first;

  @override
  void dispose() {
    _name.dispose();
    _salary.dispose();
    _payday.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final day = _digits(_payday.text);
    if (_name.text.trim().isEmpty || _digits(_salary.text) <= 0 || day < 1 || day > 31) return;
    final p = widget.person;
    final next = Staff(
      id: p?.id ?? 'staff_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      role: _role,
      salary: _digits(_salary.text),
      payday: day,
      startedOn: p?.startedOn ?? DateTime.now(),
      entries: p?.entries ?? const [],
    );
    await ref.read(staffProvider.notifier).upsert(next);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        _title(context, widget.person == null ? 'Add someone who helps at home' : 'Edit ${widget.person!.name}'),
        TextField(controller: _name, autofocus: widget.person == null, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: AppSpace.md),
        Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
          for (final r in staffRoles) ChoiceChip(label: Text(r), selected: _role == r, onSelected: (_) => setState(() => _role = r)),
        ]),
        const SizedBox(height: AppSpace.md),
        Row(children: [
          Expanded(
            flex: 2,
            child: TextField(controller: _salary, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monthly salary (${widget.currency})')),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(child: TextField(controller: _payday, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Payday', helperText: 'Day of month'))),
        ]),
        const SizedBox(height: AppSpace.xl),
        Row(children: [
          if (widget.person != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(staffProvider.notifier).remove(widget.person!.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Remove'),
              ),
            ),
            const SizedBox(width: AppSpace.md),
          ],
          Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
        ]),
      ]);
}

// ── Record a payment, advance, deduction, bonus or days off ──

Future<void> showEntrySheet(BuildContext context, {required Staff person, required String currency}) => _sheet(context, _EntryForm(person: person, currency: currency));

class _EntryForm extends ConsumerStatefulWidget {
  const _EntryForm({required this.person, required this.currency});

  final Staff person;
  final String currency;

  @override
  ConsumerState<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends ConsumerState<_EntryForm> {
  PayKind _kind = PayKind.pay;
  DateTime _date = DateTime.now();
  late final _amount = TextEditingController(text: '${payMonth(widget.person).owed.clamp(0, 1 << 31)}');
  final _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _choose(PayKind k) => setState(() {
        _kind = k;
        _amount.text = k == PayKind.pay ? '${payMonth(widget.person).owed.clamp(0, 1 << 31)}' : (k == PayKind.leave ? '1' : '');
      });

  Future<void> _save() async {
    final n = _digits(_amount.text);
    if (n <= 0) return;
    final leave = _kind == PayKind.leave;
    final entry = PayEntry(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime(_date.year, _date.month, _date.day, 12),
      kind: _kind,
      amount: leave ? 0 : n,
      days: leave ? n : 0,
      note: _note.text.trim(),
    );
    await ref.read(staffProvider.notifier).addEntry(widget.person.id, entry);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        _title(context, 'Record for ${widget.person.name}'),
        Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
          for (final k in PayKind.values) ChoiceChip(label: Text(k.label), selected: _kind == k, onSelected: (_) => _choose(k)),
        ]),
        const SizedBox(height: AppSpace.md),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: _kind == PayKind.leave ? 'Days' : 'Amount (${widget.currency})'),
        ),
        const SizedBox(height: AppSpace.md),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(now.year - 2), lastDate: now);
            if (picked != null) setState(() => _date = picked);
          },
          icon: const Icon(Icons.event_outlined),
          label: Text(shortDate(_date)),
        ),
        const SizedBox(height: AppSpace.md),
        TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note (optional)')),
        if (_kind == PayKind.advance) ...[
          const SizedBox(height: AppSpace.sm),
          Text('An advance comes off this month\'s salary.', style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpace.xl),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save'))),
      ]);
}

// ── Payslip ──

Future<void> showPayslipSheet(BuildContext context, {required Staff person, required String home, required String Function(num) fmt}) =>
    _sheet(context, _Payslip(person: person, home: home, fmt: fmt));

class _Payslip extends StatelessWidget {
  const _Payslip({required this.person, required this.home, required this.fmt});

  final Staff person;
  final String home;
  final String Function(num) fmt;

  @override
  Widget build(BuildContext context) {
    final text = payslipText(staff: person, month: payMonth(person), home: home, money: fmt);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      _title(context, 'Payslip for ${person.name}'),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: AppRadii.cardAll),
        child: SelectableText(text, style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ),
      const SizedBox(height: AppSpace.xl),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payslip copied.')));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication).catchError((_) => false),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('WhatsApp'),
          ),
        ),
      ]),
    ]);
  }
}
