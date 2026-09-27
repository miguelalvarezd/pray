import 'package:flutter_test/flutter_test.dart';

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
}
