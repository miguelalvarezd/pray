import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/providers.dart';
import 'package:pray/domain/rosary_engine.dart';
import 'package:pray/features/rosary_guide/rosary_guide_screen.dart';
import 'package:pray/features/rosary_guide/widgets/step_view.dart';

import '../test_helpers.dart';

void main() {
  Future<int> pumpGuide(WidgetTester tester) async {
    final (boxes, tmp) = await initTestHiveInWidgetTest(tester);
    addTearDown(() async => tester.runAsync(() => tearDownTestHive(boxes, tmp)));
    await tester.runAsync(
        () => boxes.settings.put(SettingsKeys.dateOverride, '2026-05-04'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
        child: const MaterialApp(home: RosaryGuideScreen()),
      ),
    );
    await settle(tester);
    return generateRosarySteps(getMysterySetForDate(DateTime(2026, 5, 4))).length;
  }

  testWidgets('tapping the prayer text advances to the next step', (tester) async {
    final total = await pumpGuide(tester);
    expect(find.text('Step 1 / $total'), findsOneWidget);

    await tester.tap(find.text('Sign of the Cross'));
    await settle(tester);

    expect(find.text('Step 2 / $total'), findsOneWidget);
  });

  testWidgets('swiping does not change the step', (tester) async {
    final total = await pumpGuide(tester);

    await tester.fling(find.text('Sign of the Cross'), const Offset(-400, 0), 1500);
    await settle(tester);

    expect(find.text('Step 1 / $total'), findsOneWidget);
  });

  testWidgets('the same prayer updates in place; a different prayer crossfades',
      (tester) async {
    await pumpGuide(tester);
    // Advance to the first of the three introductory Hail Marys.
    for (var i = 0; i < 10 && find.text('Hail Mary').evaluate().isEmpty; i++) {
      await tester.tap(find.byType(RosaryStepView));
      await settle(tester);
    }
    expect(find.text('Hail Mary'), findsOneWidget);

    // Hail Mary → Hail Mary: no transition, so only one step view at a time.
    await tester.tap(find.byType(RosaryStepView));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RosaryStepView), findsOneWidget);
    await settle(tester);

    // Third Hail Mary → Glory Be: mid-crossfade both step views are shown.
    await tester.tap(find.byType(RosaryStepView));
    await settle(tester);
    await tester.tap(find.byType(RosaryStepView));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RosaryStepView), findsNWidgets(2));
    await settle(tester);
  });
}
