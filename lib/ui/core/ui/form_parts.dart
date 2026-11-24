// ─── Form Parts ───────────────────────────────────────────────────
// Shared by the sign in and setup screens: back arrow, a heading with one
// clay word, the form, and the action pinned at the bottom.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/legal.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/readable_width.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.children, this.bottom});

  final List<Widget> children;

  /// Pinned under the form: the main button and any link under it.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ReadableWidth(child: SafeArea(
          top: false,
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xxl),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
            ),
            if (bottom != null)
              Padding(padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.lg), child: bottom),
          ]),
        )),
      );
}

/// "Create your account", with "account" in clay, and a line under it.
class AuthHeading extends StatelessWidget {
  const AuthHeading(this.before, this.word, this.after, {super.key, this.lead});

  final String before;
  final String word;
  final String after;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(TextSpan(style: AppText.title.copyWith(color: scheme.onSurface, fontSize: 30), children: [
          TextSpan(text: before),
          TextSpan(text: word, style: TextStyle(color: scheme.primary)),
          TextSpan(text: after),
        ])),
        if (lead != null) ...[
          const SizedBox(height: AppSpace.md),
          Text(lead!, style: AppText.lead.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ]),
    );
  }
}

/// The reason a sign in did not work, in words a person can act on.
class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: AppColors.danger100, borderRadius: AppRadii.cardAll),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(message!, style: AppText.label.copyWith(color: AppColors.danger))),
      ]),
    );
  }
}

/// A Failure's own sentence; anything else becomes a calm generic line.
String messageFor(Object e) => e is Failure ? e.message : 'That did not work. Please try again.';

/// "Continue with Google", "Continue with phone": outlined, full width.
class AuthOptionButton extends StatelessWidget {
  const AuthOptionButton({super.key, required this.label, required this.leading, required this.onPressed});

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.md),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            child: Row(children: [
              SizedBox(width: 28, child: Center(child: leading)),
              Expanded(child: Text(label, textAlign: TextAlign.center)),
              const SizedBox(width: 28),
            ]),
          ),
        ),
      );
}

/// A plain "G" until the official Google mark asset is added (Google's
/// branding rules ask for their own artwork on the button).
class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) =>
      Text('G', style: AppText.heading.copyWith(fontSize: 20, color: const Color(0xFF4285F4), fontWeight: FontWeight.w800));
}

/// "or", between one tap sign in and the forms.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
        child: Row(children: [
          const Expanded(child: Divider()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpace.md), child: Text('or', style: Theme.of(context).textTheme.bodySmall)),
          const Expanded(child: Divider()),
        ]),
      );
}

/// The agreement line under every way in. Becomes links once the legal
/// pages are published.
class TermsNote extends StatelessWidget {
  const TermsNote({super.key});

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    Widget link(LegalDocId doc) => InkWell(
          onTap: () => context.push(Routes.legal(doc)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
            child: Text(doc.title,
                style: small?.copyWith(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline)),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.lg),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpace.xs,
        children: [
          Text('By continuing you agree to the DomEase', style: small),
          link(LegalDocId.terms),
          Text('and', style: small),
          link(LegalDocId.privacy),
        ],
      ),
    );
  }
}
