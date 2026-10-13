import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/boxes.dart';
import '../../data/providers.dart';

/// Persists [ThemeMode] to the settings Hive box under
/// [SettingsKeys.theme]. Stored as the enum's [ThemeMode.name] so the value
/// is human-readable on disk and forward-compatible if we add modes later.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = ref.watch(settingsBoxProvider);
    final raw = box.get(SettingsKeys.theme) as String?;
    return _parse(raw);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsBoxProvider).put(SettingsKeys.theme, mode.name);
  }

  static ThemeMode _parse(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
