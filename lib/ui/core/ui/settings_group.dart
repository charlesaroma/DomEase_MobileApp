// ─── Settings Group ───────────────────────────────────────────────
// The grouped rows used by You, Profile, Settings and Help: a small label,
// then one card of rows with hairlines between them, like the phone's own
// settings, so people know how to use it without thinking.
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/section_label.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children, this.footer});

  final String? title;
  final List<Widget> children;

  /// A line of explanation under the card.
  final String? footer;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) SectionLabel(title!) else const SizedBox(height: AppSpace.lg),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                child,
              ],
            ]),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.sm, AppSpace.lg, 0),
              child: Text(footer!, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      );
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Red, for Delete account and Leave this home.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colour = danger ? scheme.error : scheme.onSurface;
    return ListTile(
      minTileHeight: 56,
      leading: Icon(icon, color: danger ? scheme.error : scheme.primary),
      title: Text(title, style: AppText.body.copyWith(color: colour, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing ?? (onTap == null || danger ? null : Icon(Icons.chevron_right, color: scheme.outline)),
      onTap: onTap,
    );
  }
}

/// The person's initials in a clay circle (no photo upload in v1).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials, {super.key, this.radius = 18});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: radius,
      backgroundColor: dark ? AppColors.clay400 : AppColors.clay,
      child: Text(
        initials,
        style: AppText.subheading.copyWith(color: dark ? AppColors.night : AppColors.white, fontSize: radius * 0.8, height: 1),
      ),
    );
  }
}
