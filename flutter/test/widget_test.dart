import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pray/app.dart';
import 'package:pray/data/providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('App boots with bottom nav and 5 tabs', (tester) async {
    final (boxes, tmp) = await initTestHiveInWidgetTest(tester);
    addTearDown(() async => tester.runAsync(() => tearDownTestHive(boxes, tmp)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
        child: const PrayApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Intentions'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
