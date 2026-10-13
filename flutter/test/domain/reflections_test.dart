import 'package:flutter_test/flutter_test.dart';
import 'package:pray/domain/reflections.dart';

void main() {
  test('same date always picks the same reflection', () {
    final a = reflectionForDate(DateTime(2026, 4, 30));
    final b = reflectionForDate(DateTime(2026, 4, 30));
    expect(a.text, b.text);
    expect(a.citation, b.citation);
  });

  test('cycles through the curated list', () {
    final n = kCuratedReflections.length;
    final first = reflectionForDate(DateTime(2026, 1, 1));
    final wrapped = reflectionForDate(DateTime(2026, 1, 1).add(Duration(days: n)));
    expect(wrapped.text, first.text);
  });

  test('different dates can yield different reflections', () {
    final a = reflectionForDate(DateTime(2026, 1, 1));
    final b = reflectionForDate(DateTime(2026, 1, 2));
    expect(a.text == b.text, isFalse);
  });
}
