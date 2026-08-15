import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/core/theme/theme_controller.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/providers.dart';

import '../test_helpers.dart';

void main() {
  group('ThemeController', () {
    test('defaults to system mode when nothing is persisted', () async {
      final (boxes, tmp) = await initTestHive();
      addTearDown(() => tearDownTestHive(boxes, tmp));
      final container = ProviderContainer(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
      );
      addTearDown(container.dispose);
      expect(container.read(themeControllerProvider), ThemeMode.system);
    });

    test('persists choice to settings box and survives a fresh container',
        () async {
      final (boxes, tmp) = await initTestHive();
      addTearDown(() => tearDownTestHive(boxes, tmp));

      final c1 = ProviderContainer(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
      );
      await c1.read(themeControllerProvider.notifier).set(ThemeMode.dark);
      expect(c1.read(themeControllerProvider), ThemeMode.dark);
      expect(boxes.settings.get(SettingsKeys.theme), 'dark');
      c1.dispose();

      // A brand new container reading the same box should pick up the dark mode.
      final c2 = ProviderContainer(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
      );
      addTearDown(c2.dispose);
      expect(c2.read(themeControllerProvider), ThemeMode.dark);
    });
  });
}
