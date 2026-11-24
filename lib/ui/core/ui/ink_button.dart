// ─── Ink Button ───────────────────────────────────────────────────
// The full width ink pill for "next" actions that appear on every step
// (Continue, Send code). Amber stays reserved for money and the one action
// that matters (docs/05-design-system.md).
import 'package:flutter/material.dart';

import 'package:domease/ui/core/themes/tokens.dart';

class InkButton extends StatelessWidget {
  const InkButton({super.key, required this.label, required this.onPressed, this.amber = false, this.busy = false});

  final String label;
  final VoidCallback? onPressed;

  /// Amber instead of ink, for the one action that matters on the screen.
  final bool amber;

  /// Shows a small spinner and ignores taps.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = amber ? AppColors.amber : (dark ? AppColors.nightText : AppColors.ink);
    final fg = amber || !dark ? AppColors.white : AppColors.night;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: dark ? AppColors.nightLine : AppColors.paper2,
          disabledForegroundColor: AppColors.ink3,
        ),
        onPressed: busy ? null : onPressed,
        child: busy
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink3))
            : Text(label),
      ),
    );
  }
}
