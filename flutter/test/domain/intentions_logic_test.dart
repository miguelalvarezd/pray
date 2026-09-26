import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/intention_status.dart';
import 'package:pray/data/models/priority.dart';
import 'package:pray/domain/intentions_logic.dart';

Intention _i({
  String id = 'x',
  Priority priority = Priority.medium,
  String? targetDate,
  String createdAt = '2026-04-01T00:00:00.000Z',
  IntentionStatus status = IntentionStatus.active,
}) =>
    Intention(
      id: id,
      title: id,
      createdAt: createdAt,
      targetDate: targetDate,
      priority: priority,
      status: status,
    );

void main() {
  final now = DateTime(2026, 5, 1);

  group('calculateUrgency', () {
    test('Archived Intentions have negative urgency', () {
      expect(calculateUrgency(_i(status: IntentionStatus.archived), now), -1);
    });

    test('priority is the base score when there is no target date', () {
      expect(calculateUrgency(_i(priority: Priority.high), now), greaterThan(0));
      expect(
        calculateUrgency(_i(priority: Priority.high), now),
        greaterThan(calculateUrgency(_i(priority: Priority.medium), now)),
      );
      expect(
        calculateUrgency(_i(priority: Priority.medium), now),
        greaterThan(calculateUrgency(_i(priority: Priority.low), now)),
      );
    });

    test('imminent target date spikes urgency', () {
      final imminent = _i(targetDate: '2026-05-03'); // 2 days out
      final farOff = _i(targetDate: '2026-08-01'); // months out
      expect(calculateUrgency(imminent, now),
          greaterThan(calculateUrgency(farOff, now)));
    });

    test('overdue target date decays urgency below base', () {
      final overdue = _i(targetDate: '2026-04-01'); // 30 days late
      expect(calculateUrgency(overdue, now), lessThan(0));
    });
  });

  test('sortIntentions orders by urgency desc', () {
    final a = _i(id: 'low', priority: Priority.low);
    final b = _i(id: 'high', priority: Priority.high);
    final c = _i(id: 'imminent', targetDate: '2026-05-02');
    final sorted = sortIntentions([a, b, c], now);
    expect(sorted.first.id, 'imminent');
    expect(sorted.last.id, 'low');
  });

  test('buildIntentionCountMap sums distinct days', () {
    final logs = {
      '2026-04-29': const DailyLog(
        date: '2026-04-29',
        completedIntentions: ['x', 'y'],
      ),
      '2026-04-30': const DailyLog(
        date: '2026-04-30',
        completedIntentions: ['x'],
      ),
      '2026-05-01': const DailyLog(
        date: '2026-05-01',
        completedIntentions: ['z'],
      ),
    };
    final counts = buildIntentionCountMap(logs);
    expect(counts['x'], 2);
    expect(counts['y'], 1);
    expect(counts['z'], 1);
    expect(counts['nothing'], isNull);
  });
}
