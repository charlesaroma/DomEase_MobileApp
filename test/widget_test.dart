// Smoke tests: the app boots on the splash and the logo paints in every layout.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/app.dart';
import 'package:domease/ui/core/ui/brand/domease_logo.dart';

void main() {
  testWidgets('boots on the splash, then opens Today', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DomEaseApp()));
    expect(find.byType(DomEaseLogo), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('every logo layout keeps the artwork ratio', (tester) async {
    for (final layout in LogoLayout.values) {
      final logo = DomEaseLogo(layout: layout, width: 200);
      await tester.pumpWidget(Center(child: logo));
      final size = tester.getSize(find.byType(DomEaseLogo));
      expect(size.width, 200);
      expect(size.height, closeTo(200 * logo.art.height / logo.art.width, 0.01));
    }
  });
}
