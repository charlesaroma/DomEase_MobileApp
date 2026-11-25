// ─── Insights Screens Test ────────────────────────────────────────
// The Premium screens draw on demo data: budget, trends, and house help pay
// with its payslip.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/config/environment.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/house_help/widgets/house_help_screen.dart';
import 'package:domease/ui/insights/widgets/insights_screen.dart';

import '../../testing/fakes.dart';

Widget premium(Widget screen) => ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(Flavor.development),
        prefsStoreProvider.overrideWithValue(MemoryPrefsStore()),
        isPremiumProvider.overrideWithValue(true),
      ],
      child: MaterialApp(home: screen),
    );

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Insights shows the budget month and the eating trends', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(premium(const InsightsScreen()));
    await settle(tester);
    expect(find.text('Spent on food this month'), findsOneWidget);
    expect(find.text('Six months of food shopping'.toUpperCase()), findsOneWidget);
    await tester.tap(find.text('Eating trends'));
    await settle(tester);
    expect(find.text('Most planned lunches and dinners'.toUpperCase()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('House Help pay shows what is owed and a payslip', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(premium(const HouseHelpScreen(initialTab: 1)));
    await settle(tester);
    expect(find.text('Grace'), findsOneWidget);
    expect(find.textContaining('Still to pay for'), findsOneWidget);
    await tester.tap(find.text('Payslip'));
    await settle(tester);
    expect(find.text('Payslip for Grace'), findsOneWidget);
    expect(find.textContaining('Salary: UGX 250,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
