// ─── Theme ────────────────────────────────────────────────────────
// Material's ThemeData dressed in the DomEase tokens, so stock widgets
// (fields, sheets, snackbars, switches) already look on-brand. Day and
// evening are separate choices, not one palette inverted.
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

ThemeData buildTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final text = dark ? AppColors.nightText : AppColors.ink;
  final muted = dark ? AppColors.ink3 : AppColors.ink2;
  final surface = dark ? AppColors.night : AppColors.paper;
  final card = dark ? AppColors.nightCard : AppColors.white;
  final line = dark ? AppColors.nightLine : AppColors.line;
  final brand = dark ? AppColors.clay400 : AppColors.clay;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: brand,
    onPrimary: dark ? AppColors.night : AppColors.white,
    secondary: dark ? AppColors.sage400 : AppColors.sage,
    onSecondary: AppColors.white,
    tertiary: dark ? AppColors.amber400 : AppColors.amber,
    onTertiary: AppColors.white,
    surface: surface,
    onSurface: text,
    surfaceContainerHighest: card,
    outline: line,
    error: AppColors.danger,
    onError: AppColors.white,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: surface, fontFamily: 'Inter');

  OutlineInputBorder field(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: AppRadii.cardAll, borderSide: BorderSide(color: c, width: w));

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: AppText.display.copyWith(color: text),
      headlineMedium: AppText.title.copyWith(color: text),
      titleLarge: AppText.heading.copyWith(color: text),
      titleMedium: AppText.subheading.copyWith(color: text),
      bodyLarge: AppText.body.copyWith(color: text),
      bodyMedium: AppText.body.copyWith(fontSize: 15, color: text),
      bodySmall: AppText.label.copyWith(color: muted),
      labelLarge: AppText.bodyStrong.copyWith(color: text),
      labelSmall: AppText.caption.copyWith(color: muted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.subheading.copyWith(color: text),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardAll),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: outfit(16, FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide(color: dark ? AppColors.nightLine : AppColors.line2),
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: outfit(16, FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.lg),
      border: field(line),
      enabledBorder: field(line),
      focusedBorder: field(brand, 1.5),
      errorBorder: field(AppColors.danger),
      focusedErrorBorder: field(AppColors.danger, 1.5),
      labelStyle: AppText.label.copyWith(color: muted),
      hintStyle: AppText.label.copyWith(color: AppColors.ink3),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? AppColors.nightCard : AppColors.ink,
      contentTextStyle: AppText.label.copyWith(color: AppColors.white),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardAll),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: brand, linearTrackColor: line),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: dark ? AppColors.nightClayTint : AppColors.clay100,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => AppText.caption.copyWith(color: s.contains(WidgetState.selected) ? brand : muted),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? brand : muted),
      ),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
  );
}
