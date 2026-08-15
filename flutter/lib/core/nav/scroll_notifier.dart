import 'package:flutter_riverpod/flutter_riverpod.dart';

class _ScrollTriggers extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => const {};

  void trigger(int tabIndex) {
    state = {...state, tabIndex: (state[tabIndex] ?? 0) + 1};
  }
}

final scrollTriggersProvider =
    NotifierProvider<_ScrollTriggers, Map<int, int>>(_ScrollTriggers.new);
