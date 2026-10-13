import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/domain/streaks_logic.dart';

DailyLog _log(String d, {List<String> prayers = const ['mass']}) =>
    DailyLog(date: d, completedPrayers: prayers);

void main() {
  final today = DateTime(2026, 5, 1);

  group('isPrayedDay', () {
    test('a Day with only an Activity is a Prayed Day', () {
      const log = DailyLog(date: '2026-05-01', completedActivities: ['confession']);
      expect(isPrayedDay(log), isTrue);
    });

    test('a Day with only a Novena prayed is a Prayed Day', () {
      const log = DailyLog(date: '2026-05-01', completedNovenas: ['n1']);
      expect(isPrayedDay(log), isTrue);
    });

    test('a Day with only a Daily Prayer is a Prayed Day', () {
      const log = DailyLog(date: '2026-05-01', completedPrayers: ['rosary']);
      expect(isPrayedDay(log), isTrue);
    });

    test('a Day with only Intentions ticked is not a Prayed Day', () {
      const log = DailyLog(date: '2026-05-01', completedIntentions: ['i1']);
      expect(isPrayedDay(log), isFalse);
    });

    test('a Day with only a Gratitude Entry is not a Prayed Day', () {
      const log = DailyLog(date: '2026-05-01', gratitudeEntry: 'Thankful');
      expect(isPrayedDay(log), isFalse);
    });

    test('Activity-only Days keep the Streak going', () {
      final logs = {
        '2026-04-29': _log('2026-04-29'),
        '2026-04-30': const DailyLog(date: '2026-04-30', completedActivities: ['adoration']),
        '2026-05-01': _log('2026-05-01'),
      };
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 3);
      expect(r.best, 3);
    });
  });

  group('calculateStreak (Prayed Day)', () {
    test('empty logs → 0/0', () {
      final r = calculateStreak({}, isPrayedDay, today);
      expect(r.current, 0);
      expect(r.best, 0);
    });

    test('today only → current 1, best 1', () {
      final logs = {'2026-05-01': _log('2026-05-01')};
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 1);
      expect(r.best, 1);
    });

    test('yesterday only → current 1 (forgives empty today), best 1', () {
      final logs = {'2026-04-30': _log('2026-04-30')};
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 1);
      expect(r.best, 1);
    });

    test('day-before-yesterday only → current 0 (gap is too big)', () {
      final logs = {'2026-04-29': _log('2026-04-29')};
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 0);
      expect(r.best, 1);
    });

    test('5 consecutive days through yesterday', () {
      final logs = {
        '2026-04-26': _log('2026-04-26'),
        '2026-04-27': _log('2026-04-27'),
        '2026-04-28': _log('2026-04-28'),
        '2026-04-29': _log('2026-04-29'),
        '2026-04-30': _log('2026-04-30'),
      };
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 5);
      expect(r.best, 5);
    });

    test('current resets on gap, best remembers earlier longer run', () {
      final logs = {
        // long old run of 4
        '2026-03-01': _log('2026-03-01'),
        '2026-03-02': _log('2026-03-02'),
        '2026-03-03': _log('2026-03-03'),
        '2026-03-04': _log('2026-03-04'),
        // gap, short recent run of 2 ending yesterday
        '2026-04-29': _log('2026-04-29'),
        '2026-04-30': _log('2026-04-30'),
      };
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 2);
      expect(r.best, 4);
    });

    test('day with empty prayer list does not count', () {
      final logs = {
        '2026-05-01': _log('2026-05-01', prayers: const []),
      };
      final r = calculateStreak(logs, isPrayedDay, today);
      expect(r.current, 0);
      expect(r.best, 0);
    });

    test('hasPrayerCompleted scopes the streak to a single prayer id', () {
      final logs = {
        '2026-04-29': _log('2026-04-29', prayers: const ['rosary', 'mass']),
        '2026-04-30': _log('2026-04-30', prayers: const ['mass']),
        '2026-05-01': _log('2026-05-01', prayers: const ['rosary']),
      };
      final massStreak =
          calculateStreak(logs, hasPrayerCompleted('mass'), today);
      final rosaryStreak =
          calculateStreak(logs, hasPrayerCompleted('rosary'), today);
      // Mass streak: ran 4/29 + 4/30, today no mass → forgives today, current=2
      expect(massStreak.current, 2);
      // Rosary streak: ran 4/29, gap 4/30, rosary 5/1 → current=1
      expect(rosaryStreak.current, 1);
    });
  });
}
