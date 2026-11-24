// ─── App Smoke Test ───────────────────────────────────────────────
// Boots the development flavor: splash, then Welcome on a fresh phone.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/app.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

import '../../testing/fakes.dart';

void main() {
  testWidgets('a fresh phone goes from the splash to Welcome', (tester) async {
    await tester.pumpWidget(demoScope(child: const DomEaseApp()));
    expect(find.byType(DomEaseLogo), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('every logo layout keeps the artwork ratio', (tester) async {
    for (final layout in LogoLayout.values) {
      final logo = DomEaseLogo(layout: layout, width: 200);
      // A real app always has a Directionality above the logo; give the bare test one too.
      await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: Center(child: logo)));
      final size = tester.getSize(find.byType(DomEaseLogo));
      expect(size.width, 200);
      expect(size.height, closeTo(200 * logo.art.height / logo.art.width, 0.01));
    }
  });
}
