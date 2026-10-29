// ─── Typography ───────────────────────────────────────────────────
// Outfit for headings, Inter for interface text, IBM Plex Mono for Shillings
// and counts (assets/fonts). Outfit and Inter are variable fonts, so the
// weight is set on the 'wght' axis through [outfit] and [inter].
import 'package:flutter/painting.dart';

import 'package:domease/ui/core/themes/tokens.dart';

TextStyle _variable(String family, double size, FontWeight weight, double? height, double? spacing, Color color) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      height: height,
      letterSpacing: spacing,
      color: color,
    );

/// An Outfit style: headings, titles, buttons.
TextStyle outfit(double size, FontWeight weight, {double? height, double? spacing, Color color = AppColors.ink}) =>
    _variable('Outfit', size, weight, height, spacing, color);

/// An Inter style: body, labels, fields.
TextStyle inter(double size, FontWeight weight, {double? height, double? spacing, Color color = AppColors.ink}) =>
    _variable('Inter', size, weight, height, spacing, color);

/// The type scale (docs/05-design-system.md). Recolour with `.copyWith(color:)`.
abstract final class AppText {
  static final display = outfit(40, FontWeight.w700, height: 1.05, spacing: -0.8);
  static final title = outfit(30, FontWeight.w700, height: 1.1, spacing: -0.5);
  static final heading = outfit(22, FontWeight.w700, height: 1.2, spacing: -0.2);
  static final subheading = outfit(18, FontWeight.w600, height: 1.35);
  static final lead = inter(17, FontWeight.w400, height: 1.55, color: AppColors.ink2);
  static final body = inter(16, FontWeight.w400, height: 1.55);
  static final bodyStrong = inter(16, FontWeight.w600, height: 1.5);
  static final label = inter(14, FontWeight.w500, height: 1.4, color: AppColors.ink2);
  static final caption = inter(12, FontWeight.w500, height: 1.4, color: AppColors.ink2);

  /// Small uppercase label in clay: "TONIGHT", "THIS WEEK".
  static final eyebrow = outfit(12, FontWeight.w600, spacing: 2, color: AppColors.clay);

  /// Shillings, quantities and counts, so columns line up: "UGX 46,500".
  static const money = TextStyle(fontFamily: 'IBMPlexMono', fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
}
