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
}
