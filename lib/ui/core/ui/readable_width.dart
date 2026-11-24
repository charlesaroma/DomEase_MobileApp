// ─── Readable Width ───────────────────────────────────────────────
// Phones use the full width. On tablets, iPads, foldables and landscape the
// content stays in a centred column, so lines stay readable and cards and
// buttons do not stretch across a wide screen. The height is passed through
// unchanged, so full height layouts (onboarding, welcome) behave as before.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final w = math.min(c.maxWidth, maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: w, maxWidth: w, minHeight: c.minHeight, maxHeight: c.maxHeight),
            child: child,
          ),
        );
      });
}
