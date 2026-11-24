// ─── Animated Logo Tests ──────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/ui/core/ui/brand/animated_logo.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

Widget _host(Widget child, {bool reduce = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: Directionality(textDirection: TextDirection.ltr, child: Center(child: child)),
    );

void main() {
  testWidgets('the drawing finishes and says so', (tester) async {
    var drawn = 0;
    await tester.pumpWidget(_host(AnimatedDomEaseLogo(width: 200, onDrawn: () => drawn++)));
    await tester.pump(const Duration(seconds: 1));
    expect(drawn, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(drawn, 1);
  });

  testWidgets('reduced motion shows the finished logo at once', (tester) async {
    var drawn = 0;
    await tester.pumpWidget(_host(AnimatedDomEaseLogo(width: 200, onDrawn: () => drawn++), reduce: true));
    await tester.pump();
    expect(drawn, 1);
  });

  testWidgets('every layout keeps the artwork ratio while it moves', (tester) async {
    for (final layout in LogoLayout.values) {
      await tester.pumpWidget(_host(AnimatedDomEaseLogo(layout: layout, width: 200)));
      final art = brandArtFor(layout);
      final size = tester.getSize(find.byType(AnimatedDomEaseLogo));
      expect(size.height, closeTo(200 * art.height / art.width, 0.01));
      await tester.pump(const Duration(seconds: 4));
    }
  });

  testWidgets('the loader loops without ending', (tester) async {
    await tester.pumpWidget(_host(const LogoLoader()));
    await tester.pump(const Duration(seconds: 6));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
