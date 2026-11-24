// ─── About ────────────────────────────────────────────────────────
// What DomEase is, the installed version, and the open source licences the
// app is built on (shown by Flutter's own licence page).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/legal.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/settings_group.dart';
import 'package:domease/ui/core/view_models/app_info_viewmodel.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final version = ref.watch(appVersionProvider).value ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('About DomEase')),
      body: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, AppSpace.huge),
          children: [
            Center(
              child: DomEaseLogo(alignment: Alignment.center, tone: dark ? LogoTone.reversed : LogoTone.primary, width: 180),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              'Meals, cleaning and one shared shopping list, planned for the way homes in Uganda really run.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SettingsGroup(title: 'This app', children: [
              SettingsTile(icon: Icons.verified_outlined, title: 'Version', subtitle: version),
              SettingsTile(
                icon: Icons.article_outlined,
                title: 'Open source licences',
                onTap: () => showLicensePage(context: context, applicationName: 'DomEase', applicationVersion: version),
              ),
            ]),
            SettingsGroup(title: 'Legal', children: [
              for (final doc in LegalDocId.values)
                SettingsTile(icon: Icons.description_outlined, title: doc.title, onTap: () => context.push(Routes.legal(doc))),
            ]),
          ],
        ),
      ),
    );
  }
}
