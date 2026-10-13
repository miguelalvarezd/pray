import 'package:flutter_test/flutter_test.dart';
import 'package:pray/core/time/logical_day.dart';

void main() {
  group('logicalToday', () {
    test('shifts wall-clock back by 4h so 02:00 still belongs to prior day', () {
      final result = logicalToday(now: DateTime(2026, 5, 1, 2, 0));
      expect(formatLogDate(result), '2026-04-30');
    });

    test('04:00 is the boundary — the new day starts here', () {
      final result = logicalToday(now: DateTime(2026, 5, 1, 4, 0));
      expect(formatLogDate(result), '2026-05-01');
    });

    test('respects YYYY-MM-DD override regardless of wall clock', () {
      final result = logicalToday(
        now: DateTime(2026, 5, 1, 12, 0),
        override: '2024-12-25',
      );
      expect(formatLogDate(result), '2024-12-25');
    });

    test('empty override string is treated as no override', () {
      final result = logicalToday(
        now: DateTime(2026, 5, 1, 12, 0),
        override: '',
      );
      expect(formatLogDate(result), '2026-05-01');
    });
  });

  group('dayOfYear', () {
    test('Jan 1 is day 1', () {
      expect(dayOfYear(DateTime(2026, 1, 1)), 1);
    });

    test('Dec 31 of a non-leap year is day 365', () {
      expect(dayOfYear(DateTime(2025, 12, 31)), 365);
    });

    test('Dec 31 of a leap year is day 366', () {
      expect(dayOfYear(DateTime(2024, 12, 31)), 366);
    });
  });
}
