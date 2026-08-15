import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/boxes.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boxes = await openAppBoxes();
  runApp(
    ProviderScope(
      overrides: [appBoxesProvider.overrideWithValue(boxes)],
      child: const PrayApp(),
    ),
  );
}
