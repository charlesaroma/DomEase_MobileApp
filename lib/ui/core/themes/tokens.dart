// ─── Design Tokens ────────────────────────────────────────────────
// Terracotta and Sage, one-for-one with the website's `src/index.css`
// (docs/05-design-system.md). Features use these names; they never type a raw
// hex value, size or duration.
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// The DomEase palette: fired clay, a quiet sage, amber for action.
abstract final class AppColors {
  // ── Clay: the brand. Logo house, headings, primary buttons, progress ──
  static const clay950 = Color(0xFF2A1005);
  static const clay900 = Color(0xFF461F0E); // splash, the dark band
  static const clay800 = Color(0xFF643119);
  static const clay = Color(0xFF874628); // 700, brand
  static const clay600 = Color(0xFFA85E3D); // the logo's tulip
  static const clay400 = Color(0xFFD99679); // brand on dark
  static const clay200 = Color(0xFFEEC6B5);
  static const clay100 = Color(0xFFF9E0D6);

  // ── Sage: cleaning and the logo's leaves. Small marks only ──
  static const sage800 = Color(0xFF3C6548);
  static const sage = Color(0xFF53815F); // 700
  static const sage400 = Color(0xFF8CB496);
  static const sage200 = Color(0xFFC0D7C5);
  static const sage100 = Color(0xFFDFECE2);

  // ── Amber: only for action (Start free, Premium). Nothing decorative ──
  static const amber800 = Color(0xFF795101);
  static const amber = Color(0xFF9A6A12); // 700
  static const amber400 = Color(0xFFCD9F5C);
  static const amber200 = Color(0xFFE7CDA9);

  // ── Ink: warm greys for text (on paper: 14.0, 6.6, 3.0 : 1) ──
  static const ink = Color(0xFF2D2520);
  static const ink2 = Color(0xFF635953); // lightest tone for body text
  static const ink3 = Color(0xFF9A928C); // hints and disabled only

  // ── Surfaces and lines, day ──
  static const paper = Color(0xFFF9F6F5);
  static const paper2 = Color(0xFFEEE9E6);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFD9D2CE);
  static const line2 = Color(0xFFB4ABA6);

  // ── Surfaces, evening (chosen, not inverted) ──
  static const night = Color(0xFF19120E);
  static const nightCard = Color(0xFF2A211C);
  static const nightLine = Color(0xFF3A302A);
  static const nightText = Color(0xFFF4EFEC);
  static const nightClayTint = Color(0xFF4A2416);

  // ── States: red only for low stock, always with an icon and a word ──
  static const success = sage;
  static const danger = Color(0xFFB4342A);
  static const danger100 = Color(0xFFFBE3E0);
}

/// Spacing on a 4-point grid.
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 32;
  static const double huge = 48;

  /// Side padding of every screen.
  static const double screen = 20;
}

abstract final class AppRadii {
  static const double tile = 12;
  static const double card = 16;
  static const double stage = 24;
  static const double pill = 999;

  static const cardAll = BorderRadius.all(Radius.circular(card));
  static const stageAll = BorderRadius.all(Radius.circular(stage));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const splash = Duration(milliseconds: 1600);
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
}
