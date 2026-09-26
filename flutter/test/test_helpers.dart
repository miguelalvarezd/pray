import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/providers.dart';

/// Initializes Hive against a fresh temp directory and opens all app boxes.
/// Returns both the boxes and the temp dir so tests can clean up after.
///
/// Suitable for `test()` groups. Inside `testWidgets`, use
/// [initTestHiveInWidgetTest] instead — Hive's `openBox` schedules microtasks
/// that don't progress under fake-async.
Future<(AppBoxes, Directory)> initTestHive() async {
  final tmp = await Directory.systemTemp.createTemp('pray_test_');
  Hive.init(tmp.path);
  final boxes = await openTestBoxes();
  return (boxes, tmp);
}

/// Widget-test variant that runs the Hive bootstrap on the real event loop.
Future<(AppBoxes, Directory)> initTestHiveInWidgetTest(
  WidgetTester tester,
) async {
  late AppBoxes boxes;
  late Directory tmp;
  await tester.runAsync(() async {
    final result = await initTestHive();
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
