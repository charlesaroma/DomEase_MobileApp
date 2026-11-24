// ─── Help ─────────────────────────────────────────────────────────
// Answers first, then a person: email support, report a problem or share
// an idea (it reaches the team in the admin dashboard), and rate DomEase.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:domease/domain/models/content_fallbacks.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/app_info_viewmodel.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/help/widgets/report_sheet.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final email = ref.watch(settingsProvider).value?.supportEmail ?? 'hello@domease.app';

    Future<void> mail() async {
      final version = await ref.read(appVersionProvider.future);
      final uri = Uri(scheme: 'mailto', path: email, query: 'subject=${Uri.encodeComponent('DomEase help (app $version)')}');
      final opened = await launchUrl(uri).catchError((_) => false);
      if (opened || !context.mounted) return;
      // No mail app: copy the address so it can be pasted anywhere.
      await Clipboard.setData(ClipboardData(text: email));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$email copied. Paste it into your email.')));
    }

    Future<void> rate() async {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating opens once DomEase is in your app store.')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Help and support')),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            SettingsGroup(title: 'Common questions', children: [
              for (final f in ref.watch(faqsProvider).value ?? fallbackFaqs)
                Theme(
                  // No extra lines from the expansion tile inside the card.
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(Icons.help_outline, color: scheme.primary),
                    title: Text(f.question, style: AppText.body.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w500)),
                    childrenPadding: const EdgeInsets.fromLTRB(56, 0, AppSpace.lg, AppSpace.lg),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(f.answer, style: AppText.body.copyWith(color: scheme.onSurface))],
                  ),
                ),
            ]),
            SettingsGroup(title: 'Talk to us', footer: 'We reply to the email or phone number on your account.', children: [
              SettingsTile(icon: Icons.mail_outline, title: 'Email support', subtitle: email, onTap: mail),
              SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a problem',
                subtitle: 'Something not working as it should',
                onTap: () => showReportSheet(context, topic: ReportTopic.problem),
              ),
              SettingsTile(
                icon: Icons.lightbulb_outline,
                title: 'Share an idea',
                subtitle: 'What would make DomEase better for your home',
                onTap: () => showReportSheet(context, topic: ReportTopic.idea),
              ),
            ]),
            SettingsGroup(title: 'Enjoying DomEase?', children: [
              SettingsTile(icon: Icons.star_outline, title: 'Rate DomEase', subtitle: 'It helps other homes find us', onTap: rate),
            ]),
          ],
        ),
      ),
    );
  }
}
