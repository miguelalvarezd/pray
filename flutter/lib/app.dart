import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/nav/router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_controller.dart';

class PrayApp extends ConsumerWidget {
  const PrayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Pray',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
