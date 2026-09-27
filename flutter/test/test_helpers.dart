import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/app.dart';
import 'package:hive_ce/hive.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/providers.dart';
import 'package:pray/services/liturgy/liturgical_calendar.dart';

/// Initializes Hive against a fresh temp directory and opens all app boxes.
/// Returns both the boxes and the temp dir so tests can clean up after.
///
/// Suitable for `test()` groups. Inside `testWidgets`, use
/// [initTestHiveInWidgetTest] instead — Hive's `openBox` schedules microtasks
/// that don't progress under fake-async.
Future<(AppBoxes, Directory)> initTestHive({bool inMemory = false}) async {
  final tmp = await Directory.systemTemp.createTemp('pray_test_');
  Hive.init(tmp.path);
  final boxes = await openTestBoxes(inMemory: inMemory);
  return (boxes, tmp);
}

/// Widget-test variant that runs the Hive bootstrap on the real event loop.
/// Boxes are in memory, so the UI's reads and writes complete under fake
/// async without giving the real event loop a turn.
Future<(AppBoxes, Directory)> initTestHiveInWidgetTest(
  WidgetTester tester,
) async {
  late AppBoxes boxes;
  late Directory tmp;
  await tester.runAsync(() async {
    final result = await initTestHive(inMemory: true);
    boxes = result.$1;
    tmp = result.$2;
  });
  return (boxes, tmp);
}

Future<void> tearDownTestHive(AppBoxes boxes, Directory tmp) async {
  await Hive.close();
  if (tmp.existsSync()) await tmp.delete(recursive: true);
}

/// A Riverpod container wired to [boxes], for testing notifier operations
/// through their public API. Dispose it in the test's tear-down.
ProviderContainer createTestContainer(AppBoxes boxes) => ProviderContainer(
      overrides: [appBoxesProvider.overrideWithValue(boxes)],
    );

/// Boots the whole app over in-memory [boxes], pinned to [day] (`YYYY-MM-DD`)
/// via the date override so date-dependent screens are deterministic.
Future<AppBoxes> pumpPrayApp(
  WidgetTester tester, {
  required String day,
  Future<void> Function(AppBoxes boxes)? seed,
}) async {
  final (boxes, tmp) = await initTestHiveInWidgetTest(tester);
  addTearDown(() async => tester.runAsync(() => tearDownTestHive(boxes, tmp)));
  await tester.runAsync(() async {
    await boxes.settings.put(SettingsKeys.dateOverride, day);
    await seed?.call(boxes);
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appBoxesProvider.overrideWithValue(boxes),
        liturgicalCalendarProvider.overrideWith((ref) async => bundledLiturgicalCalendar),
      ],
      child: const PrayApp(),
    ),
  );
  await settle(tester);
  return boxes;
}

/// The app's real bundled Liturgical Calendar, read straight from disk.
/// Widget tests provide it pre-loaded because loading assets needs the real
/// event loop, which fake-async widget tests don't run.
final bundledLiturgicalCalendar = LiturgicalCalendar.fromJson(
  File('assets/liturgy/liturgy.json').readAsStringSync(),
);

/// The app never fully settles (network-backed providers and ambient
/// animations), so pump a fixed number of frames instead of
/// `pumpAndSettle`.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Opens the ⋮ menu on the first Intention card and taps [action].
Future<void> chooseIntentionAction(WidgetTester tester, String action) async {
  await tester.tap(find.byTooltip('Intention actions').first);
  await settle(tester);
  await tester.tap(find.text(action).last);
  await settle(tester);
}

