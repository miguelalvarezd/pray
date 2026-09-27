import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/settings/mass_lang.dart';

import '../test_helpers.dart';

void main() {
  testWidgets("Today's Holy Mass card shows the Day's Celebration and Optional Memorials",
      (tester) async {
    await pumpPrayApp(tester, day: '2026-09-28');

    await tester.tap(find.text('Holy Mass'));
    await settle(tester);

    expect(find.textContaining('Saint Wenceslaus, Martyr'), findsOneWidget);
  });

  testWidgets("Today's Holy Mass card shows the Day's Reading References (27 Sep 2026)",
      (tester) async {
    await pumpPrayApp(tester, day: '2026-09-27');

    await tester.tap(find.text('Holy Mass'));
    await settle(tester);

    expect(find.text('Ez 18:25-28'), findsOneWidget);
    expect(find.text('Ps 25:4-5, 6-7, 8-9'), findsOneWidget);
    expect(find.text('Phil 2:1-11 or 2:1-5'), findsOneWidget);
    expect(find.text('Mt 21:28-32'), findsOneWidget);
  });

  testWidgets('References follow the Mass Guide language and update when it changes',
      (tester) async {
    final boxes = await pumpPrayApp(
      tester,
      day: '2026-09-27',
      seed: (boxes) => boxes.settings.put(SettingsKeys.massLang, 'es'),
    );
    await tester.tap(find.text('Holy Mass'));
    await settle(tester);
    expect(find.text('Mt 21, 28-32'), findsOneWidget);
    expect(find.text('Sal 24'), findsOneWidget);

    // What the Mass Guide does when its language is changed.
    await tester.runAsync(() => boxes.settings.put(SettingsKeys.massLang, 'de'));
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp).first))
        .invalidate(massLangProvider);
    await settle(tester);
    expect(find.text('Mt 21,28-32'), findsOneWidget);
  });
}
