import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/features/stats/widgets/prayer_progress.dart';
import 'package:pray/features/stats/widgets/streak_card.dart';

import '../test_helpers.dart';

void main() {
  group('Streak card', () {
    // 240px is a width where a 2-digit Streak fits on one line with its
    // "days" suffix but a 3-digit one did not.
    Future<void> pumpCard(WidgetTester tester, int value) => tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 240,
                child: StreakCard(
                  label: 'Current Streak',
                  value: value,
                  icon: Icons.local_fire_department,
                  bg: Colors.white,
                  fg: Colors.black,
                  numberColor: Colors.black,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

    testWidgets('a 2-digit Streak fits', (tester) async {
      await pumpCard(tester, 42);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 3-digit Streak also fits', (tester) async {
      await pumpCard(tester, 120);
      expect(tester.takeException(), isNull);
      expect(find.text('120'), findsOneWidget);
    });
  });

  testWidgets('the monthly breakdown calls Activities "Activities"', (tester) async {
    await pumpPrayApp(
      tester,
      day: '2026-09-27',
      seed: (boxes) => boxes.logs.put(
        '2026-09-27',
        const DailyLog(date: '2026-09-27', completedActivities: ['confession']),
      ),
    );
    await tester.tap(find.text('Stats').last);
    await settle(tester);

    final activitiesRow = find.widgetWithText(PrayerProgressBar, 'Activities');
    await tester.scrollUntilVisible(activitiesRow, 200,
        scrollable: find.byType(Scrollable).first);
    expect(activitiesRow, findsOneWidget);
    expect(find.text('Other Prayers', skipOffstage: false), findsNothing);
  });
}

