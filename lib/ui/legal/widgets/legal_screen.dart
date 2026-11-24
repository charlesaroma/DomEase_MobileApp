// ─── Legal ────────────────────────────────────────────────────────
// One legal document: when it last changed, the short version in plain
// words, then each section. Readable before signing in (the sign in screens
// link here) and with no connection (a copy ships in the app).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/legal.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/utils/dates.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.id});

  final LegalDocId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(id.title)),
      body: AsyncView(
        value: ref.watch(legalProvider(id)),
        onRetry: () => ref.invalidate(legalProvider(id)),
        data: (doc) => ReadableWidth(
          maxWidth: 720,
          child: SelectionArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
              children: [
                Text(doc.title, style: AppText.title.copyWith(color: scheme.onSurface)),
                const SizedBox(height: AppSpace.xs),
                Text('Last updated ${fullDate(doc.updated)}', style: Theme.of(context).textTheme.bodySmall),
                if (doc.summary.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpace.lg),
                    decoration: BoxDecoration(color: dark ? AppColors.nightClayTint : AppColors.clay100, borderRadius: AppRadii.cardAll),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('IN SHORT', style: AppText.eyebrow.copyWith(color: scheme.primary)),
                      const SizedBox(height: AppSpace.sm),
                      Text(doc.summary, style: AppText.body.copyWith(color: scheme.onSurface)),
                    ]),
                  ),
                ],
                for (final (i, s) in doc.sections.indexed) ...[
                  const SizedBox(height: AppSpace.xxl),
                  Text('${i + 1}. ${s.heading}', style: AppText.subheading.copyWith(color: scheme.onSurface)),
                  for (final p in s.paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.sm),
                      child: Text(p, style: AppText.body.copyWith(color: scheme.onSurface)),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
